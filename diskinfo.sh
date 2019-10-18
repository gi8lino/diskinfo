#!/bin/sh

VERSION="2.0"

function ShowUsage {
    local _percent=$1
    local _barlength=$2
  
    (( _rounded = (${_percent}+2)/5, _rounded *= 5))  # round to the next five percent
    let _used=(_barlength*_rounded/100)  # used in relation to bar length
    let _free=(_barlength-_used)  # rest
    
    # progressbar string lengths
    local _fill=$(printf "%${_used}s")
    local _empty=$(printf "%${_free}s")

    printf "[${_fill// /#}${_empty// /-}]"  # show progressbar: [########------------]
}

function ShowHelp {
    printf "%s\n" \
	       "Usage: $(basename $BASH_SOURCE) [-e|--excluded-types \"TYPE ...\"] [-b|--bar-length INT]] | [-h|--help] | [-v|--version]" \
	       "" \
               "Show diskinfo (df -h) with a progressbar for disk usage. You can" \
	       "exclude any filesystem type you want by setting the parameter" \
	       "'-e|--excluded-types', following a list of filesystem types. " \
	       "You have to set the list between quotes." \
	       "The progressbar will round up/down the progress to the next 5 percent." \
	       "The actual disk usage next to the progressbar will not be rounded." \
	       "" \
	       "Optional Parameters:" \
	       "-e, --excluded-types \"[Type] ...\"   types of filesystem to hide" \
	       "                                    list of strings, separatet by a space (not case sensitive)" \
	       "                                    example: -e \"shm overlay tmpfs devtmpfs\"" \
	       "-b, --bar-length [INT]              length of progressbar (default: 20)" \
	       "                                    example: -b 30" \
	       "                                    result: $(ShowUsage $(( ( RANDOM % 100 )  + 1 )) 30)" \
	       "-s, --sort                          sort by this column. default:  'mounted on'" \
	       "-r, --reverse                       reverse sort columns " \
	       "-h, --help                          display this help and exit" \
	       "-v, --version                       output version information and exit" \
	       "" \
	       "created by gi8lino (2018)"
    exit 0
}

function ShowVersion {
    printf "$(basename $BASH_SOURCE) version: %s\n" "${VERSION}"
    exit 0
}

function ShowUnknownParam {
    printf "%s\n" \
	       "$(basename $BASH_SOURCE): invalid option -- '$1'" \
           "Try '$(basename $BASH_SOURCE) --help' for more information."
    exit 1
}

shopt -s nocasematch  # set string compare to not case senstive
# read start parameter
while [[ $# -gt 0 ]];do
    key="$1"
    case $key in
        -e|--excluded-types)
        EXCLUDES="$2"
        shift  # pass argument
        shift  # pass value
        ;;
        -b|--bar-length)
        BARLENGTH="$2"
        shift  # pass argument
        shift  # pass value
        ;;
        -s|--sort)
        SORTKEY="$2"
        shift  # pass argument
        shift  # pass value
        ;;
        -r|--reverse)
        REVERSE="-r"
        shift  # pass argument
        ;;
        -v|--version)
        ShowVersion
        ;;
        -h|--help)
        ShowHelp
        ;;
        *)  # unknown option
	    ShowUnknownParam "$1"
        ;;
    esac  # end case
done

KEY=1
case $SORTKEY in
    "mounted")
    KEY=1
    ;;
    "size")
    KEY=3
    ;;
    "used")
    KEY=4
    ;;
    "free")
    KEY=5
    ;;
    "usage")
    KEY=7
    ;;
    "filesystem")
    KEY=7
    ;;
    *)
    KEY=1
    printf "'$SORTKEY not found!"
    ShowHelp
    ;;
esac



[[ ! ${BARLENGTH} =~ ^[0-9]+$ ]] && BARLENGTH=20  # if barlength value is not set or not a number, set barlength to 20

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

    # check if filesystem is in excluded list
    if [[ ! " ${EXCLUDES[@]} " =~ " ${filesystem} " ]];then
        printf "%-22s%8s%8s%8s%4s%-${BARLENGTH}s%3s%4s%-s\n" ${mounted} ${size} ${used} ${avail} "" "$(ShowUsage ${use::-1} ${BARLENGTH}) " ${use} "" ${filesystem}
    fi
done <<< "$(df -h)" |
sort -n -k1 $REVERSE
exit 0
