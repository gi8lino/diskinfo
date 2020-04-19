# diskinfo

## description

Show diskinfo (`df -h`) with a progressbar for disk usage.  
The progressbar will be round up or down the progress to the next 5 percent. The disk usage in percent next to the progressbar will not be rounded.  
If the screen resolution ist less than 80, the progressbar width will be set to 10!

### optional parameters:
* `-e|--excluded-types` - types of filesystem to hide. List of strings, separatet by a space. example: `-e "shm overlay tmpfs devtmpfs"`
* `-b|--bar-length` - length of the progressbar. default: 20. Example: [#######-------------] 33%
* `-s|--sort` - ascending sort by column (default: mounted). possible values: mounted|size|used|free|usage|filesystem
* `-r|--reverse` - sort columns descending
* `-h|--help` - display help and exit
* `-v|--version` - output version information and exit

\* *abbreviation:*  
   *mounted: m*  
   *size: s*  
   *used: ud*  
   *free: f*  
   *usage: ug*  
   *filesystem: fs*

## usage

`diskinfo.sh [-e|--excluded-types "TYPE ..."] [-b|--bar-length INT] | [-s|--sort mounted|size|used|free|usage|filesystem] | [-r|--reverse] | [-h|--help] | [-v|--version]`

## alias

for easier use add following alias:  
open bash: `vi ~/.bashrc`  
set command:

```bash
alias di="echo -e 'alias for \033[0;35m/opt/diskinfo/diskinfo.sh -e \"shm overlay tmpfs devtmpfs\" \033[0m' && /opt/diskinfo/diskinfo.sh -e \"shm overlay tmpfs devtmpfs\""
```

reload bash: `. ~/.bashrc`

type in console: `di`  
result:  

```text
mounted on↑                size   used    free    usage                         filesystem
/                          20G    1.8G     19G    [##------------------]  9%    /dev/mapper/centos-root
/boot                    1014M    198M    817M    [####----------------] 20%    /dev/sdd2
/boot/efi                 200M    9.8M    191M    [#-------------------]  5%    /dev/sdd1
/home                      10G     53M     10G    [--------------------]  1%    /dev/mapper/centos-home
/mnt/hd01                 1.5T      1T    500G    [#############-------] 66%    /dev/sda1
```
