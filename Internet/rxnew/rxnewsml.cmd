/* This is the RexxNews Mail program - this rexx command uses sendmail
   to send a mail message out and then erases the file when it's finished.
*/
parse arg tempfile sender recipient
"sendmail -af "tempfile "-f" sender recipient
"erase "tempfile
"exit"
