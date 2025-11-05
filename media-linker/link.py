import argparse
from pathlib import Path
import difflib

VIDEO_EXTENSIONS = {'.mp4', '.mkv', '.avi', '.mov', '.wmv', '.flv', '.webm', '.m4v'}

def extract_title(name: str) -> str:
    name = name.strip().lower()
    name = name.replace(' ', '.')
    name = name.replace('(', '').replace(')', '')
    bracket_pos = name.find('[')
    name = name[:bracket_pos if bracket_pos != -1 else len(name)]
    return name

def media_search(query: str, downloads_media: list[Path]) -> list[tuple[float, Path]]:
    movie_title = extract_title(query)
    matches = []
    for media in downloads_media:
        media_title = extract_title(media.stem)
        score = difflib.SequenceMatcher(None, movie_title, media_title).ratio()
        matches.append((score, media))
    matches.sort(key=lambda x: x[0], reverse=True)
    return matches[:5]

def list_matches(matches: list[tuple[float, Path]]) -> None:
    print("Found potential matches:")
    for i, (score, media) in enumerate(matches, 1):
        print(f"{i}: {media.name} (score: {score:.2f})")

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
    parser = argparse.ArgumentParser(description="Link movies from downloads folder to Jellyfin movies folder.")
    parser.add_argument("downloads_path", help="Path to the downloads directory")
    args = parser.parse_args()

    work_dir = Path.cwd()
    downloads_dir = Path(args.downloads_path)

    movie_folders = [p for p in work_dir.iterdir() if p.is_dir()]
    downloads_media = [p for p in downloads_dir.rglob('*') if p.is_file() and p.suffix.lower() in VIDEO_EXTENSIONS]

    print(f"Working directory: {work_dir}")
    print(f"Downloads directory: {downloads_dir}")
    print(f"Found {len(movie_folders)} movie folders.")
    print(f"Found {len(downloads_media)} media files in downloads.")

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
                choice = user_menu(matches)
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


if __name__ == "__main__":
    main()
