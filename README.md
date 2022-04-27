# docker-php
This is my private PHP base image in order to be up-to-date with latest Apache AND PHP versions. The image includes many PHP extensions enabled
by default so most PHP applications can run without much tweaks. Check the [Dockerfile](Dockerfile) to see the list of PHP extensions.

# Docker Name
The Dockerhub image name is `technicalguru/rs-php`

# Releases / Tags
* 8.1.5-apache-2.4.53.0
* 7.4.28-apache-2.4.53.1
* 7.4.28-apache-2.4.52.0
* 7.4.24-apache-2.4.48.1
* 7.4.19-apache-2.4.38.2

# Enabled PHP Modules
Core
ctype
curl
date
dom
exif
fileinfo
filter
ftp
gd
hash
iconv
imagick
imap
intl
json
libxml
mbstring
mcrypt
mysqli
mysqlnd
openssl
pcre
PDO
pdo_mysql
pdo_sqlite
Phar
posix
readline
Reflection
session
SimpleXML
SPL
sqlite3
standard
tokenizer
xml
xmlreader
xmlwriter
zip
zlib

# License
All scripts are either taken from PHP original Docker image and adapted to work with the latest Apache or created on my own. However, the main
credit goes to PHP and its prior work. The [PHP LICENSE](PHP_LICENSE.txt) is distributed here.

# Disclaimer
The decision to publish my base image was taken in July 2021. That's why the documentation is currently missing or incomplete. 


