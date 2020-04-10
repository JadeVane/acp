#!/bin/bash
#
# [Features]
# 1. Compress the pictures in the monitored folder
# 2. Supported: jpg, jpeg. png
#
# [Requirement]
# 1. Monitoring component: 
#    - inotify-tools (inotifywait of it)
# 2. Compress component: 
#    - pngquant
#    - jpegoptim
#
# [Usage]
# ./compress.sh /path/to/directory/
#
# [Author]
# By wenjinyu, on 2020.04.10

EVENTPATH=$1
Quality=50

# compress png, jpg
_Compress_Pic () {
	File_suffix="${File##*.}"

	if [[ $File_suffix == "png" ]]
	then
		pngquant --quality=$Quality --ext=.png --force --speed 1 "$File"
	elif [[ $File_suffix == "jpg" ]] || [[ $File_suffix == "jpeg" ]]; then
		jpegoptim -m$Quality "$File"
	fi
}

# -m   Continuous monitoring
# -e   Which type to monitor, available types: modify, create, delete, moved_to, moved_from
# %w%f The output of event，
#          %w mean the filename when monitor a file
#          %f mean the name of the file in the directory when monitor a directory
inotifywait -m -e create,moved_to ${EVENTPATH} --format "%w%f" | while read File
do
	_Compress_Pic
done
