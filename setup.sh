#!/bin/bash
# This script installs R and builds RStudio Desktop for ARM Chromebooks running debian stretch

# Install R; Debian stretch has latest version
apt-get update
mkdir -p /usr/share/man/man1
apt-get install --no-install-recommends -y r-base r-base-dev wget openjdk-11-jdk lsb-release 

# Set RStudio version
VERS=v1.3.1093

# Download RStudio source
cd /tmp
wget -O $VERS https://github.com/rstudio/rstudio/tarball/$VERS
mkdir /tmp/rstudio-$VERS
tar xvf /tmp/$VERS -C /tmp/rstudio-$VERS --strip-components 1
rm /tmp/$VERS

# Run environment preparation scripts
cd /tmp/rstudio-$VERS/dependencies/linux/
sed -i 's/bionic/buster/g' ./install-dependencies-bionic
sed -i 's/sudo//g' ./install-dependencies-bionic
sed -i 's/apt-get -y install/apt-get -y --no-install-recommends install/g' ./install-dependencies-bionic
sed -i 's/openjdk-8-jdk/openjdk-11-jdk/g' ./install-dependencies-bionic

./install-dependencies-bionic --exclude-qt-sdk

# Run common environment preparation scripts

cd /tmp/rstudio-$VERS/dependencies/common/
#./install-common
#./install-gwt
sed -i 's/sudo//g' ./install-dictionaries
./install-dictionaries
sed -i 's/sudo//g' ./install-mathjax
./install-mathjax
sed -i 's/sudo//g' ./install-boost
./install-boost
sed -i 's/sudo//g' ./install-pandoc
./install-pandoc
#./install-libclang
sed -i 's/sudo//g' ./install-packages
./install-packages

# Add pandoc folder to override build check
mkdir /tmp/rstudio-$VERS/dependencies/common/pandoc
apt-get install --no-install-recommends git libcurl4-openssl-dev
# Get Closure Compiler and replace compiler.jar
cd /tmp/

wget https://dl.google.com/closure-compiler/compiler-20200719.tar.gz 
tar -xzvf compiler-20200719.tar.gz /tmp/

rm COPYING README.md compiler-20200719.tar.gz
mv closure-compiler*.jar /tmp/rstudio-$VERS/src/gwt/tools/compiler/compiler.jar

# Configure cmake and build RStudio
cd /tmp/rstudio-$VERS/
mkdir build
cmake -DRSTUDIO_TARGET=Server -DCMAKE_BUILD_TYPE=Release
make install

# Additional install steps
useradd -r rstudio-server
cp /usr/local/lib/rstudio-server/extras/init.d/debian/rstudio-server /etc/init.d/rstudio-server
chmod +x /etc/init.d/rstudio-server
ln -f -s /usr/local/lib/rstudio-server/bin/rstudio-server /usr/sbin/rstudio-server
chmod 777 -R /usr/local/lib/R/site-library/

# Setup locale
apt-get install --no-install-recommends -y locales
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
#echo 'export LANG=en_US.UTF-8' >> ~/.bashrc
#echo 'export LANGUAGE=en_US.UTF-8' >> ~/.bashrc

# Clean the system of packages used for building
apt-get autoremove -y cabal-install ghc openjdk-11-jdk pandoc libboost-all-dev lsb-release wget nano
rm -r -f /tmp/rstudio-$VERS
apt-get autoremove -y

# Start the server
useradd Adm1nRsTudi0 && echo "Adm1nRsTudi0:+R$tUdi0-SeRVeR+" | chpasswd && mkdir /home/rstudio chown Adm1nRsTudi0:Adm1nRsTudi0 /home/rstudio && addgroup Adm1nRsTudi0 staff

rstudio-server start

# Go to localhost:8787