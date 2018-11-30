show diskinfo (df -h) with a progressbar for disk usage. you can
exclude any filesystem types you want by setting the param -e|--excluded-types

## optional parameters
* `-e, --excluded-types`    types of filesystem to hide<br>
                            list of strings, separatet by a space<br>
                            example: -e "shm overlay tmpfs devtmpfs"<br>
* `-b, --bar-length`        length of progressbar<br>
                            default: 15<br>
                            example: [######---------] 40%<br>

## alias
for easier use add following alias:<br>
open bash:<br>
`vi ~/.bashrc`<br>
set command:<br>
`alias di="/opt/diskinfo/diskinfo.sh -e 'shm overlay tmpfs devtmpfs'"`<br>
reload bash:<br>
. ~/.bashrc