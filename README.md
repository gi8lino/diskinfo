## description
Show diskinfo (df -h) with a progressbar for disk usage. You can exclude any filesystem type you want by setting the parameter <br>
'-e|--excluded-types', following a list of filesystem types. Set the list between quotes. The progressbar will round up or down the progress to the next 5 percent.<br>
The actual disk usage next to the progressbar will not be rounded.<br>

### optional parameters:
* `-e, --excluded-types` - types of filesystem to hide. List of strings, separatet by a space. example: `-e "shm overlay tmpfs devtmpfs"`
* `-b, --bar-length` - length of the progressbar. default: 20. Example: [#######-------------] 33%
* `-h, --help` - display help and exit
* `-s, --sort` - sort by column. default:  'mounted'. possible values: mounted|size|used|free|usage|filesystem
* `-r, --reverse` - reverse sort columns
* `-v, --version` - output version information and exit

*abbreviation:<br>
 mounted: m, size: s, used: d, free: f, usage: u, filesystem: f

## usage
`diskinfo.sh [-e|--excluded-types "TYPE ..."] [-b|--bar-length INT] | [-s|--sort mounted|size|used|free|usage|filesystem ] | [-r|--reverse] | [-h|--help] | [-v|--version]`

## alias
for easier use add following alias:<br>
open bash: `vi ~/.bashrc`<br>
set command: `alias di="echo -e 'alias for \033[0;35m/opt/diskinfo/diskinfo.sh -e \"shm overlay tmpfs devtmpfs\" \033[0m' && /opt/diskinfo/diskinfo.sh -e \"shm overlay tmpfs devtmpfs\""
`<br>
reload bash: `. ~/.bashrc`

type in console: `di`<br>
result:<br>
```
mounted on                size    used    free    usage                         filesystem
/                          20G    1.8G     19G    [##------------------]  9%    /dev/mapper/centos-root
/boot                    1014M    198M    817M    [####----------------] 20%    /dev/sdd2
/boot/efi                 200M    9.8M    191M    [#-------------------]  5%    /dev/sdd1
/mnt/hd01                 1.5T      1T    500G    [#############-------] 66%    /dev/sda1
/home                      10G     53M     10G    [--------------------]  1%    /dev/mapper/centos-home
```


