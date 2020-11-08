#!/bin/bash

VERSION="v1.0.9"

ShowUsage() {
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

ShowHelp() {
    printf "
Usage: diskinfo.sh [-e|--exclude-types \"TYPE ...\"]
                   [-b|--bar-length INT]
                   [-s|--sort mounted|size|used|free|usage|filesystem]
                   [-r|--reverse]
                   | [-h|--help]
                   | [-v|--version]

Show diskinfo (df -h) with a progressbar for disk usage.
The progressbar will round up/down the progress to the next 5 percent.
The disk usage in percent next to the progressbar will not be rounded.
If the screen resolution ist less than 80, the progressbar width will be set to 10!

Optional Parameters:
-e, --exclude-types \"[Type] ...\"    types of filesystem to hide
                                    list of strings, separatet by a space (not case sensitive)
                                    can contain wildcards (*)
                                    example: -e \"shm overlay tmpfs devtmpfs /dev/loop*\"
-b, --bar-length [INT]              length of progressbar (default: 20)
                                    example: -b 30
                                    result: $(ShowUsage $(( ( RANDOM % 100 ) + 1 )) 30)
-s, --sort                          ascending sort by column (default: mounted)
                                    possible values: mounted|size|used|free|usage|filesystem *
                                    example: -s mounted
-r, --reverse                       sort columns descending
-h, --help                          display this help and exit
-v, --version                       output version information and exit

*\e[3mabbreviations:
 - mounted: m
 - size: s
 - used: ud
 - free: f
 - usage: ug
 - filesystem: fs
\e[0m
created by gi8lino (2020)
https://github.com/gi8lino/diskinfo.git\n\n"
    exit 0
}

unset IFS

# read start parameter
while [ $# -gt 0 ]; do
    key="$1"
    case $key in
        -e|--exclude-types)
        EXCLUDES="$2"
        shift
        shift
        ;;
        -b|--bar-length)
        BARLENGTH="$2"
        shift
        shift
        ;;
        -s|--sort)
        SORTKEY="$2"
        shift
        shift
        ;;
        -r|--reverse)
        REVERSE="-r"
        shift
        ;;
        -v|--version)
        printf "$(basename $BASH_SOURCE) version: %s\n" "${VERSION}"
        exit 0
        ;;
        -h|--help)
        ShowHelp
        ;;
        *)  # unknown option
        printf "%s\n" \
           "$(basename $BASH_SOURCE): invalid option -- '$1'" \
           "Try '$(basename $BASH_SOURCE) --help' for more information."
        exit 1
        ;;
    esac
done

[ -z "${BARLENGTH##*[!0-9]*}" ] && BARLENGTH=20  # if barlength value is not set or not a number, set barlength to 20

[ -x "$(command -v tput)" ] && \
    [ $(tput cols) -le 80 ] && \
    BARLENGTH=10  # If the screen resolution ist less than 80, the progressbar width will be set to 10!


[ -z "${REVERSE}" ] && \
    SORT_DIRECTION="↑" || \
    SORT_DIRECTION="↓"

declare -a diskinfo
MOUNTED_LEN=15

# collect disk usage
while IFS=' ', read -ra input; do
    filesystem="${input[0]}"
    size="${input[1]}"
    used="${input[2]}"
    avail="${input[3]}"
    use="${input[4]%\%}"  # strip %
    mounted="${input[5]}"

    for entry in $EXCLUDES; do
        [[ " $filesystem " =~ ${entry} ]] && \
            exclude=true && \
            break
    done
    if [ ! -n "$exclude" ]; then
        diskinfo+=( "${mounted} ${size} ${used} ${avail} $(ShowUsage ${use} ${BARLENGTH}) ${use} "\%" ${filesystem}" )
        current_mounted_len=${#mounted}
        [[ ${current_mounted_len} -gt  $MOUNTED_LEN ]] && \
            MOUNTED_LEN=${current_mounted_len}
    fi
    unset exclude
done <<< "$(df -h | tail -n +2)"  # tail for skipping header

# default column width
SIZE_WIDTH=8
USED_WIDTH=8
FREE_WIDTH=8
USAGE_WIDTH=9
PERCENT_WIDTH=5

# initalize variables for adjustment of header space distance
sort_mounted_correction=0
sort_size_correction=0
sort_used_correction=0
sort_free_correction=0
sort_usage_correction=0
sort_filesystem_correction=0

# set header space distance and set direction symbol
if [ -n "${SORTKEY}" ]; then
    case $SORTKEY in
        mounted|m)
        SORTED_BY="1"
        sort_mounted_correction=2
        MOUNTED_SORT="$SORT_DIRECTION"
        ;;
        size|s)
        SORTED_BY="2 -h"
        sort_size_correction=3
        sort_used_correction=-1
        SIZE_SORT="$SORT_DIRECTION"
        ;;
        used|ud)
        SORTED_BY="3 -h"
        sort_used_correction=3
        sort_free_correction=-1
        USED_SORT="$SORT_DIRECTION"
        ;;
        free|f)
        SORTED_BY="4 -h"
        sort_free_correction=3
        sort_usage_correction=-1
        FREE_SORT="$SORT_DIRECTION"
        ;;
        usage|ug)
        SORTED_BY="6 -h"
        sort_usage_correction=3
        sort_filesystem_correction=2
        USAGE_SORT="$SORT_DIRECTION"
        ;;
        filesystem|fs)
        SORTED_BY="7"
        FS_SORT="$SORT_DIRECTION"
        ;;
        *)
        SORT_ERR=true
        printf "sort key '$SORTKEY' does not exists!\n\n"
        ShowHelp
        ;;
    esac
    IFS=' '
    readarray diskinfo <<< $(printf '%s\n' "${diskinfo[@]}" | sort -k$SORTED_BY $REVERSE)  # sort array according sort selection
fi

# print title
format="\
%-$(( ${MOUNTED_LEN} + ${sort_mounted_correction} ))s\
%$(( ${SIZE_WIDTH} + ${sort_size_correction} ))s\
%$(( ${USED_WIDTH} + ${sort_used_correction} ))s\
%$(( ${FREE_WIDTH} + ${sort_free_correction} ))s\
%$(( ${USAGE_WIDTH} + ${sort_usage_correction} ))s\
%$(( ${BARLENGTH} + 16 ))s\
%$(( 3 + ${sort_filesystem_correction} ))s\
%s\n"

printf $format "mounted on${MOUNTED_SORT}" \
               "size${SIZE_SORT}" \
               "used${USED_SORT}" \
               "free${FREE_SORT}" \
               "usage${USAGE_SORT}" \
               "filesystem${FS_SORT}"

format="\
%-${MOUNTED_LEN}s\
%${SIZE_WIDTH}s\
%${USED_WIDTH}s\
%${FREE_WIDTH}s\
%$(( ${BARLENGTH} + ${USAGE_WIDTH} - 3 ))s\
%${PERCENT_WIDTH}s\
%-4s\
%s"

printf $format ${diskinfo[@]}

exit 0
