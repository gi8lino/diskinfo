#!/bin/sh

VERSION="1.04"

shopt -s nocasematch  # set string compare to not case senstive

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
        -v|--version)
        SHOWVERSION=TRUE
        shift # past argument
        ;;
        -?|-h|--help)
        HELP=TRUE
        shift # past argument
        ;;
        *)    # unknown option
        shift # past argument
        ;;
      esac  # end case
done

function ShowUsage {
    _percent=$1
    _barlength=$2
  
    (( _rounded = (${_percent}+2)/5, _rounded *= 5))  # round to the next five percent
    let _used=(_barlength*_rounded/100)  # used in relation to bar length
    let _free=(_barlength-_used)  # rest
    
    # build progressbar string lengths
    _fill=$(printf "%${_used}s")
    _empty=$(printf "%${_free}s")

    printf "[${_fill// /#}${_empty// /-}]"  # show progressbar: [########------------]
}

if [ ${HELP} ];then
    printf "%s\n" "usage: $(basename $BASH_SOURCE) [PARAMETERS]
show diskinfo (df -h) with a progressbar for disk usage. you can
exclude any filesystem type you want by setting the param -e|--excluded-types
following a list of filesystem types. set the list between quotes.
the progressbar will round up or down the progress to the next 5 percent. 
the actual disk usage next to the progressbar will not be rounded.

optional parameters:
-e, --excluded-types    types of filesystem to hide 
                        list of strings, separatet by a space (not case sensitive)
                        example: -e \"shm overlay tmpfs devtmpfs\"
-b, --bar-length        length of progressbar
                        default: 20
                        example: $(ShowUsage $(( ( RANDOM % 100 )  + 1 )) 20)
-h, --help              show this dialog
-v, --version           show version
                    
created by gi8lino (2018)
"
    exit 0
fi

if [ ${SHOWVERSION} ];then
    printf "$(basename $BASH_SOURCE) version: %s\n" "${VERSION}"
    exit 0
fi

[[ ! ${BARLENGTH} =~ ^[0-9]+$ ]] && BARLENGTH=20  # if barlength value is not a number, set barlength to 20

printf "%-22s%8s%8s%8s%4s%-${BARLENGTH}s%10s%-s\n" "mounted on" "size" "used" "free" "" "usage" "" "filesystem"  # title

skip=true  # to skip first line (header)
# output disk usage
while IFS=' ', read -a input; do
    filesystem="${input[0]}"
    size="${input[1]}"
    used="${input[2]}"
    avail="${input[3]}"
    use="${input[4]}"
    mounted="${input[5]}"

    [ ${skip} == true ] && skip=false && continue  # skip first line (header)

    # check if filesystem is in unwanted list
    if [[ ! " ${EXCLUDES[@]} " =~ " ${filesystem} " ]];then
        printf "%-22s%8s%8s%8s%4s%-${BARLENGTH}s%3s%4s%-s\n" ${mounted} ${size} ${used} ${avail} "" "$(ShowUsage ${use::-1} ${BARLENGTH}) " ${use} "" ${filesystem}
    fi
    
done <<< "$(df -h)"

exit 0
