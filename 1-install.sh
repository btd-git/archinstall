#!/bin/bash
clear
echo "    _             _       ___           _        _ _ "
echo "   / \   _ __ ___| |__   |_ _|_ __  ___| |_ __ _| | |"
echo "  / _ \ | '__/ __| '_ \   | || '_ \/ __| __/ _' | | |"
echo " / ___ \| | | (__| | | |  | || | | \__ \ || (_| | | |"
echo "/_/   \_\_|  \___|_| |_| |___|_| |_|___/\__\__,_|_|_|"
echo ""
echo "-----------------------------------------------------"
echo ""
# ------------------------------------------------------
# Enter partition names
# ------------------------------------------------------
lsblk
read -p "Enter the name of the EFI partition (eg. sda1): " sda1
read -p "Enter the name of the ROOT partition (eg. sda2): " sda2
# ------------------------------------------------------
# Sync time
# ------------------------------------------------------
timedatectl set-ntp true

# ------------------------------------------------------
# Format partitions
# ------------------------------------------------------
mkfs.fat -F 32 /dev/$sda1;
mkfs.btrfs -f /dev/$sda2

# ------------------------------------------------------
# Mount points for btrfs
# ------------------------------------------------------
mount /dev/$sda2 /mnt
btrfs su cr /mnt/@
btrfs su cr /mnt/@cache
btrfs su cr /mnt/@home
btrfs su cr /mnt/@snapshots
btrfs su cr /mnt/@log
umount /mnt

mount -o rw,compress=zstd:1,noatime,space_cache=v2,subvol=@ /dev/$sda2 /mnt
mkdir -p /mnt/{boot/efi,home,.snapshots,var/{cache,log}}
mount -o rw,compress=zstd:1,noatime,space_cache=v2,subvol=@cache /dev/$sda2 /mnt/var/cache
mount -o rw,compress=zstd:1,noatime,space_cache=v2,subvol=@home /dev/$sda2 /mnt/home
mount -o rw,compress=zstd:1,noatime,space_cache=v2,subvol=@log /dev/$sda2 /mnt/var/log
mount -o rw,compress=zstd:1,noatime,space_cache=v2,subvol=@snapshots /dev/$sda2 /mnt/.snapshots
mount /dev/$sda1 /mnt/boot/efi

# ------------------------------------------------------
# FIND BEST DOWNLOAD SERVERS
# ------------------------------------------------------
echo "FINDING BEST SERVERS"
reflector -c "India" -a 5 -p https --sort rate --save /etc/pacman.d/mirrorlist

# ------------------------------------------------------
# UNCOMMENT "ParallelDownloads = 50" in /etc/pacman.conf
# ------------------------------------------------------

while true; do
    read -p "DO YOU WANT TO OPEN /etc/pacman.conf? (Yy/Nn): " yn
    case $yn in
        [Yy]* )
            vim /etc/pacman.conf
        break;;
        [Nn]* ) 
        break;;
        * ) echo "Please answer yes or no.";;
    esac
done
# ------------------------------------------------------
# Install base packages
# ------------------------------------------------------
pacman -Syy
pacstrap -K /mnt base base-devel git linux linux-firmware vim openssh reflector rsync intel-ucode

# ------------------------------------------------------
# Generate fstab
# ------------------------------------------------------
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
sleep 3
# ------------------------------------------------------
# Copy configuration scripts
# ------------------------------------------------------
mkdir -p /mnt/archinstall
cp 1-install.sh /mnt/archinstall
cp 2-configuration.sh /mnt/archinstall/
cp 3-yay.sh /mnt/archinstall/
cp 4-zram.sh /mnt/archinstall/
cp 5-timeshift.sh /mnt/archinstall/
cp 6-preload.sh /mnt/archinstall/
cp snapshot.sh /mnt/archinstall/

# ------------------------------------------------------
# Chroot to installed sytem
# ------------------------------------------------------
arch-chroot /mnt ./archinstall/2-configuration.sh

