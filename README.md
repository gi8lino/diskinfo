show diskinfo (df -h) with a progressbar for disk usage. you can
exclude any filesystem types you want by setting the param -e|--excluded-types
## alias
`alias di="/opt/diskinfo/diskinfo.sh -e 'shm overlay tmpfs devtmpfs'"`