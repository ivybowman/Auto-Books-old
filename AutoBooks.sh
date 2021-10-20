#!/bin/bash
#Set Variables
time=$(date +%Y-%m-%d_%H:%M) #Timestamp of when the script began, used for log & discord message.
host=$(hostname) #Hostname stored for discord message, used in case multiple machines are used.
error="false" #Initalize error status, used to choose Discord message to send
scriptdir=$(pwd) #Store pwd for copy commands

# Set User Customized Variables
webhook="https://discord.com/api/webhooks/900195892009762916/fkwgutgBCuXussd3rQKJhW0vOQFBv27XJfu7pIqK_1RWKyhjEI55TxP1PE696jROw-XR"
#Directory which contains your .ODM download files.  
odmdir=/mnt/c/Users/famil/Downloads/
#Directory to copy the .m4b output files
audiobooksdir=/mnt/c/Users/famil/OneDrive/AudioBooks
#If using WSL optionally put your Automatically Add to iTunes folder here.
itunesdir=/mnt/c/Users/famil/Music/iTunes/iTunes Media/Automatically Add to iTunes

#Output Banner
toilet AutoBooks
echo "by Ivan Bowman | Hostname: $host | Start Time: $time"
echo "====================================================================="

#Pre script checks to determine variable status.
if [ -z "$webhook" ] #
then
echo -e "\e[1;31m\Error: Please set the webhook variable."
read
exit
fi
if [ -z "$odmdir" ]
then
echo -e "\e[1;31m\Error: Please set the odmdir variable."
read
exit
fi
if [ -z "$audiobooksdir" ]
then
echo -e "\e[1;31m\Error: Please set the audiobooksdir variable."
read
exit
fi
cd $odmdir

#Check for existing files and remove if found
if [ -f "cover.jpg" ]
then
    rm cover.jpg
fi
if [ -f "./AutoBooks.log" ]
then
    rm AutoBooks.log
fi
if [ -f "./AutoBookList.txt" ]
then
    rm AutoBookList.txt
fi

#Check for .odm files to Download & Merge
echo "Checking for .odm files to process in $pwd"
if ls ${odmdir}/*.odm &>/dev/null
then
    #Set var for use later and print success message + file list  
    odmstatus="Success, found .odm download files to process."
    echo "$odmstatus"
    echo -e "\e[1;35mList of Found .odm files"
    ls *.odm
    #For every .odm file, run odmpy to download add chapter info and merge.
    for file in *.odm; do  $HOME/.local/bin/odmpy dl -c -m --mergeformat m4b --nobookfolder "$file" && rm cover.jpg ; done 2>&1 | tee AutoBooks.log
    cat AutoBooks.log | grep Downloading > AutoBookList.txt
else
odmstatus="Error, no .odm download files found."
echo -e "\e[1;31m$odmstatus"
error="true"
fi

#Check for leftover cover.jpg & Book List and remove if found
if [ -f "./cover.jpg" ];
then
    rm cover.jpg
fi

#Checks if output files are present and process them
if ls ${odmdir}/*.m4b &>/dev/null
then
echo "Backing up source files." 
#Clean and back up the log and download files
mv -f *.{odm,license} $scriptdir/ODMbackup
cp -v AutoBooks.log $scriptdir/log/Autobooks-$time.log #Log contains output from odmpy commands.  
#Set status for later use and send status message + file list
m4bstatus="Success, found .m4b book files to process"
echo -e "\e[1;35m$m4bstatus"
echo -e "\e[1;35mList of Found .odm files"
ls *.m4b
#Copy .m4b files to Audiobooks Folder and iTunes Auto Add folder and remove them from $odmdir
cp -v *.m4b $audiobooksdir
cp -v *.m4b $itunesdir
rm *.m4b
toilet Finished
else
m4bstatus="Error, no .m4b book files found."
echo -e "\e[1;31m$m4bstatus"
error="true"
fi

#Sending Output to Discord
endtime=$(date +"%r")
echo "Status Sent to #auto-books-output on Discord"
cd $scriptdir

#Send this if error = true
if [ $error = "true" ]
then
./discord.sh \
  --webhook-url=https://discord.com/api/webhooks/900195892009762916/fkwgutgBCuXussd3rQKJhW0vOQFBv27XJfu7pIqK_1RWKyhjEI55TxP1PE696jROw-XR \
  --username "AutoBooksLogBot" \
--avatar "https://styles.redditmedia.com/t5_2qh2d/styles/communityIcon_xagsn9nsaih61.png?width=256&s=1e4cf3a17c94aecf9c127cef47bb259162283a38" \
--title "AutoBooks Has Finshed Running With Errors at $endtime" \
--description "**Status List** \n $odmstatus \n $m4bstatus \n **Description** \n This means the script was unsuccessful and you can see why above." \
--footer "Started: $time Host: $host" \
--image "https://media.giphy.com/media/TqiwHbFBaZ4ti/giphy.gif"
fi

#Send this Discord Message if error = false
if [ $error = "false" ]
then
./discord.sh \
  --webhook-url=$webhook \
  --username "AutoBooksLogBot" \
--avatar "https://styles.redditmedia.com/t5_2qh2d/styles/communityIcon_xagsn9nsaih61.png?width=256&s=1e4cf3a17c94aecf9c127cef47bb259162283a38" \
--title "AutoBooks Has Finshed Running at $endtime" \
--description "**Status List** \n $odmstatus \n $m4bstatus \n $scriptdir \ n  \n**Description** \n This is supposed to mean the script was successful." \
--footer "Started: $time Host: $host" \
--image "https://media.giphy.com/media/LnRahQFrzU5OXOuA8S/giphy.gif"
fi

#Discord File Message For Booklist
if [ -f "$odmdir/AutoBookList.txt" ]
then
./discord.sh \
  --webhook-url=$webhook \
  --username "AutoBooksLogBot" \
--avatar "https://styles.redditmedia.com/t5_2qh2d/styles/communityIcon_xagsn9nsaih61.png?width=256&s=1e4cf3a17c94aecf9c127cef47bb259162283a38" \
--file $odmdir/AutoBookList.txt
fi

#File Message For LOG
#if [ -f "/mnt/c/Users/famil/Downloads/AutoBooks.log" ]
#then
#./discord.sh \
#  --webhook-url=$webhook
#  --username "AutoBooksLogBot" \
#--avatar "https://styles.redditmedia.com/t5_2qh2d/styles/communityIcon_xagsn9nsaih61.png?width=256&s=1e4cf3a17c94aecf9c127cef47bb259162283a38" \
#--file $odmdir/AutoBooks.log
#fi
exit