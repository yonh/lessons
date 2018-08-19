# 创建CentOS本地镜像源

课程笔记及源码: https://github.com/yonh/lessons/tree/master/centos_mirror

这里搭建 CentOS 7 的镜像源，其他版本类似

### 步骤如下

1. 同步(下载)官方镜像源文件
   1. 到哪里下载
   2. 用什么工具
   3. 要下什么东西
2. 搭建本地镜像源的http服务
   1. nginx
3. 配置虚拟机的yum源地址为本地源
4. 测试安装







#### 操作环境

使用docker启动2个容器(`centos7`)，一个用于搭建镜像源，一个用于测试

当然你也可以使用虚拟机，但docker比较快捷



官方镜像源地址

```
## 官方源
https://www.centos.org/download/mirrors/
## EPEL源
https://admin.fedoraproject.org/mirrormanager/mirrors/EPEL/7

```





# 1.同步(下载)官方镜像源文件

怎么同步，到哪里同步  (官方提供的源，国内大厂，学校提供的源)

#### 同步什么内容

二进制文件，GPGKey

`os, extras, updates, epel`

#### 怎么知道同步什么内容

看yum配置文件`/etc/yum.repos.d/CentOS-Base.repo`,`/etc/yum.repos.d/epel.repo`

默认epel源是不存在的，你需要`yum install epel-release`



#### 镜像源同步脚本

安装rsync  `yum install -y rsync`

```bash
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
```



## 2. 搭建本地镜像源的http服务

```
yum install -y nginx
```

打开nginx的文件目录索引的一个功能, /etc/nginx/nginx.conf

```
...
server {
		autoindex on;
...
```





## 3.配置虚拟机的镜像源地址为本地源

编辑 /etc/yum.repos.d/CentOS-Base.repo

```
[base]
name=CentOS-$releasever - Base
baseurl=http://172.17.0.4/centos/$releasever/os/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[updates]
name=CentOS-$releasever - Updates
baseurl=http://172.17.0.4/centos/$releasever/updates/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-$releasever - Extras
baseurl=http://172.17.0.4/centos/$releasever/extras/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[centosplus]
name=CentOS-$releasever - Plus
baseurl=http://172.17.0.4/centos/$releasever/centosplus/$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[epel]
name=Extra Packages for Enterprise Linux 7 - $basearch
baseurl=http://172.17.0.4/pub/epel/7/$basearch
failovermethod=priority
enabled=1
gpgcheck=1
#gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
gpgkey=http://172.17.0.4/epel/RPM-GPG-KEY-EPEL-7
```











## 附录

# 什么是GPG-Key在Yum源的作用

**一句话说明就是: 校验包是否是官方的,没有被修改过**

GPG在Linux上的应用主要是实现官方发布的包的签名机制。
GPG分为公钥及私钥。
公钥：顾名思意，即可共享的密钥，主要用于验证私钥加密的数据及签名要发送给私钥方的数据。
私钥：由本地保留的密钥，用于签名本地数据及验证用公钥签名的数据。
实现原理(以Red Hat签名为例)：
1>RH在发布其官方的RPM包时（如本地RHEL光盘及FTP空间包），会提供一个GPG密钥文件，即所谓的公钥。
2>用户下载安装这个RPM包时，引入RH官方的这个RPM GPG公钥，用来验证RPM包是不是RH官方签名的。
导入GPG-KEY:
可以去https://www.redhat.com/security/team/key/或/etc/pki/rpm-gpg查找相应的GPG密钥，并导入到RPM:
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY
签名及加密概念：
签名与加密不是一个概念。
签名类似于校验码，用于识别软件包是不是被修改过，最常用的的就是我们的GPG及MD5签名，原方使用一定的字符（MD5)或密码(GPG私钥）与软件进行相应的运算并得到一个定长的密钥，。
加密是用一定的密钥对原数据进行修改，即使程序在传输中被截获，只要它不能解开密码，就不能对程序进行修改，除非破坏掉文件，那样我们就知道软件被修改过了。
RPM验证方法：
1>验证安装的整个软件包的文件
rpm -V crontabs-1.10-8
2>验证软件包中的单个文件
rpm -Vf /etc/crontab
如果文件没有被修改过，则不输出任何信息。
3>验证整个软件包是否被修改过
rpm -Vp AdobeReader_chs-7.0.9-1.i386.rpm 
.......T   /usr/local/Adobe/Acrobat7.0/Reader/GlobalPrefs/reader_prefs
S.5....T   /usr/local/Adobe/Acrobat7.0/bin/acroread
4>验证签名
rpm -K AdobeReader_chs-7.0.9-1.i386.rpm
AdobeReader_chs-7.0.9-1.i386.rpm: sha1 md5 OK
验证结果含意：
S ：file Size differs
M ：Mode differs (includes permissions and file type)
5 ：MD5 sum differs
D ：Device major/minor number mis-match
L ：readLink(2) path mis-match
U ：User ownership differs
G ：Group ownership differs
T ：mTime differs



