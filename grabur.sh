##########################################
##      IMGUR - IMAGE GRABBER           ##
##					##
## Arg $2: Source-Link                  ##
## Arg $3: destination file txt-file	##
##	   (absolute)			##
##########################################

# FIXME: 
# The modulo calculation errors sometimes with division by zero 
# (probably because no links gathered [no connection ?]) 
#
# Adding help section for help flag 
#



# Command that defines which shell to use
#!/bin/bash



imageContainer=$1			 	# Container where images are stored online 
sourceIsSet=0					# boolean: 1 = Source Parameter is set
links=()                         	  	# links to access picture preview
index=0						# index counter for links-array
append=0					# append links to output or clear output file first (0-false 1-true )
imgBuffer=0					# amount of images cached from the website (0 means all)
destination=$2					# .txt file where parsed links should be stored
rnd=0						# select random Image from Container
verbose=0					# flag: if set addidtional text will be displayed (debug purpose)

usage(){
        echo "Usage: $0 [-a] [-v] [-n <number>] [-h][--help] <source> <destination>"
        exit 1
}

# DebugMessages:
# Use this function if you want to print some debug
# echos which are only displayed in verbose mode
debugM(){
  message=$1
  if [ $verbose -eq 1  ]; then
     echo "$message "
     logger System -- "$1"
  fi
}



# check if minimum parameters (src and dest) are set
if [ $# -lt 2 ]; then
 echo "Error: missing parameters."
 usage
fi

# Check which flags and parameters are set
while [ "$1" != "" ]; do
  case $1 in
    -a | --append )	append=1	;; # append
    -h | --help )	usage
			exit 2		;; # help
    -n | --amount )	shift
			re='^[0-9]+$' # regex: check if input is a number
			if ! [[ $1 =~ $re ]] ; then
			   echo "error: -n needs a number as argument." >&2; exit 3
			fi
			imgBuffer=$1	;; # amount of pictures
    -v | --verbose )	verbose=1	;; # verbose flag 
   * )
		# it is assumed, that the first flagless parameter is the source
		# the second has to be the destination then (is source is set)
		if [ $sourceIsSet -eq 1 ]; then
                	destination=$1
               	else
                	imageContainer=$1;
                        sourceIsSet=1;
                fi ;;
   
  esac
  shift
done

# FUNCTION: Check for malformed links
# Checks if link is malformed and tries to fix it
# --> ATTENTION: Overrides variable $file !!
# $1 contains link to be checked
checkForBrokenLink(){

  # check if link starts with "//" instead of "http://"
  if [[ $1 == //*  ]]; then
     debugM "malformed URL detected: trying to repair.."
     file="http:"$1
  else
     debugM "URL wellformed. all ok :)"
  fi

}



###########################################################################################################
# rough filter: get all lines with imgur wallpapers							  #
#    ex: <img class="unloaded" data-src="http://i.imgur.com/5JUMGh.jpg" alt="" />			  #
#	 <img src="http://i.imgur.com/eWtfMME.png" alt="" />						  #
# I)  get URL-Sourcecode										  #
# II) get all lines that contain '<img' AND 'i.imgur'							  #
# III) throw out all lines that contain 'thumb-title' OR '<img class="nodisplay"'			  #
#													  #
# old one.. can be deleted later (for now just for history)						  #
#site=$(curl -s $imageContainer | grep -E '<img.*i.imgur' | grep -Ev 'thumb-title|<img class="nodisplay"') #
site=$(curl -s $imageContainer | grep -E 'href="//i.imgur.com*') 					  #
###########################################################################################################

# Now extract the direct link from each image and safe it to the links() array

# get all links
debugM "extracting links from source."
for file in $(echo "$site" ) 
do
	debugM "entry found: $file"
   if [[ "$file" == *i.imgur*  ]]; then
	file=$(echo $file | cut -d '=' -f 2 | cut -d '"' -f 2)
	debugM "grep'ed link => $file "	# DEBUG
	checkForBrokenLink $file	# check for maleformed links and fix them if necessary
        debugM "added file to array: $file"
        links[$index]=$file		# Add new url to array
        index=$((index+1))		# increment array index by 1 to reach new position
   fi
done


# determine if output file has to be wiped or not
if [ $append -eq 0  ]; then
  debugM "append-mode: false - output wiped"	#DEBUG
  > $destination			# making sure that file exists AND is empty
fi


# if imgBuffer is 0 : save all links to output file
if [ $imgBuffer -eq 0 ]; then
   debugM "all save mode"	 #DEBUG
   for (( ci=0;ci<${#links[@]};ci++ ))
   do
	#echo "nr: $ci = ${links[$ci]}" #DEBUG 
	echo "${links[$ci]}" >> $destination 
   done
# otherwise save random pictures (amount imgBuffer) from array in output file
else
   debugM "amount save mode($imgBuffer)"	#DEBUG
   for (( ci=0;ci<$imgBuffer;ci++ ))
   do
     salt=$(date +%S) # %S for 'only seconds'
     rnd=$[($(($RANDOM+$salt)) % ${#links[@]} )] # random number between 0 and amount of links
						 # incl. 0 since array starts with 0
     #echo "nr: $ci = ${links[$rnd]}" 
     echo "${links[$rnd]}" >> $destination
   done
fi


