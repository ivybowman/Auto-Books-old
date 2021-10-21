#!/bin/bash
#Set Variables
time=$(date +%Y-%m-%d_%H:%M) #Timestamp of when the script began, used for log & discord message.
host=$(hostname) #Hostname stored for discord message, used in case multiple machines are used.
error="false" #Initialize error status, used to choose Discord message to send
scriptdir=$(pwd) #Store pwd for copy commands
 
# Set User Customized Variables
#Webhook for Discord status alerts.
webhook="https://discord.com/api/webhooks/900195892009762916/fkwgutgBCuXussd3rQKJhW0vOQFBv27XJfu7pIqK_1RWKyhjEI55TxP1PE696jROw-XR"
#Directory to copy the .m4b output files
audiobooksdir=/mnt/c/Users/famil/OneDrive/AudioBooks
#Directory which contains your .ODM download files.  
odmdir=/mnt/c/Users/famil/Downloads/
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
    touch AutoBookList.txt
fi

#Output Banner
toilet AutoBooks 
echo "by Ivan Bowman | Hostname: $host | Start Time: $time" 
echo "=====================================================================" 

#Pre script checks to determine variable status.
if [ -z "$webhook" ] 
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

#Check for .odm files to Download & Merge
echo "Checking for .odm files to process in $odmdir"
if ls ${odmdir}/*.odm &>/dev/null
then
    #Set var for use later and print success message + file list  
    odmstatus="Success, found .odm download files to process." 
    echo "$odmstatus" 
    echo -e "\e[1;35mList of Found .odm files" 
    ls *.odm 
    echo "====================================================================="
    #For every .odm file, run odmpy to download add chapter info and merge.
    for file in *.odm; do  $HOME/.local/bin/odmpy dl -c -m --mergeformat m4b --nobookfolder "$file" ; done 2>&1 | tee AutoBooks-Download.log
    cat AutoBooks.log | grep Downloading >> AutoBookList.txt
    cat AutoBooks.log | grep downloaded >> AutoBookList.txt
    cat AutoBooks.log | grep expired >> AutoBookList.txt
    cat AutoBooks.log | grep Merged >> AutoBookList.txt
    echo "====================================================================="
else
odmstatus="Error, no .odm download files found."
echo -e "\e[1;31m$odmstatus" 
error="true"
fi

#Checks if output files are present and process them
if ls ${odmdir}/*.m4b &>/dev/null
then
#Set status for later use and send status message + file list
m4bstatus="Success, found .m4b book files to process"
echo -e "\e[1;35m$m4bstatus"
echo -e "\e[1;35mList of Found .m4b files"
ls *.m4b
echo "====================================================================="
#Copy .m4b files to Audiobooks Folder and remove them from $odmdir
cp -v *.m4b $audiobooksdir
cp -v *.m4b "/mnt/c/Users/famil/Music/iTunes/iTunes Media/Automatically Add to iTunes"
rm *.m4b
echo "Backing up source files."
#Clean and back up the log and download files
mv -f *.{odm,license} $scriptdir/ODMbackup  
toilet Finished
else
m4bstatus="Error, no .m4b book files found." 
echo -e "\e[1;31m$m4bstatus" 
error="true"
fi
cp -v AutoBooks-Download.log $scriptdir/log/Autobooks-Download-$time.log #Log contains output from odmpy.

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
--title "AutoBooks Run Failed at $endtime" \
--description "**Status List** \n $odmstatus \n $m4bstatus \n **Other Variables** \n odmdir=$odmdir \n scriptdir=$scriptdir \n time=$time \n host=$host \n **Description** \n Failed! Double check files & settings." \
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
--title "AutoBooks Run Success at $endtime" \
--description "**Status List** \n $odmstatus \n $m4bstatus \n ODMdir=$odmdir \n **Description** \n Success! You get brownie points." \
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
exit