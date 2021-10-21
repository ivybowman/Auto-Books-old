# Auto-Books
An automation script written in shell for https://github.com/ping/odmpy/ supporting multiple .odm files, logging, discord alerts and more. Uses ODMPY to automatically download and convert multiple OverDrive audiobooks into a single file per book .m4b files with chapter tags, metadata, and the book cover all built in. The outputted .m4b file can easily be imported to iTunes and most audiobook players. 
# Disclaimer
The intention of this script is solely to automate downloading and converting of OverDrive audiobook loans, in order to use them properly with your preferred audiobook player during the loan period.
# Requirements
This script should work on Linux, MacOS, and WSL. However I have only tested it under WSL. All dependencies are installed in the setup script, including odmpy. 
# Installation
First clone the repository, and enter the resulting folder.
``` bash
git clone https://github.com/ivanbowman/Auto-Books && cd Auto-Books
```

Next run the `AutoBooks-Setup.sh` file and follow prompts. It gives you the option to install ODMPY if you haven't already.
``` bash
bash AutoBooks-Setup.sh
```
Now you need to set a few variables, open `AutoBooks.sh` in your text/code editor of choice and modify this section. 

``` bash
# Set User Customized Variables
#Webhook for Discord status alerts.
webhook="" 
#Directory to copy the .m4b output files
audiobooksdir= 
#Directory which contains your .ODM download files.  
odmdir=
```

Optional: Add ODMPY to $PATH
``` bash
export PATH="$HOME/.local/bin:$PATH"
```
# Usage
To run the script just type `bash AutoBooks.sh` in the script directory. Assuming you followed the instructions correctly it requires no user interaction although most errors will cause the window to stay open. While the script can be adjusted to preform any odmpy function, it's setup to run the command `odmpy dl -c -m --mergeformat m4b --nobookfolder` on every .odm file in the provided directory(odmdir), it then transfers the resulting .m4b files to another provided folder(audiobooksdir) and cleans up the leftover files. The download files are backed up to the folder `ODMbackup` where the script was run, allowing you to retry a failed download assuming the book hasn't expired. After the script finishes it will post a discord message using the provided webhook, with either a success or fail message.

### Important Note Regarding Retrying Downloads: 
In order to retry a download you need both the .odm and .license file as the latter is only generated once per .odm download. If you don't have the .license file you can redownload the .odm from your loans page  

# Credits
- Python OverDrive client, which my script is automating. https://github.com/ping/odmpy/
- Bash Discord write only CLI, which is used to post the webhook alert messages. https://chaoticweg.cc/discord.sh/
