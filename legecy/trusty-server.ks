# Ubuntu 14.04 LTS kickstart for XenServer
# branch: develop
##########################################

# Install, not upgrade
install

# Install from a friendly mirror and add updates
url --url http://au.archive.ubuntu.com/pub/ubuntu/archive/

# Language and keyboard setup
lang en_US
langsupport en_US
keyboard us

# Configure networking without IPv6, firewall off

# for STATIC IP: uncomment and configure
# network --device=eth0 --bootproto=static --ip=192.168.###.### --netmask=255.255.255.0 --gateway=192.168.###.### --nameserver=###.###.###.### --noipv6 --hostname=$$$

# for DHCP:
network --bootproto=dhcp --device=eth0

firewall --disabled

# Set timezone
timezone --utc Asia/Shanghai

# Authentication
rootpw --disabled
user xxxx --fullname "Ubuntu User" --password 123456
# if you want to preset the root password in a public kickstart file, use SHA512crypt e.g.
# user ubuntu --fullname "Ubuntu User" --iscrypted --password $6$9dC4m770Q1o$FCOvPxuqc1B22HM21M5WuUfhkiQntzMuAV7MY0qfVcvhwNQ2L86PcnDWfjDd12IFxWtRiTuvO/niB0Q3Xpf2I.
auth --useshadow

# Disable anything graphical
text

# Setup the disk
#zerombr yes
#clearpart --all
#autopart
bootloader --location=mbr

selinux --disabled

# Shutdown when the kickstart is done
reboot

# Minimal package set
%packages
ubuntu-minimal
curl
wget
xenstore-utils
linux-image-virtual
xubuntu-desktop
openssh-server

%post
#!/bin/bash
echo -n "Minimizing kernel"
apt-get install -f -y linux-virtual
apt-get remove -y linux-firmware
dpkg -l | grep extra | grep linux | awk '{print $2}' | xargs apt-get remove -y
echo .

echo -n "/etc/fstab fixes"
# update fstab for the root partition
perl -pi -e 's/(errors=remount-ro)/noatime,nodiratime,$1,barrier=0/' /etc/fstab
echo .

echo -n "Network fixes"
# For cloud images, 'eth0' _is_ the predictable device name, since
# we don't want to be tied to specific virtual (!) hardware
rm -f /etc/udev/rules.d/70*
ln -s /dev/null /etc/udev/rules.d/80-net-name-slot.rules
echo .

# generic localhost names
echo "Ubuntu14" > /etc/hostname
echo .
cat > /etc/hosts << EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 Ubuntu14
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6 Ubuntu14

EOF
echo .

# generalization
echo -n "Generalizing"
rm -f /etc/ssh/ssh_host_*
rm -f /var/cache/apt/archives/*.deb
rm -f /var/cache/apt/*cache.bin
rm -f /var/lib/apt/lists/*_Packages
echo .

# utility scripts
echo -n "Utility scripts"
dpkg-reconfigure openssh-server


# fix boot for older pygrub/XenServer
# you should comment out this entire section if on XenServer Creedence/Xen 4.4
echo -n "Fixing boot"
cp /boot/grub/grub.cfg /boot/grub/grub.cfg.bak
cp /etc/default/grub /etc/default/grub.bak
cp --no-preserve=mode /etc/grub.d/00_header /etc/grub.d/00_header.bak
sed -i 's/GRUB_DEFAULT=saved/GRUB_DEFAULT=0/' /etc/default/grub
sed -i 's/default="\\${next_entry}"/default="0"/' /etc/grub.d/00_header
echo -n "."
cp --no-preserve=mode /etc/grub.d/10_linux /etc/grub.d/10_linux.bak
sed -i 's/${sixteenbit}//' /etc/grub.d/10_linux
echo -n "."
update-grub
echo .

%end
