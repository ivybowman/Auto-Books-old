#!/bin/bash

#Set Variables
time=$(date +"%r")
host=$(hostname)
error="false"

cd /mnt/c/Users/famil/Downloads

#Output Banner
toilet AutoBooks
echo "by Ivan Bowman | Hostname: $host | Start Time: $time"
echo "====================================================================="
Check for existing files and remove if found
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
if [ -f *.odm ];
then
    odmstatus="Success, found .odm download files to process."
    for file in *.odm; do  /home/famil/.local/bin/odmpy dl -c -m --mergeformat m4b --nobookfolder "$file" && rm cover.jpg ; done 2>&1 | tee AutoBooks.log
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
#Check if output files are present and send them to the right place.
if [ -e *.m4b ];
then
echo "Backing up source files." 
mv -f *.{odm,license} /mnt/c/Users/famil/OneDrive/Documents/OverdriveSourceFiles
cp -v AutoBooks.log /mnt/c/Users/famil/OneDrive/Documents/OverdriveSourceFiles/log/Autobooks-$time.log
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
cd /mnt/c/Users/famil/OneDrive/Documents/

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
  --webhook-url=https://discord.com/api/webhooks/900195892009762916/fkwgutgBCuXussd3rQKJhW0vOQFBv27XJfu7pIqK_1RWKyhjEI55TxP1PE696jROw-XR \
  --username "AutoBooksLogBot" \
--avatar "https://styles.redditmedia.com/t5_2qh2d/styles/communityIcon_xagsn9nsaih61.png?width=256&s=1e4cf3a17c94aecf9c127cef47bb259162283a38" \
--title "AutoBooks Has Finshed Running at $endtime" \
--description "**Status List** \n .odm = $odmstatus \n .m4b = $m4bstatus \n **Description** \n This is supposed to mean the script was successful." \
--footer "Started: $time Host: $host" \
--image "https://media.giphy.com/media/LnRahQFrzU5OXOuA8S/giphy.gif"
fi

#Discord File Message For Booklist
if [ -f "./AutoBookList.txt" ]
then
./discord.sh \
  --webhook-url=https://discord.com/api/webhooks/900195892009762916/fkwgutgBCuXussd3rQKJhW0vOQFBv27XJfu7pIqK_1RWKyhjEI55TxP1PE696jROw-XR \
  --username "AutoBooksLogBot" \
--avatar "https://styles.redditmedia.com/t5_2qh2d/styles/communityIcon_xagsn9nsaih61.png?width=256&s=1e4cf3a17c94aecf9c127cef47bb259162283a38" \
--file /mnt/c/Users/famil/Downloads/AutoBookList.txt
fi

#File Message For LOG
#if [ -f "/mnt/c/Users/famil/Downloads/AutoBooks.log" ]
#then
#./discord.sh \
#  --webhook-url=https://discord.com/api/webhooks/900195892009762916/fkwgutgBCuXussd3rQKJhW0vOQFBv27XJfu7pIqK_1RWKyhjEI55TxP1PE696jROw-XR \
#  --username "AutoBooksLogBot" \
#--avatar "https://styles.redditmedia.com/t5_2qh2d/styles/communityIcon_xagsn9nsaih61.png?width=256&s=1e4cf3a17c94aecf9c127cef47bb259162283a38" \
#--file /mnt/c/Users/famil/Downloads/AutoBooks.log
#fi
exit