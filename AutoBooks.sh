#!/bin/bash
#Set Variables
time=$(date +%Y-%m-%d_%H:%M)
host=$(hostname)
error="false"
# Set User Customized Variables
webhook="https://discord.com/api/webhooks/900195892009762916/fkwgutgBCuXussd3rQKJhW0vOQFBv27XJfu7pIqK_1RWKyhjEI55TxP1PE696jROw-XR"
#Script Directory
scriptdir=$(pwd)
#Directory Containing your .ODM files  
dirodm=/mnt/c/Users/famil/Downloads/
cd $dirodm

#Output Banner
toilet AutoBooks
echo "by Ivan Bowman | Hostname: $host | Start Time: $time"
echo "====================================================================="

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
if ls ${dirodm}/*.odm &>/dev/null
then
    odmstatus="Success, found .odm download files to process."
    echo "$odmstatus"
    for file in *.odm; do  $HOME/.local/bin/odmpy dl -c -m --mergeformat m4b --nobookfolder "$file" && rm cover.jpg ; done 2>&1 | tee AutoBooks.log
    cat AutoBooks.log | grep Downloading > AutoBookList.txt
else
odmstatus="Error, no .odm download files found."
echo "$odmstatus"
error="true"
fi

#Check for leftover cover.jpg & Book List and remove if found
if [ -f "./cover.jpg" ];
then
    rm cover.jpg
fi
#Checks if output files are present and process them
if ls ${dirodm}/*.odm &>/dev/null
then
echo "Backing up source files." 
#Clean and back up the log and source files
mv -f *.{odm,license} $scriptdir/ODMbackup
cp -v AutoBooks.log $scriptdir/log/Autobooks-$time.log
#Set status for later use and status message
m4bstatus="Success, found .m4b book files to process"
echo "$m4bstatus"
# ls *.m4b > AutoBookList.txt
cp -v *.m4b /mnt/c/Users/famil/OneDrive/AudioBooks
cp -v *.m4b "/mnt/c/Users/famil/Music/iTunes/iTunes Media/Automatically Add to iTunes" 2>&1 | tee AutoBooks.log
rm *.m4b
toilet Finished
else
m4bstatus="Error, no .m4b book files found."
echo "$m4bstatus"
error="true"
fi

#Sending Out to discord
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
--description "**Status List** \n .odm = $odmstatus \n .m4b = $m4bstatus \n **Description** \n This means the script was unsuccessful and you can see why above." \
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
--description "**Status List** \n $odmstatus \n $m4bstatus \n Script Dir $scriptdir \ n ODM Directory **Description** \n This is supposed to mean the script was successful." \
--footer "Started: $time Host: $host" \
--image "https://media.giphy.com/media/LnRahQFrzU5OXOuA8S/giphy.gif"
fi

#Discord File Message For Booklist
if [ -f "./AutoBookList.txt" ]
then
./discord.sh \
  --webhook-url=$webhook \
  --username "AutoBooksLogBot" \
--avatar "https://styles.redditmedia.com/t5_2qh2d/styles/communityIcon_xagsn9nsaih61.png?width=256&s=1e4cf3a17c94aecf9c127cef47bb259162283a38" \
--file $dirodm/AutoBookList.txt
fi

#File Message For LOG
#if [ -f "/mnt/c/Users/famil/Downloads/AutoBooks.log" ]
#then
#./discord.sh \
#  --webhook-url=$webhook
#  --username "AutoBooksLogBot" \
#--avatar "https://styles.redditmedia.com/t5_2qh2d/styles/communityIcon_xagsn9nsaih61.png?width=256&s=1e4cf3a17c94aecf9c127cef47bb259162283a38" \
#--file $dirodm/AutoBooks.log
#fi
exit