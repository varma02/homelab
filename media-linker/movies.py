import argparse
from pathlib import Path
import difflib
import re

VIDEO_EXTENSIONS = {'.mp4', '.mkv', '.avi', '.mov', '.wmv', '.flv', '.webm', '.m4v'}
TITLE_FILTER = r'([\ \_\-\(\)\[\]\.\/]|(1080p|720p|480p|1440p|UHD)|(bluray|webrip|webdl|hdtv)|(x264|x265|av1|h264|h265))+'
SERIES_FILTER = r's\d{2}|series|season|\d{2}x\d{2}'
SAMPLE_FILTER = r'sample'

def extract_title(name: str) -> str:
    name = name.strip().lower()
    name = re.sub(TITLE_FILTER, '', name)
    return name

def media_search(query: str, downloads_media: list[Path]) -> list[tuple[float, Path]]:
    movie_title = extract_title(query)
    matches = []
    for media in downloads_media:
        media_title = extract_title(media.parent.stem + media.stem)
        score = difflib.SequenceMatcher(None, movie_title, media_title).ratio()
        matches.append((score, media))
    matches.sort(key=lambda x: x[0], reverse=True)
    return matches[:5]

def list_matches(matches: list[tuple[float, Path]]) -> None:
    print("Found potential matches:")
    for i, (score, media) in enumerate(matches, 1):
        print(f"{i}: {media.parent.stem}/{media.name} (score: {score:.2f})")

def user_menu(max: int) -> int:
    while True:
        user_input = input(f"Select an option (1-{max}) or ('s' skip, 'm' manual entry, 'f' manual search): ").strip()
        try:
            choice = int(user_input)
            if 1 <= choice <= max:
                return choice
        except ValueError:
            match user_input.lower():
                case 's':
                    return 6
                case 'm':
                    return 7
                case 'f':
                    return 8
        print("Invalid input.")

def link_media(source: Path, destination: Path) -> None:
    link_path = destination / source.name
    link_path.symlink_to(source.resolve())
    print(f"Linked {source} to {link_path}")

def main() -> None:
    print("Movie Linker Script - by: varma01")
    print("-----------------------------------")
    print("Parsing arguments...", end=" ")
    parser = argparse.ArgumentParser(description="Link movies from downloads folder to Jellyfin movies folder.")
    parser.add_argument("downloads_path", help="Path to the downloads directory")
    args = parser.parse_args()
    work_dir = Path.cwd()
    downloads_dir = Path(args.downloads_path)
    print("OK")

    print(f"Working directory: {work_dir}")
    print(f"Downloads directory: {downloads_dir}")

    print("Scanning for movie folders...", end=" ")
    movie_folders = [p for p in work_dir.iterdir() if p.is_dir()]
    print("OK")
    print("Scanning downloads folder...", end=" ")
    downloads_media = [
        p for p in downloads_dir.rglob('*') \
        if p.is_file() and \
        p.suffix.lower() in VIDEO_EXTENSIONS and \
        not re.seatch(SERIES_FILTER, p.stem.lower() +"/"+ p.parent.stem.lower()) and \
        not re.seatch(SAMPLE_FILTER, p.stem.lower() +"/"+ p.parent.stem.lower())
    ]
    print("OK")

    print(f"Found {len(movie_folders)} movie folders.")
    print(f"Found {len(downloads_media)} media files in downloads.")

    print("-----------------------------------\n")

    for folder in movie_folders:
        print(f"Found movie folder: {folder.name} - ", end="")
        has_media = any(f.suffix.lower() in VIDEO_EXTENSIONS for f in folder.rglob('*') if f.is_file())
        if has_media:
            print("OK")
        else:
            print("No media files found")
            query = folder.name
            matches = media_search(query, downloads_media)
            list_matches(matches)
            while True:
                choice = user_menu(len(matches))
                match choice:
                    case 1 | 2 | 3 | 4 | 5:
                        link_media(matches[choice - 1][1], folder)
                        break
                    case 6:
                        print("Skipping this movie.")
                        break
                    case 7:
                        manual_media = Path(input("Enter the full path to the media file: ").strip())
                        if manual_media.exists() and manual_media.is_file() and manual_media.suffix.lower() in VIDEO_EXTENSIONS:
                            link_media(manual_media, folder)
                        else:
                            print("Invalid media file path.")
                    case 8:
                        query = input("Enter a search query for the media file: ").strip()
                        matches = media_search(query, downloads_media)
                        list_matches(matches)
            print()


if __name__ == "__main__":
    main()
