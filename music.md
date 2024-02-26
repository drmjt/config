
# Music

## Prepare flac files

### Cover art for flacs

Remove cover art, both seemingly needed to remove art and not leave padding
```
find -name "*.flac" -exec metaflac --remove --block-type=PICTURE,PADDING --dont-use-padding "{}" \;
find -name "*.flac" -exec metaflac --remove-tag=COVERART  --dont-use-padding "{}" \;
```

Add new art from folder.jpg
```
find -name "*.flac" -exec bash -c 'metaflac --import-picture-from="$(dirname "$(readlink -f "{}")")/folder.jpg" "{}" ' \;
```

### Check that the files are OK

Check flac files with a tool, only output on problems
```
find -name "*.flac" -exec bash -c 'flac -wst "{}" 2>/dev/null || printf '%3d %s\n' "$?" "{}"' \;
```

Count the number of files, and look for empty files
```
find -name "*.flac" -not -empty | wc -l
```

Compare just the audio contents with a backup using the command given for opus files below

## Encoding Opus files

These have the advantage over m4a of providing gapless playback at the time of writing. This will encode in 16 threads.

```
find . -type f -name "*.flac" -print0|xargs -0 -P 16 -I {} sh -c 'opusenc --bitrate 192 --vbr "$1" "${1%.*}.opus" ' sh {}
```

### Check the audio contents
Compare the audio contents of two files, in this case opus, but can be used for any format. For example compare before and after writing tags, which for some formats could affect volume, gapless playback, etc.

```
find ./dir1/ -name "*.opus" -exec bash -c 'ffmpeg -y -i "{}" /tmp/1.wav; ffmpeg -y -i "./dir2/{}" /tmp/2.wav; diff /tmp/1.wav /tmp/2.wav || echo "{}" >> ~/result ' \;
```


### Converting flac to m4a/aac for apple devices

On MacOS, use afconvert to convert to itunes plus quality. At the time of writing this is regarded as the highest quality aac encoder. Note that copying to and from MacOS can change the characters used in filenames (e.g. accented e). 

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

