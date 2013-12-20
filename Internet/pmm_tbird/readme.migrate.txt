    MIGRATION SCRIPTS FOR MOVING FROM PMMAIL TO THUNDERBIRD


This package contains two Rexx scripts for the use of PMMail users
who wish to move their mail to Thunderbird (the e-mail offshoot
from the Mozilla project).  One script copies your PMMail
mail to the format used by Thunderbird, and the other converts your
address books.  None of the PMMail files are altered or destroyed;
you can delete those files after you're convinced that you really
wanted to switch to Thunderbird, but meanwhile the files are there
in case you change your mind and switch back.

The migration isn't completely automatic - for example, signatures
aren't migrated - but it takes you to the point where you can
finish the job manually.  You have my permission to use these
scripts as the starting point for a more ambitious project that
automates everything.  I don't intend to take this project any
further myself, because once the mail is migrated I don't need to
do the job again.


AUTHOR INFORMATION

     Author: Peter Moylan
     e-mail: peter@ozebelg.org
     web:    http://www.pmoylan.org

(There is more useful software at my web site.)


DISCLAIMER

These scripts worked for me.  I hope they work for you, but I don't
guarantee it.  Different software versions, different installation
options, or different personal settings could invalidate the assumptions
I made.  You might find that you have to modify the Rexx code in order
to handle your setup.  (That's why I did the job in Rexx.)

Make sure, in any case, that you back up your copies of both PMMail
and Thunderbird before starting.  You will not be happy if you lose
your mail.  My liability in case something goes wrong is limited to
what you paid me for this software; i.e. nothing.


BEFORE YOU START

When copying the mail you will have to know the name of the PMMAIL
directory (the directory that contains PMMAIL.EXE).  Make a note of
it now.  While you're there, go to the SOUTHSDE\TOOLS directory, find
the files called ADDR.DB and BOOKS.DB, and copy those two files to
the directory that contains the two scripts you are going to use.

Most importantly, check that you will have enough disk space to hold
the new copy of all your mail.  Using any suitable file manager, see
how much disk space is used by the PMMAIL directory and its
subdirectories.  (You might be surprised at how big the answer is.
I know I was.)  Then find - probably in CONFIG.SYS - the specification
of the environment variable MOZILLA_HOME.  That tells you the drive
where the migrated mail is going to go, and you need about as much
free space on that drive as is taken up by the PMMAIL directories.
If you don't have enough free space, you'll probably have to pick
another MOZILLA_HOME, and then reboot and make sure that the Mozilla
programs are working properly in the new home.  Get this correct
before starting the migration.


CREATING A DUMMY THUNDERBIRD ACCOUNT

The migration scripts are not able to create a Thunderbird account
(I couldn't fully decode the format of some of the files), so you'll
have to do that manually.  Start Thunderbird, and from the File
menu select New->Account.  Follow the prompts to create a new
e-mail account that uses POP.  This is going to be a throwaway
account that you will probably delete after doing the migration, so
the account details (server name, username, etc.) can be given
imaginary names.  Make a note of the account name (specified at the
final step), and the imaginary POP server name, because one of these
(depending on which version of Thunderbird you're using) will identify
the directory that you'll have to use during the migration.

Leave Thunderbird running for the next step.


MIGRATING THE ADDRESS BOOKS

This is the easy part.  You are going to use the script PMMAB_CSV.CMD
from the present package, and the files ADDR.DB and BOOKS.DB from
the PMMAIL TOOLS directory.  If you've been following the instructions
so far, you already have these three files in the same directory.
The script can accept two parameters to specify a source
and result directory, but it's easiest to run it without parameters,
in which case it will assume the current directory.

Run that script.  It will create several *.CSV files, one for each
of your address books.

Now go to Thunderbird, and on the Tools menu choose the Import
option.  Follow the "Next" options until you get to a file selection
menu.  Using this, choose the first of your *.CSV files.  (You
might have to change the "Restrict files to" option to specify that
you're looking for CSV files.)  Next you will come to a window
listing a lot of address book fields.  Leave all the options
unchanged, and select the OK button.  Finish the operation.  To
check that it worked, open the address book and confirm that the
desired entries have indeed been imported.

Then repeat that operation for all of your *.CSV files.


COPYING ALL THE OLD MAIL

This next part will be very slow, because there will probably be
many thousands of files to copy.  You might find that it's easiest
to do this run overnight.  In my case, I had so much mail that I
had to leave it running for almost 24 hours.  I have since updated
the script to let you migrate only a subset of the PMMail accounts,
so that you can do the migration a little bit at a time,
but the big accounts are still going to take a long time.

Run the script PMM_TBIRD.  It will ask you for two directory
names, one for your PMMAIL directory and one for a temporary
directory to hold the migrated mail.  The default for the temporary
directory is a subdirectory 'TempDir' within the Thunderbird
directory structure, and this will probably already be suitable
without your having to alter it.  The PMMAIL directory, on the other
hand, will probably have to be entered manually, because I can't
guess where you have PMMail installed.

Depending on how much mail you have, this script could take a
very long time to run.  Just let it run overnight, or in the background
while you're working on other things.  You can safely use Thunderbird
while this is happening.  You can probably also use PMMAIL, although
there's a risk of a file conflict if you're accessing a file that
the script is also trying to access.  There's also the risk of some
mail not being migrated because PMMAIL fetched it after the
migration script had finished dealing with that Inbox.

[Many hours later]

When the script has finished running, close Thunderbird.  You now
have to manually move some files, and you have to do it while
Thunderbird is NOT running.

Go to your Thunderbird Mail directory.  If you're not sure where it
is, you can find the path from the MOZILLA_HOME variable which is
probably in CONFIG.SYS.  As an indication of what the directory path
should look like, the directory name in my case is

    G:\MozProfiles\Thunderbird\Profiles\ioomzt8y.default\Mail

In that directory you will have one subdirectory per POP mail account,
and one of those accounts should be the dummy account that you created
for the purpose of this migration.  Open that subdirectory.  In my case
the new account has the name "h", which is the dummy account name I chose
for ease of typing.

The temporary directory used by the migration script - which, if you
accepted the default, should also be a subdirectory of the Thunderbird
mail directory - should also contain some files and some further
subdirectories, where the file names all correspond to PMMAIL account
names (say xyz), and the subdirectory names are all of the form xyz.sbd.
Select those files and sbd subdirectories, and move them all into
the "h" directory, or whatever name you chose for the dummy account.

Cross-check.  For each PMMAIL account you should be moving two
things: one zero-sized file xyz, and one directory xyz.sbd, where
xyz is the account name in PMMAIL.

[Why didn't the migration script put them into the right directory
in the first place?  Answer: I had trouble decoding some details of
the Thunderbird configuration files.  Also, I didn't want Thunderbird
to notice those new files until the migration script had finished
running.]

Now start Thunderbird again.  You should see a collection of new
folders containing the migrated mail.  The mail isn't necessarily
in the folders you really wanted it in, but from here on you can
move mail around using Thunderbird itself, until it's arranged
to your satisfaction.  You will notice that Thunderbird does some
extra initialisation work on each new folder when you first open
it.  For folders containing lots of mail, expect a time delay.

One trap to watch out for: I found that when I dragged a folder
from one Thunderbird account to another it did a copy rather
than a move, which can be confusing if you then forget to delete
the original.  Also, it seems that Thunderbird can hang if you
get impatient and try to start another operation before the
move is finished.  I lost several folders of mail before I realised
that I had to pause between the 'move folder' operations.

Remember that you still have another copy of all that mail in the
PMMAIL directories.  If you're certain that you're not going to
go back to PMMAIL, you can delete the originals.  If you're a
bit more cautious, but still want to save disk space, you can
use a zip utility to save all the old mail in a single archive.

Remember, too, that you still have a (possibly empty) temporary directory,
which for neatness you should delete.  In addition, you have a
new dummy Thunderbird account that you will probably want to delete
after you have moved its contents to 'real' mail accounts.  I've
found that Thunderbird does not physically delete the directories
when an account is deleted, so you'll have to manually delete all
the obsolete files.  (The Thunderbird designers seem to have adopted
the Microsoft approach of letting obsolete files accumulate, and
buying a new computer once the disk is full, but OS/2 users typically
don't work with such enormous disks.)

