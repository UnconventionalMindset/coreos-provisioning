#!/bin/bash

# Check if env is passed
[ $# != 1 ] && { echo "Usage: ./create-ipxe-iso.sh <env>"; exit 1; }

download_folder="ipxe"
install_script_url="https://raw.githubusercontent.com/UnconventionalMindset/coreos-setup/main/coreos-install.ipxe"

# path to download the ipxe script
full_path="$HOME/${download_folder}"

[ -z $full_path ] && { echo "Error: download path is empty"; exit 1; } || echo "Download path set to: ${full_path}, continuing..."

# Needed to make ipxe
apt -y install gcc binutils make perl liblzma-dev mtools genisoimage syslinux isolinux

# Cleanup in case script fails
rm -f $HOME/coreos-install.ipxe
rm -rf ${full_path}/
rm -f /var/lib/vz/template/iso/coreos-ipxe.iso

git clone https://git.ipxe.org/ipxe.git $full_path

cd ${full_path}/src

# Downloads ipxe script from github
curl $install_script_url -o $HOME/coreos-install.ipxe

# Enables HTTPS
sed -i 's/#undef[[:space:]]*\(DOWNLOAD_PROTO_HTTPS\)/#define \1/' config/general.h

# Makes IPXE
make bin/ipxe.iso EMBED=$HOME/coreos-install.ipxe

# Puts ISO in the right folder to be available in Proxmox
mv bin/ipxe.iso /var/lib/vz/template/iso/coreos-ipxe.iso

# Cleanup after succeeding
rm -f $HOME/${branch}-coreos-install.ipxe
rm -rf ${full_path}/
