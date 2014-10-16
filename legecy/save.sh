#!/bin/bash

#FIRST, PLEASE INSTALL UBUNTU AND XEN-TOOLS.
#See http://virantha.com/2014/05/21/ubuntu-14-04-trusty-on-xenserver-62/ or 
#    http://www.frederickding.com/posts/2014/07/paravirtualized-centos-7-ubuntu-14-04-xenserver-162072/ 
#for installing ubuntu latest onto XS 6.2
#When installing Ubuntu, you can use http://au.archive.ubuntu.com/pub/ubuntu/archive/ as the URL, because we are in Australia.


#This script is supposed to be running on Ubuntu 14.04 LTS, because that is the latest version of Ubuntu.
#Make sure XFCE desktop is installed.
#To use this script, you should first run
#          script-name step1
#then you should su - newuser, and run
#          script-name step2
#then you should log out, and log in, and run
#          script-name step3

NEWUSER=
NEWUID=
NEWGID=
P4PASSWD=""
WORKSPACENAME=
WORKSPACELOCATION=

LOG_FILE=/tmp/install.log

function die { info "DIE: $@"; exit 1; }
function info { echo -e "INFO: $@" | tee -a ${LOG_FILE}; }
function infoNewCommand { echo -e "\nEXECUTE: $@" | tee -a ${LOG_FILE}; }

function run_with_retry {
  local n=1
  local max=5
  local delay=15
  while true; do
    "$@" >>${LOG_FILE} 2>&1 && break || {
      if [[ $n -lt $max ]]; then
        ((n++))
        info "Command failed. Attempt $n/$max:"
        sleep $delay;
      else
        die "$@"
      fi
    }
  done
}

info "LOG file is ${LOG_FILE}."


setup_users() {
	infoNewCommand "make sudo password-less"
	sudo sed -i -e '1,$s/^%sudo.*$/%sudo   ALL=(ALL:ALL) NOPASSWD: ALL/'  /etc/sudoers

	#make sure the user has correct groups.
	infoNewCommand "ADDING USER $NEWUSER..."
	sudo addgroup --gid $NEWGID $NEWUSER
	sudo adduser --uid $NEWUID --gid $NEWGID  --gecos "" $NEWUSER
	sudo usermod -G  adm,cdrom,sudo,dip,plugdev,lpadmin,sambashare  $NEWUSER

	info "ADDING USER taas_analysis_home..."
	sudo adduser --disabled-password --gecos ""  taas_analysis_home

	sudo chmod a+w ${LOG_FILE}

	info ''
	info 'Now you should install XenServer Tools manually.'
	info 'Hint:'
	info '    sudo dpkg -i xe-guest-utilities_6.2.0-1120_amd64.deb'
	info ''
	info "And then login as the newly created user: ${NEWUSER}"
} #end of setup_users


setup_profile() {
#install vim and spf13,
infoNewCommand 'Provisoning apt-get ...'
run_with_retry sudo apt-get update

infoNewCommand 'Installing vim and git ...'
run_with_retry sudo apt-get -y install git vim

infoNewCommand 'Installing spf13-vim ...'
run_with_retry curl https://j.mp/spf13-vim3 -L > spf13-vim.sh 
run_with_retry bash spf13-vim.sh
run_with_retry rm spf13-vim.sh


cat > ~/.vimrc.local <<EOF
set fileencodings=utf-8,gbk,ucs-bom,latin1
map <F8> :NERDTreeToggle<CR>:NERDTreeMirror<CR>
unmap <C-e>
set mouse=""
let mapleader = ","
EOF

#install p4
infoNewCommand "installing p4.."
run_with_retry wget 'http://www.perforce.com/downloads/perforce/r14.1/bin.linux26x86_64/p4' 
run_with_retry chmod +x p4 
run_with_retry sudo mv p4 /usr/local/bin/p4


cat > ~/.p4config <<EOF
P4PORT=
P4HOST=
P4USER=$NEWUSER
P4CLIENT=${WORKSPACENAME}
EOF

echo '*.pyc' > ~/.p4ignore


#install golang
infoNewCommand "installing golang .."
run_with_retry wget http://golang.org/dl/go1.3.linux-amd64.tar.gz 
run_with_retry sudo tar -C /usr/local -xzf go1.3.linux-amd64.tar.gz 
run_with_retry rm -rf go1.3.linux-amd64.tar.gz

mkdir ~/gopath


cat >> ~/.bash_profile <<EOF
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

export GOPATH=/home/$NEWUSER/gopath
export PATH=\$PATH:/usr/local/go/bin:\$GOPATH/bin/

export P4CONFIG=/home/$NEWUSER/.p4config
export P4EDITOR=/usr/bin/vim
export P4IGNORE=/home/$NEWUSER/.p4ignore
alias my-workdir=
#alias run_server='my-workdir; sudo python ./manage.py   runserver_plus   --settings=settings  0.0.0.0:80'


export PGHOST=
export PGUSER=postgres
EOF

info ''
info 'Please log out and log in to run step3'
}

setup_dev() {

#install pip
# normally I would prefer python-pip, but there seems to be something wrong with it.
#sudo apt-get -y install  python-setuptools python-pip
info "installing pip .."

run_with_retry wget https://bootstrap.pypa.io/get-pip.py 
run_with_retry sudo python get-pip.py 
run_with_retry rm get-pip.py


#install and setup NFS, see more details: https://help.ubuntu.com/12.04/serverguide/network-file-system.html
info "installing NFS .."
run_with_retry sudo apt-get -y install nfs-common 
echo 'xxx.xxx.xxx.xxx:/home /home/taas_analysis_home nfs rw 0 0' | sudo tee -a /etc/fstab
if [ ! -d /home/taas_analysis_home/taas2 ] ; then
	run_with_retry sudo mount -t nfs -o rw xxx.xxx.xxx.xxx:/home /home/taas_analysis_home
fi


#sync code.
info "Syncing code ..."
echo $P4PASSWD | /usr/local/bin/p4 login || die 'p4 login'
run_with_retry /usr/local/bin/p4 sync


#copy rex's p4check
#cp /home/taas_analysis_home/taas2/zhaoguoj/taas/TaasSite/p4check_mine.py  ${WORKSPACELOCATION}/TaasSite/p4check_rex.py
#chmod +x ${WORKSPACELOCATION}/TaasSite/p4check_rex.py	


info "install dev libs ..."
run_with_retry sudo apt-get -y install libxml2-dev libxslt-dev python-dev libldap2-dev libssl-dev libsasl2-dev libldap2-dev freetds-dev sqlite3 libpq-dev
# pymssql==2.0.0b1-dev-20111019 can not be found any more.
# pexpect 2.3 can not be found any more.
python ${WORKSPACELOCATION}/TaasSite/requirements.py node > ~/requirements.txt
sed -i -e '1,$s/pymssql==2.0.0b1-dev-20111019/pymssql==2.0.1/' ~/requirements.txt 
sed -i -e '1,$s/pexpect==2.3/pexpect==2.4/' ~/requirements.txt

run_with_retry sudo pip install   --allow-all-external    --allow-unverified django-admin-tools     --allow-unverified pyDes    --allow-unverified pyrex  --allow-unverified pymssql -r  ~/requirements.txt



#TODO: install and setup nginx.
info "install nginx ..."
run_with_retry sudo apt-get -y install nginx



#TODO: install xrdp and vnc
info "install xrdp and vnc ..."
run_with_retry sudo apt-get -y install xrdp
run_with_retry sudo apt-get -y install tightvncserver


info "setting password for VNC ..."
tightvncpasswd

#The default $HOME/.vnc/xstartup file assumes this file is present.
touch ~/.Xresources

#make the XFCE xstartup file.
if [ ! -d ~/.vnc ] ; then
	mkdir ~/.vnc
fi

if [ ! -f ~/.vnc/xstartup ] ; then
cat > ~/.vnc/xstartup << EOF
#!/bin/bash

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

vncconfig -iconic &
xfce4-session &
EOF
fi

chmod +x ~/.vnc/xstartup


#startup VNC automatically.
cat > ~/vncserver << EOF
#!/bin/bash
### BEGIN INIT INFO
# Provides:          vncserver
# Required-Start:    networking
# Default-Start:     S
# Default-Stop:      0 6
### END INIT INFO

PATH="\$PATH:/usr/X11R6/bin/"

# The Username:Group that will run VNC
export VNCUSER="$NEWUSER"
#${RUNAS}

# The display that VNC will use
DISPLAY="1"

# The Desktop geometry to use.
#GEOMETRY="<WIDTH>x<HEIGHT>"
#GEOMETRY="800x600"
GEOMETRY="1024x768"
#GEOMETRY="1280x1024"


OPTIONS="-geometry \${GEOMETRY} :\${DISPLAY} -rfbport 8080"

source /lib/lsb/init-functions

case "\$1" in
start)
log_action_begin_msg "Starting vncserver for user '\${VNCUSER}' on localhost:\${DISPLAY}"
su \${VNCUSER} -l  -c "/usr/bin/vncserver \${OPTIONS}"
;;

stop)
log_action_begin_msg "Stoping vncserver for user '\${VNCUSER}' on localhost:\${DISPLAY}"
su \${VNCUSER} -l -c "/usr/bin/vncserver -kill :\${DISPLAY}"
;;

restart)
\$0 stop
\$0 start
;;
esac

exit 0
EOF

sudo mv ~/vncserver /etc/init.d/vncserver
sudo chmod +x /etc/init.d/vncserver
run_with_retry sudo update-rc.d vncserver defaults


info 'Starting VNC on port 8080:'
run_with_retry vncserver -rfbport 8080



#Other tools that I might use.
info 'install dos2unix and ag and others.'
run_with_retry sudo apt-get -y install dos2unix mercurial  rabbitmq-server tmux  silversearcher-ag

#this installs a httpserver command, which is a replacement for Python SimpleHTTPServer.
info 'install httpserver'
run_with_retry go get github.com/hecticjeff/httpserver

} #end of setup_devenv


case $1 in 
	step1)
        setup_users
    ;;
    step2)
        setup_profile
    ;;
    step3)
        setup_dev
    ;;
    *)
      echo 'wrong argument.'
    ;;
esac
