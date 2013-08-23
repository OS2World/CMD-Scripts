/**++++++++++++++++++++++++++++++++++++++++++**********************************/
/* Readme.txt for URLObjectTool V0.1 Beta  by Norbert Kohl                    */
/+++++++++++++++++++++++++++++++++++++++++*************************************/

When OS/2 Warp 4 came out one of the Enhancements I liked prety soon
where the URL-Objects. You can use them for more than just open a Web-URL
I just missed one thing:
why can I start only one program - the Standardbrowser?
why cant I rigt-click on a URL-Object and chose a different program like I
can do with regular program-objects?

Well - I found a solution and I call it URLObjectTool or short URLOT

INSTALLATION
Copy all the files to a folder of your choice. If you dont want to use URLOT
from command-line it does not have to be in the path-statement.
Then execute setup.cmd. Setup.cmd will create a folder and the programobject
'create new' in the Configuration-folder (<WP_ CONFIG>) and a shadow of that
URLOT-Configfolder on the Desktop.

USAGE
To create a URL-Object Meuitem use the 'create new' object.
After the helpscreen and pressing 'y' you will be asked for a titel.
This titel will be shown in the menu
Next you have to insert the URL of the program you want to associate.
Thats it. Now a new URLOT-Object with your titel will be created in the
URLOT-Configfolder.
Of course you can change the URLOT-Object maually by the usual OS/2 method

DEINSTALLATION
Just delete the URLOT-Folder. That should do it.

HOW DOES IT WORK?
Basically URLOT opens the URL-Object file and read the contents.
Then the program will be started with the 'start'-command
If you look at the URLOT.cmd-feile you will see

TIP
I seperate ProgramURL and InternetURL with a #. So you can use Blanks
And you can use all the Parameters of the 'start'-command.
For Example: /C WGET.EXE -c#ftp://hobbes.nmsu.edu/pub/incoming/URLOT.ZIP


DISCLAIMER
You use this software on your own risc. I am not responsible for any damage
This Software is distributed under the GNU Lizence

AUTHOR
Norbert Kohl
norbert.kohl@gmx.de

