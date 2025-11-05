# Agent Instructions for media-linker

I want to create a python script for linking movies from my downloads folder into the jellifin movies folder. I would like it to discover my existing movie folders and then see which does not already contain a media file. Then it should search for the movie in my downloads folder and subfolders. After it found a match, it should ask me if it is the right one, let me chose from less precise matches or let me enter the path manually. And in the end it should link the selected media file into the respective movie's folder. The search should be somewhat fuzzy since the filename usually contains extra information about resolution, source, etc...

## Code Style Guidelines

- **Imports**: Use absolute imports, group stdlib, third-party, local imports with blank lines
- **Formatting**: Follow PEP 8, use Black formatter, 88 char line length
- **Types**: Use type hints for all functions, prefer `Union` over `|`, use `Optional` for nullable types
- **Naming**: snake_case for functions/variables, PascalCase for classes, UPPER_CASE for constants
- **Error handling**: Use try/except with specific exceptions, log errors with context
- **Security**: Never expose paths, validate all user inputs, use pathlib for path operations

## Example Usage

Example result when a movie folder is found without a media file:

```
admin@localhost:/media/movies/$ python ~/link.py /path/to/downloads
Found movie folder: Inception (2010) - No media file found.
Searching for media files in /path/to/downloads...
Found potential matches:
1: Inception.2010.1080p.BluRay.x264.YIFY.mp4
2: Inception.2010.720p.WEB-DL.x264.AAC.mkv
Select an option (1, 2, 'm' for manual entry, 's' to skip, 'f' manual search): 1
Linking /path/to/downloads/Inception.2010.1080p.BluRay.x264.YIFY.mp4 to /media/movies/Inception (2010)/

... (continues for other movies) ...
```

## Progress Summary

So far, we've implemented the initial setup in `link.py`:

- Added command-line argument parsing to accept the downloads directory path.
- Set variables for the working directory (current cwd, assumed to be the movies folder) and downloads directory.
- Listed all subdirectories in the working directory as potential movie folders.
- Defined a set of common video file extensions (mp4, mkv, avi, etc.).
- Added a loop to check each movie folder for existing media files; only folders without media files are identified and printed with the message "No media file found."
- Created a function which will handle the media search logic (currently a placeholder).
- Implemented fuzzy matching logic using `difflib.SequenceMatcher` to compare movie folder names with media file names in the downloads directory.
