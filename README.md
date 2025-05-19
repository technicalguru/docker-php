# docker-php
This is my private PHP base image in order to be up-to-date with latest Apache AND PHP versions. The image includes many PHP extensions enabled
by default so most PHP applications can run without much tweaks. Check the [Dockerfile](Dockerfile) to see the list of PHP extensions.

# Breaking Change with PHP 8.4.x
The extension mcrypt is not supported anymore with PHP 8.4. New PHP code should be written to use libsodium rather than mcrypt. 
The libsodium extension is installed by default on PHP 7.2+

# Docker Name
The Dockerhub image name is `technicalguru/php`

# Current Releases / Tags
* 8.4.7-apache-2.4.62.0
* 8.3.21-apache-2.4.62.0

# Unsupported PHP versions
* 8.2.28-apache-2.4.62.0
* 8.1.32-apache-2.4.62.0
* 7.4.32-apache-2.4.54.0

# Enabled PHP Modules
* Core
* ctype
* curl
* date
* dom
* exif
* fileinfo
* filter
* ftp
* gd
* hash
* iconv
* imagick
* imap
* intl
* json
* libxml
* mbstring
* mysqli
* mysqlnd
* openssl
* pcre
* PDO
* pdo_mysql
* pdo_sqlite
* Phar
* posix
* random
* readline
* Reflection
* session
* SimpleXML
* sodium
* SPL
* sqlite3
* standard
* tokenizer
* xml
* xmlreader
* xmlwriter
* zip
* zlib

# Modfied INI settings (varying from default)
```
expose_php=Off
display_errors=Off
```

# License
All scripts are either taken from PHP original Docker image and adapted to work with the latest Apache or created on my own. However, the main
credit goes to PHP and its prior work. The [PHP LICENSE](PHP_LICENSE.txt) is distributed here.

# Disclaimer
The decision to publish my base image was taken in July 2021. That's why the documentation is currently missing or incomplete. 


