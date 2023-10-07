
# Music

### Converting flac to m4a/aac for apple devices

On MacOS, use afconvert to convert to itunes plus quality. Note that copying to 

```
find . -name "*.flac" -exec afconvert -d aac -f m4af -b 256000 -s 2 -q 127 {} {}.m4a \;
```

On Linux, convert filenames (special characters / accents to Linux style from Mac), and add tags.
Adding artwork requires atomicparsley.
```
convmv --nfc -f utf8 -t utf8 -r --notest .
find . -name "*.flac" -exec bash -c 'ffmpeg -y -i "$1" -i "$1".m4a -map 1 -c copy -map_metadata 0  "${1%.flac}".m4a' - '{}' \;
find -name "*.m4a" -exec bash -c 'atomicparsley "{}" --artwork "$(dirname "$(readlink -f "{}")")/folder.jpg" --overWrite' \;
```

## Flac files

### Cover art for flacs

Remove cover art, both seemingly needed to remove art and not leave padding
```
find -name "*.flac" -exec metaflac --remove --block-type=PICTURE,PADDING --dont-use-padding "{}" \;
find -name "*.flac" -exec metaflac --remove-tag=COVERART  --dont-use-padding "{}" \;
```

Add new art
```
find -name "*.flac" -exec bash -c 'metaflac --import-picture-from="$(dirname "$(readlink -f "{}")")/folder.jpg" "{}" ' \;
```

Check flac files, only output on problems
```
find -name "*.flac" -exec bash -c 'flac -wst "{}" 2>/dev/null || printf '%3d %s\n' "$?" "{}"' \;
```

## Check that the files are OK

Count the number of files, and look for empty files
```
find -name "*.flac" -not -empty | wc -l
```

Use flac tool to check for errors
```
find -name "*.flac" -exec bash -c 'flac -wst "{}" 2>/dev/null || printf '%3d %s\n' "$?" "{}"' \;
```

Compare just the audio content with a backup
```
find -name "*.flac" -exec bash -c 'ffmpeg -y -i "{}" /tmp/1.wav; ffmpeg -y -i "../flac.bak/{}" /tmp/2.wav; diff /tmp/1.wav /tmp/2.wav >> ~/result ' \;
```
