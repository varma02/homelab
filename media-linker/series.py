from pathlib import Path
from difflib import SequenceMatcher
from itertools import groupby
from argparse import ArgumentParser
import re


PREFIX = ""
print = lambda *args, **kwargs: __builtins__.print(PREFIX, *args, **kwargs)


VIDEO_EXTENSIONS = {'.mp4', '.mkv', '.avi', '.mov', '.wmv', '.flv', '.webm', '.m4v'}
SERIES_FILTER = r's\d{2}|series|season|specials|\d{2}x\d{2}|s\d{1,2}e\d{1,2}|s\d{1,2}.{1,3}\d{1,2}'
SAMPLE_FILTER = r'sample'
W = r'[^a-zA-Z0-9]'

class Media:
    def __init__(self, path: Path, title: str, season: int, episode: int):
        self.path = path
        self.title = title
        self.season = season
        self.episode = episode


def extract_episode_info(name: str) -> tuple[str, int, int] | None:
    name = name.strip().lower()
    m = re.search(W+r's(\d{2})[\w\.]{0,1}e(\d{2})'+W, name)
    if m: return (re.sub(W, '', name[:m.start()]), int(m.group(1)), int(m.group(2)))

    m = re.search(W+r'(\d{2})x(\d{2})'+W, name)
    if m: return (re.sub(W, '', name[:m.start()]), int(m.group(1)), int(m.group(2)))
    
    m = re.search(W+r's(\d{2}) - e{0,1}(\d{2})'+W, name)
    if m: return (re.sub(W, '', name[:m.start()]), int(m.group(1)), int(m.group(2)))
    
    return None

def media_search(name: str, season: int, downloads_media: list[Media], layers: int):
    name = re.sub(W, '', name.strip().lower())
    matches = [m for m in downloads_media if m.season == season]
    matches = map(lambda x: (x[0], list(x[1])), groupby(matches, key=lambda x: x.path.parents[-(layers)]))
    matches = sorted(map(lambda x: (SequenceMatcher(None, name, x[1][0].title).ratio(), x), matches), key=lambda x: x[0], reverse=True)
    return matches[:5]

def list_matches(matches) -> None:
    print("Found potential matches:")
    for i, (score, (key, _)) in enumerate(matches, 1):
        print(f"{i}: {key} (score: {score:.2f})")

def user_menu(max: int) -> int:
    while True:
        user_input = input(f"Select an option (1-{max}) or ('s' skip, 'f' manual search): ").strip()
        try:
            choice = int(user_input)
            if 1 <= choice <= max:
                return choice
        except ValueError:
            match user_input.lower():
                case 's':
                    return 6
                case 'f':
                    return 7
        print("Invalid input.")

def link_all(sources: list[Media], destination: Path) -> None:
    for source in sources:
        source = source.path
        link_path = destination / source.name
        link_path.symlink_to(source.resolve())
        print(f"Linked {source} to {link_path}")

def main() -> None:
    print("Series Linker Script - by: varma01")
    print("-----------------------------------")
    print("Parsing arguments...", end=" ")
    parser = ArgumentParser(description="Link episodes of series from downloads folder to Jellyfin series folder.")
    parser.add_argument("downloads_path", help="Path to the downloads directory")
    args = parser.parse_args()
    work_dir = Path.cwd()
    downloads_dir = Path(args.downloads_path)
    print("OK")

    print(f"Working directory: {work_dir}")
    print(f"Downloads directory: {downloads_dir}")

    print("Scanning for series folders...", end=" ")
    series_folders = [p for p in work_dir.iterdir() if p.is_dir()]
    print("OK")
    print("Scanning downloads folder...", end=" ")
    downloads_media: list[Media] = []
    for p in downloads_dir.rglob('*'):
        if p.is_file() and \
        p.parent != downloads_dir and \
        p.suffix.lower() in VIDEO_EXTENSIONS and \
        re.search(SERIES_FILTER, p.stem.lower() +"/"+ p.parent.stem.lower()) and \
        not re.search(SAMPLE_FILTER, p.stem.lower() +"/"+ p.parent.stem.lower()):
            info = extract_episode_info(p.stem)
            if info is not None:
                downloads_media.append(Media(p, info[0], info[1], info[2]))
    print("OK")

    print(f"Found {len(series_folders)} series folders.")
    print(f"Found {len(downloads_media)} media files in downloads.")

    print("-----------------------------------\n")

    for series_folder in series_folders:
        print(f"Searching series folder: {series_folder.name}")
        for season_folder in sorted([f for f in series_folder.iterdir() if f.is_dir() and f.stem.strip().lower().startswith('season')]):
            print(f"\t {season_folder.name} - ", end="")
            has_media = any(f.suffix.lower() in VIDEO_EXTENSIONS for f in season_folder.rglob('*') if f.is_file())
            if has_media:
                print("OK")
            else:
                print("No media files found")
                name = series_folder.stem.strip().lower()[:series_folder.stem.find('[')]
                season = int(re.search(W+r'\d{1,2}', season_folder.stem).group())
                matches = media_search(name, season, downloads_media, len(downloads_dir.parents))
                list_matches(matches)
                while True:
                    choice = user_menu(len(matches))
                    match choice:
                        case 1 | 2 | 3 | 4 | 5:
                            link_all(matches[choice - 1][1][1], series_folder)
                            break
                        case 6:
                            print("Skipping this season.")
                            break
                        case 7:
                            query = input("Enter a search query for the media file: ").strip()
                            matches = media_search(query, season, downloads_media, len(downloads_dir.parents))
                            list_matches(matches)
                print()
        print()


if __name__ == "__main__":
    main()
