#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#=================================================================#
#   System Required:  Ubuntu 12+                                  #
#   One click Install Apache+OpenSSL+Nghttp2                      #
#   Author: Baka-Network <contact@baka.network>                   #
#=================================================================#

clear
echo
echo "#############################################################"
echo "# One click Install Apache+OpenSSL+Nghttp2                  #"
echo "# Author: Baka-Network <contact@baka.network>               #"
echo "#############################################################"
echo

echo
echo "#############################################################"
echo "# NOTICE:                                                   #"
echo "# The script will install all the things in /opt/LAON       #"
echo "#############################################################"
echo

# Make sure only root can run our script
rootness(){
    if [[ $EUID -ne 0 ]]; then
        echo "Error:This script must be run as root!" 1>&2
        exit 1
    fi
}

# Disable selinux
disable_selinux(){
if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0
fi
}

pre_install(){
    # Set Apache Version
    echo "Please input the version of Apache:"
    read -p "(Default Version: 2.4.25 ):" apaversion
    [ -z "${apaversion}" ] && apaversion="2.4.25"
    # Set OpenSSL Version
    echo -e "Please input the version of OpenSSL [X_X_Xx eg:1_0_2j]:"
    read -p "(Default Version: 1.0.2j[1_0_2j,X_X_Xx eg:1_0_2j]):" oslversion
    [ -z "$oslversion" ] && oslversion="1_0_2j"
    # Set Nghttp2 Version
    echo -e "Please input the version of Nghttp2:"
    read -p "(Default Version: 1.19.0):" nh2version
    [ -z "$nh2version" ] && nh2version="1.19.0"
	# Set Node.js Version
    #echo "Please input the version of Node.js:"
    #read -p "(Default Version: stable [eg:stable,lts,6.6.0]):" nodeversion
    #[ -z "${nodeversion}" ] && nodeversion="stable"
	# Set HEXO Directory
    #[ -z "${hexopatch}" ] && hexopatch="/var/www/blog"
    get_char(){
        SAVEDSTTY=`stty -g`
        stty -echo
        stty cbreak
        dd if=/dev/tty bs=1 count=1 2> /dev/null
        stty -raw
        stty echo
        stty $SAVEDSTTY
    }
    echo
    echo "Press any key to start...or Press Ctrl+C to cancel"
    char=`get_char`
    #Install necessary dependencies
    apt-get update -y && apt-get install build-essential git unzip gcc make automake python autoconf libtool* -y
}

# Making File-Cache Dir
make_dir(){
    mkdir /opt/LAON
    mkdir /opt/LAON/tmp
    cd /opt/LAON/tmp
}

# Install Apr
install_apr(){
    echo "Installing Apr"
    cd /tmp/LAON
    wget --no-check-certificate https://github.com/apache/apr/archive/1.5.2.tar.gz
    tar -zxf 1.5.2.tar.gz
    rm 1.5.2.tar.gz
    mv apr-1.5.2 apr
    cd apr
    ./buildconf
    ./configure --prefix=/opt/LAON/apr
    make && make install
}

# Install Apr-Util
install_apr_util(){
    echo "Installing Apr-Util"
    cd .. && wget --no-check-certificate https://github.com/apache/apr-util/archive/1.5.4.tar.gz
    tar -zxf 1.5.4.tar.gz
    rm 1.5.4.tar.gz
    mv apr-util-1.5.4 apr-util
    cd apr-util
    ./buildconf
    ./configure --prefix=/opt/LAON/apr-util --with-apr=/opt/LAON/apr
    make && make install
}

# Install Zlib
install_zlib(){
    echo "Installing Zlib"
    cd .. && wget http://zlib.net/zlib-1.2.11.tar.gz
    tar -zxf zlib-1.2.11.tar.gz
    rm zlib-1.2.11.tar.gz
    cd zlib-1.2.11
    ./configure --prefix=/usr/local
    make && make install
}

# Install Pcre
install_pcre(){
    echo "Installing Pcre"
    cd .. && wget https://ftp.pcre.org/pub/pcre/pcre-8.40.tar.gz
    tar -zxf pcre-*.tar.gz
    rm pcre-*.tar.gz
    cd pcre-*
    ./configure --prefix=/opt/LAON/pcre
    make && make install
}

# Install OpenSSL
install_openssl(){
    echo "Installing OpenSSL"
    cd .. && wget --no-check-certificate https://github.com/openssl/openssl/archive/OpenSSL_${oslversion}.tar.gz
    tar -zxf OpenSSL*.tar.gz
    rm OpenSSL*.tar.gz
    mv *openssl* openssl
    cd openssl
    ./config --prefix=/opt/LAON/openssl enable-shared
    make && make install
}

# Install Nghttp2
install_nghttp2(){
    echo "Installing Nghttp2"
    cd .. && wget --no-check-certificate https://github.com/nghttp2/nghttp2/releases/download/v${nh2version}/nghttp2-${nh2version}.tar.gz
    tar -zxf nghttp2*.tar.gz
    rm nghttp2*.tar.gz
    cd nghttp2*
    ./configure --prefix=/opt/LAON/nghttp2
    make && make install
}

# Install Apache
install_apache(){
    echo "Installing Apache"
    cd .. && wget --no-check-certificate https://github.com/apache/httpd/archive/${apaversion}.tar.gz
    tar -zxf ${apaversion}.tar.gz
    rm ${apaversion}.tar.gz
    cd httpd*
    ln -s /opt/LAON/tmp/apr srclib/apr
    ln -s /opt/LAON/tmp/apr-util srclib/apr-util
    ./buildconf
    ./configure --prefix=/opt/LAON/httpd --enable-deflate --enable-expires --enable-headers --enable-modules=all --enable-so --enable-mpm --with-mpm=prefork --enable-rewrite --with-apr=/opt/LAON/apr --with-apr-util=/opt/LAON/apr-util --with-pcre=/opt/LAON/pcre/bin/pcre-config --enable-ssl --enable-rewrite --enable-http2 --with-nghttp2=/opt/LAON/nghttp2 --with-ssl=/opt/LAON/openssl --with-crypto
    make && make install
}

# Install HEXO
#install_hexo(){
    #npm install n -g
    #n ${nodeversion}
    #npm install hexo-cli -g
    #mkdir /var/www
    #mkdir /var/www/blog
    #hexo init ${hexopatch}
    #cd ${hexopatch}
    #npm install
#}

# Config
config(){
    echo "Configing"
    #chown www-root:www-root /var/www/blog/public -R
    #chmod 755 /var/www/blog/public -R
    cp /opt/LAON/openssl/lib/* /usr/lib/ -R -f
    cp /opt/LAON/httpd/bin/* /usr/bin/ -R -f
    cp /opt/LAON/nghttp2/lib/* /usr/lib/ -R -f
    
}

# Delete Downloaded File
delete_files(){
    echo "Deleting useless files"
    rm -rf /opt/LAON/tmp
    echo "Install Complete!"
}

# Install LAON
install_LAON(){
    rootness
    disable_selinux
    pre_install
    make_dir
    install_apr
    install_apr_util
    install_zlib
    install_pcre
    install_openssl
    install_nghttp2
    install_apache
    #install_hexo
    config
    delete_files
}

# Uninstall LAON
uninstall_LAON(){
    rm -rf /opt/LAON
	#cd ${hexopatch}
	#node uninstall
	#rm -rf ${hexopatch}
	#rm -rf /usr/local/n
	#rm /usr/bin/node
	rm /usr/bin/httpd
	rm /usr/bin/apachectl
	#apt-get remove npm -y
	#apt-get purge npm
    echo "Uninstall Complete!"
}

# Initialization step
install_LAON
