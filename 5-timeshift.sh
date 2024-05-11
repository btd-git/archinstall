#!/bin/bash
#  _____ _                     _     _  __ _    
# |_   _(_)_ __ ___   ___  ___| |__ (_)/ _| |_  
#   | | | | '_ ` _ \ / _ \/ __| '_ \| | |_| __| 
#   | | | | | | | | |  __/\__ \ | | | |  _| |_  
#   |_| |_|_| |_| |_|\___||___/_| |_|_|_|  \__| 
#                                               
#  
clear
echo " _____ _                     _     _  __ _    "
echo "|_   _(_)_ __ ___   ___  ___| |__ (_)/ _| |_  "
echo "  | | | | '_ ' _ \ / _ \/ __| '_ \| | |_| __| "
echo "  | | | | | | | | |  __/\__ \ | | | |  _| |_  "
echo "  |_| |_|_| |_| |_|\___||___/_| |_|_|_|  \__| "
echo "                                               "
echo ""

# -----------------------------------------------------
# Confirm Start
# -----------------------------------------------------
while true; do
    read -p "DO YOU WANT TO START THE INSTALLATION NOW? (Yy/Nn): " yn
    case $yn in
        [Yy]* )
            echo "Installation started."
        break;;
        [Nn]* ) 
            exit;
        break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# -----------------------------------------------------
# Install zram
# -----------------------------------------------------
sudo pacman --noconfirm -S timeshift

echo "DONE!"
echo "You can create snapshots and update the GRUB Bootloader with ./snapshot.sh"
sleep 3
./6-preload.sh