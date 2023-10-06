
On MacOS

```
find . -name "*.flac" -exec afconvert -d aac -f m4af -b 256000 -s 2 -q 127 {} {}.m4a \;
```

On Linux, convert filenames (special characters / accents to Linux style from Mac), and add tags.
```
convmv --nfc -f utf8 -t utf8 -r --notest .
find . -name "*.flac" -exec bash -c 'ffmpeg -y -i "$1" -i "$1".m4a -map 1 -c copy -map_metadata 0  "${1%.flac}".m4a' - '{}' \;
```
