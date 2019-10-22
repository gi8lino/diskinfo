#!/bin/sh

VERSION="2.0"

function ShowUsage {
    local _percent=$1
    local _barlength=$2
  
    ((_rounded = (${_percent}+2)/5, _rounded *= 5))  # round to the next five percent
    let _used=(_barlength*_rounded/100)  # used in relation to bar length
    let _free=(_barlength-_used)  # rest
    
    # progressbar string lengths
    local _fill=$(printf "%${_used}s")
    local _empty=$(printf "%${_free}s")

    printf "[${_fill// /#}${_empty// /-}]"  # show progressbar: [########------------]
}

function ShowHelp {
    printf "%s\n" \
	       "Usage: $(basename $BASH_SOURCE) [-e|--excluded-types \"TYPE ...\"] [-b|--bar-length INT]] | [-s|--sort mounted|size|used|free|usage|filesystem] | [-r|--reverse] | [-h|--help] | [-v|--version]" \
	       "" \
	           "Show diskinfo (df -h) with a progressbar for disk usage. You can" \
	       "exclude any filesystem type you want by setting the parameter" \
	       "'-e|--excluded-types', following a list of filesystem types. " \
	       "You have to set the list between quotes." \
	       "The progressbar will round up/down the progress to the next 5 percent." \
	       "The disk usage in percent next to the progressbar will not be rounded." \
	       "" \
	       "Optional Parameters:" \
	       "-e, --excluded-types \"[Type] ...\"   types of filesystem to hide" \
	       "                                    list of strings, separatet by a space (not case sensitive)" \
	       "                                    example: -e \"shm overlay tmpfs devtmpfs\"" \
	       "-b, --bar-length [INT]              length of progressbar (default: 20)" \
	       "                                    example: -b 30" \
	       "                                    result: $(ShowUsage $(( ( RANDOM % 100 ) + 1 )) 30)" \
	       "-s, --sort                          ascending sort by column (default: mounted)" \
	       "                                    possible values: mounted|size|used|free|usage|filesystem *" \
	       "                                    example: -s mounted" \
	       "-r, --reverse                       sort columns descending" \
	       "-h, --help                          display this help and exit" \
	       "-v, --version                       output version information and exit" \
	       "" \
	       "*abbreviation:" \
	       " mounted: m, size: s, used: ud, free: f, usage: ug, filesystem: fs" \
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
unset IFS

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

[[ ! ${BARLENGTH} =~ ^[0-9]+$ ]] && BARLENGTH=20  # if barlength value is not set or not a number, set barlength to 20

if [ -z "${REVERSE}" ]; then
    SORT_DIRECTION="↑"
else    
    SORT_DIRECTION="↓"
fi

diskinfo=()
MOUNTED_LEN=0
# output disk usage
while IFS=' ', read -a input; do
    filesystem="${input[0]}"
    size="${input[1]}"
    used="${input[2]}"
    avail="${input[3]}"
    use="${input[4]}"
    mounted="${input[5]}"

    # check if filesystem is in excluded list
    if [[ ! " ${EXCLUDES[@]} " =~ " ${filesystem} " ]];then
        diskinfo+=( "${mounted} ${size} ${used} ${avail} $(ShowUsage ${use::-1} ${BARLENGTH}) ${use} ${filesystem}" )
        [[ ${#mounted} -gt  $MOUNTED_LEN ]] && MOUNTED_LEN=${#mounted}
    fi

done <<< "$(df -h | tail -n +2)"  # tail for skipping header

# default width
MOUNTED_WIDTH=22
SIZE_WIDTH=8
USED_WIDTH=8
FREE_WIDTH=8
USAGE_WIDTH=9
PERCENT_WIDTH=5

# initalize variables
SORTED_MOUNTED_WIDTH=0
SORTED_SIZE_WIDTH=0
SORTED_USED_WIDTH=0
SORTED_FREE_WIDTH=0
SORTED_USAGE_WIDTH=0

# correct width and set direction symbol
if [ -n "${SORTKEY=free}" ]; then
    case $SORTKEY in
        mounted|m)
        SORTED_BY=1
        SORTED_MOUNTED_WIDTH=2
        MOUNTED_SORT="$SORT_DIRECTION"
        ;;
        size|s)
        SORTED_BY="2 -h"
        SORTED_SIZE_WIDTH=2
        SIZE_SORT="$SORT_DIRECTION"
        ;;
        used|ud)
        SORTED_BY="3 -h"
        SORTED_USED_WIDTH=2
        USED_SORT="$SORT_DIRECTION"
        ;;
        free|f)
        SORTED_BY="4 -h"
        SORTED_FREE_WIDTH=3
        FREE_SORT="$SORT_DIRECTION"
        ;;
        usage|ug)
        SORTED_BY="6 -h"
	    SORTED_USAGE_WIDTH=3
        USAGE_SORT="$SORT_DIRECTION"
        ;;
        filesystem|fs)
        SORTED_BY=8
        FS_SORT="$SORT_DIRECTION"
        ;;
        *)
        SORT_ERR=true
        printf "sort key '$SORTKEY' does not exists!\n"
        ;;
    esac
    readarray diskinfo <<< $(printf '%s\n' "${diskinfo[@]}" | sort -k$SORTED_BY $REVERSE)
fi

# print title
printf "%-$(( ${MOUNTED_LEN} + ${SORTED_MOUNTED_WIDTH} ))s%$(( ${SIZE_WIDTH} + ${SORTED_SIZE_WIDTH} ))s%$(( ${USED_WIDTH} + ${SORTED_USED_WIDTH} ))s%$(( ${FREE_WIDTH} + ${SORTED_FREE_WIDTH} ))s%$(( ${USAGE_WIDTH} + ${SORTED_USAGE_WIDTH} ))s%$(( ${BARLENGTH} - 3 ))s%${PERCENT_WIDTH}s%4s%s \n" "mounted on${MOUNTED_SORT}" "size${SIZE_SORT}" "used${USED_SORT}" "free${FREE_SORT}" "usage${USAGE_SORT}" "" "" "" "filesystem${FS_SORT}"

# print disk information
for line in "${diskinfo[@]}";do
    IFS=' ' read -r -a info <<< "${line}"
    
    mounted="${info[0]}"
    size="${info[1]}"
    used="${info[2]}"
    free="${info[3]}"
    bar="${info[4]}"
    percent="${info[5]}"
    filesystem="${info[6]}"

    printf "%-${MOUNTED_LEN}s%${SIZE_WIDTH}s%${USED_WIDTH}s%${FREE_WIDTH}s%$(( ${BARLENGTH} + ${USAGE_WIDTH} - 3 ))s%${PERCENT_WIDTH}s%4s%s \n"  ${mounted} ${size} ${used} ${free} ${bar} ${percent} "" ${filesystem}

done

exit 0
