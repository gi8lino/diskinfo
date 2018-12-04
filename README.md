## description
show diskinfo.sh (`df -h`) with a progressbar for disk usage. you can exclude any filesystem type you want by setting the param `-e|--excluded-types` following a list of filesystem types. set the list between quotes.<br>
the progressbar will round up or down the progress to the next 5 percent.<br>
the actual disk usage next to the progressbar will not be rounded.


## optional parameters
* `-e, --excluded-types` - types of filesystem to hide. list of strings, separatet by a space. example: `-e "shm overlay tmpfs devtmpfs"`
* `-b, --bar-length` - length of the progressbar. default: 15. example: [######---------] 40%

## alias
for easier use add following alias:<br>
open bash: `vi ~/.bashrc`<br>
set command: `alias di="/opt/diskinfo/diskinfo.sh -e 'shm overlay tmpfs devtmpfs'"`<br>
reload bash: `. ~/.bashrc`
