#!/bin/bash

# Check if env is passed
[ $# != 1 ] && { echo "Usage: ./create-ipxe-iso.sh <env>"; exit 1; }

branch=$1
download_folder="ipxe"
scriptname="${branch}-coreos-install.ipxe"
isoname="${branch}-coreos-ipxe.iso"
install_script_url="https://raw.githubusercontent.com/UnconventionalMindset/coreos-provisioning/${branch}/coreos-install.ipxe"

# path to download the ipxe script
full_path="$HOME/${download_folder}"

[ -z $full_path ] && { echo "Error: download path is empty"; exit 1; } || echo "Download path set to: ${full_path}, continuing..."

# Needed to make ipxe
apt -y install gcc binutils make perl liblzma-dev mtools genisoimage syslinux isolinux

# Cleanup in case script fails
rm -f "$HOME/${scriptname}"
rm -rf "${full_path}/"
rm -f "/var/lib/vz/template/iso/${isoname}"

git clone https://git.ipxe.org/ipxe.git $full_path

cd ${full_path}/src

# Downloads ipxe script from github
curl $install_script_url -o "$HOME/${scriptname}"

# Enables HTTPS
sed -i 's/#undef[[:space:]]*\(DOWNLOAD_PROTO_HTTPS\)/#define \1/' config/general.h

# Makes IPXE
make bin/ipxe.iso EMBED="$HOME/${scriptname}"

# Puts ISO in the right folder to be available in Proxmox
mv bin/ipxe.iso /var/lib/vz/template/iso/${isoname}

# Cleanup after succeeding
rm -f "$HOME/${scriptname}"
rm -rf "${full_path}/"
