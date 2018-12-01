#!/bin/bash

# read start parameter
while [[ $# -gt 0 ]];do
         key="$1"
         case $key in
        -e|--excluded-types)
        EXCLUDES="$2"
        shift # past argument
        shift # past value
        ;;
        -b|--bar-length)
        BARLENGTH="$2"
        shift # past argument
        shift # past value
        ;;
        -?|--help)
        HELP=TRUE
        shift # past argument
        ;;
        *)    # unknown option
        shift # past argument
        ;;
        esac
done

function ShowUsage {
# param 1: procent
# param 2: bar length

    # process data
    let _bar_width=$2
    let _done=(${_bar_width}*${1}/100)
    let _progress=$1
    let _left=${_bar_width}-${_done}
    # build progressbar string lengths
    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")

    # build progressbar strings and print the progressbar line
    # output example:                           
    # [--------------------] 2%
    printf "[${_fill// /#}${_empty// /-}]"
    #printf "[${_fill// /#}${_empty// /-}] ${_progress}%%"
}

if [ ${HELP} ]; then
printf "%s"  "
Usage: diskinfo [PARAMETERS]
show diskinfo (df -h) with a progressbar for disk usage. you can
exclude any filesystem types you want by setting the param -e|--excluded-types

optional parameters:
-e, --excluded-types    types of filesystem to hide 
                        list of strings, separatet by a space (not case sensitive)
                        example: -e \"shm overlay tmpfs devtmpfs\"
-b, --bar-length        length of progressbar
                        default: 20
                        example: "$(ShowUsage $(( ( RANDOM % 100 )  + 1 )) 20)" 
                    
created by gi8lino (2018)

"
    exit 0
fi

# load config
if [ "${EXCLUDES}" ]; then
    #read -a unwanted <<< ${EXCLUDES}
    unwanted=${EXCLUDES}
fi

if [ "${BARLENGTH}" ]; then
    re='^[0-9]+$'
    if ! [[ ${BARLENGTH} =~ $re ]] ; then
        printf "bar length is not a number. set progressbar length to default (20)!"
    fi
else
    # size of progress bars
    BARLENGTH=20
fi

shopt -s nocasematch  # set string compare to not case senstive

# output title
SPACES=4
BARWIDTH=$((BARLENGTH + SPACES))

#printf "%-22s%8s%8s%8s%4s%-${BARWIDTH}s%2s%-s\n" "mounted on" "size" "used" "free" " " "usage" " " "filesystem"
printf "%-22s%8s%8s%8s%4s%-${BARWIDTH}s%7s%-s\n" "mounted on" "size" "used" "free" "" "usage" "" "filesystem"

# output disk usage
while IFS=' ', read -r -a input; do
    filesystem="${input[0]}"
    size="${input[1]}"
    used="${input[2]}"
    avail="${input[3]}"
    use="${input[4]}"
    mounted="${input[5]}"
 
    if [[ ! " ${unwanted[@]} " =~ " ${filesystem} " ]] && [ ${filesystem} != "Filesystem" ]; then
        printf "%-22s%8s%8s%8s%4s%-${BARWIDTH}s%3s%4s%-s\n" ${mounted} ${size} ${used} ${avail} " " "$(ShowUsage ${use::-1} ${BARLENGTH})" ${use} "" ${filesystem}
    fi

done <<< "$(df -h)"


