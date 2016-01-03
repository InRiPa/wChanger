#!/bin/bash

###################################
##       -- wChanger --		 	 ##
##  A dynamic wallpaper changer  ##
###################################





# Help function: displayed on input error or help request
usage(){
        echo "Usage: $0 "
        exit 1
}

# Check which flags and parameters are set
verbose=0	# flag for additional informations (default = 0 = silent)
while [ "$1" != "" ]; do
  case $1 in
    -h | --help )       usage
                        exit 2          ;; # help
    -v | --verbose )    verbose=1       ;; # verbose flag 
    * )			usage
			exit 1          ;;

  esac
  shift
done


# DebugMessages:
# Use this function if you want to print some debug
# echos which are only displayed in verbose mode
debugM(){
  message=$1
  if [ $verbose -eq 1  ]; then
     echo "$message "
  fi
}


# Error-LOG: 
# First argument ($1) contains the error message
# Be sure to put them in ""; otherwise a error message 
# would end up in x parameters. 
errorLog(){
  currDate=$(date)
  echo "$currDate: $1" >> $imgPath/errorlog.log
}



# The following functions are first implementations of extra randomness
# in getting a wallpaper out of the $imgDB
# Remember that the Image-Grabber-Tools already chose the
# background images (saved in $imgDB) randomly. 
# - random piece out of imgCache (takes one out of all randomly)


# Simple image choosing algorithm:
# It just takes always the first image in the $imgDB as wallpaper
# It can be used, if you intend to download only one wallpaper at 
# once anyway.
clearSimple(){
  sourceLink=$(head -n 1 $imgDB)	# get first line of $imgDB
}

# Random image out of $imgDB:
# Takes 1 image randomly out of $imgDB. 
# It uses internal $RANDOM and modulo operation to determine the number
simpleRnd(){

rnd=0		 # number which line of $imgDB should be used as wallpaper
li=0		 # locale increment variable to reach $rndNumber
salt=$(date +%S) # used for better random number. %S for 'only seconds'

# Generate random number from 0 to amount behind the modulo sign
# the +1 is used to omit the 0 and get the maximum number
# eg.: nr=7 -> 0-6 --> 1-7
rnd=$[($(($RANDOM+$salt)) % $(wc -l < "$imgDB"))+1]

while [ "$li" != "$rnd" ] && read -r line	# while rnd number is not reached 
do						# AND file still got lines in it
    sourceLink=$line
    li=$((li+1))
done < "$imgPath/$imgDB"

}


# Download image function:
# Downloads the link in $sourceLink in a file called 'cache<nr>.<ext>'
# Number can vary (not yet ;) )
# Image extension will be determined dynamically (just in time)
downloadSource(){
  i=0
  
  IFS='/ ' read -a tmpArray <<< "$sourceLink" # split string into array (remove whitespaces and slash)
  imgFile=${tmpArray[${#tmpArray[@]}-1]} # access last element of array: arraylength-1 => array starts with 0
  debugM "chosen image: " $imgFile
  # now we got something like jf8f3f.jpg
  IFS='.' read -a tmpArray <<< "$imgFile" # split string on '.' to get file ending
  cacheFile=cache$i.${tmpArray[${#tmpArray[@]}-1]} # string: 'cache'+'nr'+'.'+'file extension'
  options="-o $imgPath/$cacheFile $sourceLink" 
  if [ ! $verbose -eq 1  ]; then
    options="$options -s"
  fi
  curl $options
  return $?
}


# Activate new Wallpaper function:
# Checks for the environment and uses the specific command to set the new background wallpaper
# (not quite done yet ;) )
setWallpaper(){

 # -- FOR GNOME --
 # FIXME: Check for operating environment; in order to choose correct command to set background

 gsettings set org.gnome.desktop.background picture-uri file://$imgPath/$cacheFile	# file:///.. is correct
 # in case images don't have required sizes
 gsettings set org.gnome.desktop.background picture-options zoom # commented because of a bug

}


#######################################
#         -  SCRIPTING PART  -        #
#       Create your own script !      #
#######################################
#
# Build here your script which defines 
# - WHEN (e.g. seasonal)
# - WHICH (multiple sources: remember that img-grab-tools got the -a flag)
# image should be used as a wallpaper

# These functions are already available

# 1) Define image grabbing tool + source
#    # grabur.sh - image grabber for imgur.com
#	 # grabloc.sh - image grabber for local images
#    # <FIXME> - image grabber for wallbase.cc
#    # <FIXME> - image grabber for hdwallpapers.in
#    # < missing etc. you name it >
# 2) Get link number of wallpaper out of $imgDB
#    # clearSimple()
#    # simpleRnd()
# 3) Download image as <cache>.<filetype> 
#    # downloadSource()
# 4) Set it up as background 
#    # setWallpaper()
#
# IMPORTANT: Don't forget to write this script in your 'crontab -e' as final installment
# e.g.: 59 * * * * /path/to/wChanger.sh          # executes script at every hour and 59 minutes


# In the following a simple example script: 
# ------------------------------------------

imgPath="/home/<user>/Tools/wChanger" 	# path to all script files
imgDB=$imgPath"/wallpaper.txt"			# name of file that contains retrieved images
imgSrc="http://imgur.com/a/YMF4S"		# path to image container
						# http://imgur.com/a/YMF4S -- chilltep.info
						# http://imgur.com/a/lZaZR -- cities 
						# http://imgur.com/a/rMPdm -- 1.000 1080p Pic's !!
						# http://imgur.com/a/S7MtD/layout/blog -- 180+ Woman
sourceLink=""					# contains URL to wallpaper for the new background
imgCache=4					# amount of images to be retrieved 
						# from image container


debugM "-- verbose mode -- "	# debugM prints the message only if verbose mode is active


bash $imgPath/grabur.sh -n $imgCache $imgSrc $imgDB	# load images from given source into $imgDB
													# using imgur grab extension
debugM "imgDB is loaded with wallpaper links "

clearSimple			# $sourceLink is now available
					# clearSimple: just take the first image in the db
debugM "chosen image: $sourceLink "

downloadSource 			# image downloaded and cacheFile created
debugM "Image downloaded"
if [ $? -ne 0 ]; then
  debugM "failed to load image."
  exit 1
fi

setWallpaper			# set image as wallpaper
debugM "new Wallpaper loaded"

debugM "I'm done here :)" 


# -- End of Script -- #
# ------------------- #






