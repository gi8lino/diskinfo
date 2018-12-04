## description
show diskinfo.sh (`df -h`) with a progressbar for disk usage. you can exclude any filesystem type you want by setting the param `-e|--excluded-types` following a list of filesystem types. set the list between quotes.<br>
the progressbar will round up or down the progress to the next 5 percent.<br>
the actual disk usage next to the progressbar will not be rounded.


## optional parameters
* `-e, --excluded-types` - types of filesystem to hide. list of strings, separatet by a space. example: `-e "shm overlay tmpfs devtmpfs"`
* `-b, --bar-length` - length of the progressbar. default: 120. example: [######---------] 40%
* `-h, --help` - show help dialog
* `-v, --version` - show version


## alias
for easier use add following alias:<br>
open bash: `vi ~/.bashrc`<br>
set command: `alias di="/opt/diskinfo/diskinfo.sh -e 'shm overlay tmpfs devtmpfs'"`<br>
reload bash: `. ~/.bashrc`

type di
result:<br>
mounted on                size    used    free    usage                         filesystem
/                          20G    1.8G     19G    [##------------------]  9%    /dev/mapper/centos-root
/boot                    1014M    198M    817M    [####----------------] 20%    /dev/sdd2
/boot/efi                 200M    9.8M    191M    [#-------------------]  5%    /dev/sdd1
/mnt/hd01                 1.5T      1T    500G    [#######-------------] 33%    /dev/sda1
/home                      10G     53M     10G    [--------------------]  1%    /dev/mapper/centos-home

