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
    (( _rounded = ($1+2)/5, _rounded *= 5))  # round to the next five percent 
    let _bar_width=$2
    let _done=(${_bar_width}*${_rounded}/100)
    let _progress=${_rounded}
    let _left=${_bar_width}-${_done}
    # build progressbar string lengths
    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")

    # build progressbar strings and print the progressbar line
    # output example:                           
    # [##########-----] 73%
    printf "[${_fill// /#}${_empty// /-}]"
}

if [ ${HELP} ]; then
printf "%s"  "Usage: diskinfo [PARAMETERS]
show diskinfo (df -h) with a progressbar for disk usage. you can
exclude any filesystem type you want by setting the param -e|--excluded-types
following a list of filesystem types. set the list between quotes.
the progressbar will round up or down the progress to the next 5 percent. 
the actual diskusage next to the progressbar will not be rounded.

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

# check param exclude
if [ "${EXCLUDES}" ]; then
    unwanted=${EXCLUDES}
fi


# check if param was sat and is a number
re='^[0-9]+$'
if [ !  "${BARLENGTH}" ] || [[ ! ${BARLENGTH} =~ $re ]]; then
    BARLENGTH=20
fi

shopt -s nocasematch  # set string compare to not case senstive

# output title
SPACES=4
BARWIDTH=$((BARLENGTH + SPACES))

printf "%-22s%8s%8s%8s%4s%-${BARWIDTH}s%7s%-s\n" "mounted on" "size" "used" "free" "" "usage" "" "filesystem"

skip=true
# output disk usage
while IFS=' ', read -r -a input; do
    filesystem="${input[0]}"
    size="${input[1]}"
    used="${input[2]}"
    avail="${input[3]}"
    use="${input[4]}"
    mounted="${input[5]}"

    # skip first line 
    if [ ${skip} == true ];then
        skip=false
        continue
    fi

    # check if filesystem is in unwanted list
    if  [[ ! " ${unwanted[@]} " =~ " ${filesystem} " ]];then
        printf "%-22s%8s%8s%8s%4s%-${BARWIDTH}s%3s%4s%-s\n" ${mounted} ${size} ${used} ${avail} " " "$(ShowUsage ${use::-1} ${BARLENGTH})" ${use} "" ${filesystem}
    fi

done <<< "$(df -h)"


