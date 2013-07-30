                           WHAT THESE SCRIPTS DO

They  allow you to setup the desktop's menu so that you only need to right
click on the desktop to get a new folder or program object without  having
to rummage through the templates folder.  Also, if you want to create more
than one new object,  these scripts will automatically modify the name  of
the newest object thus avoiding a name collision.


                               INSTALLATION:

Just put these files in whichever directory you like.

Then modify the desktop menu by right clicking on  the  desktop  and  then
selecting  "Settings" and then "Menu".   This brings up the page that lets
you make the desired modifications.   This page is broken  down  into  two
parts:   a  top part and a bottom part.   The top part lets you create new
submenus on the desktop's menu.   The bottom part lets you add programs or
REXX scripts to the submenus.

THE TOP PART:  Select the top "Create another...", and where it says "Menu
name:", type in "~New".  Then click on OK.   If you look in the top yellow
box, you will see that "~New" has now been added as a submenu.  Now, click
on "~New" in the yellow box to highlight it so that OS/2 will  know  which
submenu you want to modify.

THE  BOTTOM  PART:   The  easiest way to add the two scripts to the "~New"
submenu is by dragging and dropping the icons that  represent  the  script
into  the  bottom  yellow  box.    If  you  want to use the bottom "Create
another..."  you're on your own, but it looks easy enough.

Your now done.   If you don't like the way your menus look,   play  around
with  the  "Settings..."   dialogue.   Personally,  I have a "New" submenu
which brings me  to  two  options  called  "Folder  Object"  and  "Program
Object".

IMPORTANT:   If you want this to be seamless,  then you need to modify the
REXX scripts' objects so that the scripts start minimized and so that they
close their windows on exit.  This is easy enough to do.  Just right click
on the exact same icons you dragged and dropped into the yellow box.  Now,
select "Settings" and then "Session".  Check the appropriate options.

DISCLAIMER: Use at your own risk.

Paul Serice
serice@sprynet.com
