/* Compares current directory to zip file.		  */
/* Deletes files that no longer exist after confirmation. */

arg Name
if Name='' then do
  say "Usage: ZipStrip <zip-filename>"
  say "Compares current directory to zip file."
  say "Deletes files that no longer exist after confirmation."
  exit(1)
end

if LENGTH(CHARIN(Name,1,1)) \= 1 then do
  say Name "not found."
  exit(1)
end
call CharOut(Name)
  
'@unzip -v' Name '| rxqueue /fifo'

pull . . . . . . . FieldName .
pull Underline

do i=1 to queued()
  pull WholeLine
  parse var WholeLine len . . . . . . File.i .
  if len = '------' then
    count = i-1
end
if Left(FieldName,4) \= "NAME" then do
  say "I don't understand this format.  Name field's title is" FieldName
  exit(1)
end

z = 0
do i=1 to count
  if Length(CHARIN(File.i,1,1)) \= 1 then do
    z = z+1
    Deleted.z = File.i
  end
end

if z = count then do
  say "None of the files in the archive exist.  Are you in the right directory?"
  exit(1)
end

if z>0 then do
  DeleteList = ''
  do i=1 to z
    DeleteList = DeleteList Deleted.i
  end
  say "Preparing to remove:" DeleteList
  Call CharOut ,"Okay? "
  parse upper pull okay
  if Left(okay,1)='Y' then do
    '@zip -d' Name Strip(DeleteList)
  end
  else
    say "Aborting ->" okay
end
