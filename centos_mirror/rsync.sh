#!/bin/bash
# 镜像源同步目录
mirror_dir="/usr/share/nginx/html"
# 同步源网址
src="mirrors.ustc.edu.cn"

cd $mirror_dir

mkdir -p centos/7/{os/x86_64,updates/x86_64,extras/x86_64}
mkdir -p epel/7/x86_64

# 同步源，保持和线上源一致
rsync -av --delete --exclude=LiveOS/ rsync://$src/centos/7/os/x86_64/ centos/7/os/x86_64/
rsync -av --delete rsync://$src/centos/7/extras/x86_64/ centos/7/extras/x86_64/
rsync -av --delete rsync://$src/centos/7/updates/x86_64/ centos/7/updates/x86_64/
#rsync -av --delete rsync://$src/centos/7/centosplus/x86_64/ centos/7/centosplus/x86_64/
rsync -av --delete rsync://$src/epel/7/x86_64/ epel/7/x86_64/
