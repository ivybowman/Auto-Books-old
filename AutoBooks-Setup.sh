#!/bin/bash
#Run Updates
echo "Running sudo apt update"
sudo apt update

#Install Deps
echo "Installing Dependencies"
sudo apt-get install ffmpeg toilet neofetch python3 python3-pip curl bats jq moreutils git -y
#Download discord.sh
curl https://raw.githubusercontent.com/ChaoticWeg/discord.sh/v1.6/discord.sh > discord.sh

#Ask whether or not to install ODMPY
echo "Install ODMPY? [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "Installing ODMPY by https://github.com/ping"
        pip3 install git+https://git@github.com/ping/odmpy.git --upgrade --force-reinstall
        echo "To add to path run the following command." 
        echo 'export PATH="$HOME/.local/bin:$PATH"'
else
        echo "Proceeding Without Installing ODMPY. Make sure you have it installed."
fi
