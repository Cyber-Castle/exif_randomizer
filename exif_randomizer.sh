#!/bin/bash
################################################################################
################################################################################
# Created by NISB 07 May 2022
#
# This script uses exiftool in order to randomly assign exif data to a bunch of
# photos. It is designed to be pointed at a single directory, but you can edit
# in order to make it point only at specific types of files
#
# EXIFTOOL automatically makes backups (*_original)
#
# Right now this is picking completely randomly for lat, long, created date, and
# modified date. There is a ton of work that could be done in order to build a
# more credible tool.
# Immitate camera models
# Pick Dates in a more recent range
# Bias Modified Dates toward the create date
# Pic coordinates in countries
# Do research into what granularity of GPS reporting
################################################################################
################################################################################

################################################################################
# USER INPUT
################################################################################
path_to_pics="/home/chrx/Documents/Obsidian/CyberCastle/pics/"
################################################################################

# First, lets strip off all of the old data
echo "> Removing all old EXIF data"
exiftool -recurse -all= $path_to_pics


# Then we loop through each file and pick some random data to assign to it
echo "> Generating New EXIF data"

for file in "$path_to_pics"*; do

	# Pick Random Lat and Long
	echo -e "\t Picking new Data for $file"

	lat_whole=$((RANDOM % 180 - 90))
	lat_dec=$(((RANDOM * RANDOM) % 999999))
	
	long_whole=$((RANDOM %  360 - 180))
	long_dec=$(((RANDOM * RANDOM) % 999999))

	lat_string="$lat_whole.$lat_dec"
	long_string="$long_whole.$long_dec"

	echo -e "\t \t Random lat: $lat_string"
	echo -e "\t \t Random long: $long_string"


	# Pick Random dates
	# Unix time starts January 1st, 1970
	today=$(date +%s)

	# Pick a random original creation date
	original_date=$(((RANDOM*RANDOM*RANDOM) % $today))

	# Pick a random modified date
	range=$(($today - $original_date))
	modify_date=$(((RANDOM*RANDOM) % $range + $original_date))

	# Convert our dates from epoch time to the correct format
	original_date_string="$(date -d @$original_date +%Y)\
:$(date -d @$original_date +%m)\
:$(date -d @$original_date +%d)\
	$(date -d @$original_date +%H)\
:$(date -d @$original_date +%M)\
:$(date -d @$original_date +%S)\
Z"

	modify_date_string="$(date -d @$modify_date +%Y)\
:$(date -d @$modify_date +%m)\
:$(date -d @$modify_date +%d)\
	$(date -d @$modify_date +%H)\
:$(date -d @$modify_date +%M)\
:$(date -d @$modify_date +%S)\
Z"

	echo -e "\t \t Random original date: $original_date_string"
	echo -e "\t \t Random modify date: $modify_date_string"


	# Change the exif

	exiftool \
		-DateTimeOriginal="$original_date_string"\
		-CreateDate="$original_date_string"\
		-ModifyDate="$modify_date_string"\
		-GPSLatitude="$lat_string"\
		-GPSLongitude="$long_string"\
		\
		"$file"

	echo -e "\t Modified $file"

done
