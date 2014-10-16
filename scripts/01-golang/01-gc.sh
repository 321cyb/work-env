#!/bin/bash


echo "installing golang 1.3.3 to /usr/local/go/"
cd $HOME
wget https://storage.googleapis.com/golang/go1.3.3.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.3.3.linux-amd64.tar.gz
rm go1.3.3.linux-amd64.tar.gz
mkdir -p gopath/src
cd -

cat >> ~/.bash_profile << EOF
export GOPATH=$HOME/gopath/
export PATH=\$PATH:/usr/local/go/bin:$HOME/gopath/bin/
EOF
