/* Compares current directory to zip file.		  */
/* Deletes files that no longer exist after confirmation. */

UsePKZip = 1

parse arg Name
if Name='' then do
  say "Usage: ZipStrip <zip-filename>"
  say "Compares current directory to zip file."
  say "Deletes files that no longer exist after confirmation."
  exit(1)
end

if Stream( Strip(Name,,'"'), 'C', 'QUERY EXISTS' ) = '' then do
  say Name "not found."
  exit 1
end

if UsePKZip = 1 then
  '@pkunzip -v' Name '| rxqueue /fifo'
else
  '@unzip -v' Name '| rxqueue /fifo'

len = ''
do while len \= 'LENGTH'
  pull WholeLine
  parse var WholeLine len . . . . . . FieldName .
end
pull Underline

do i=1 to queued()
  pull WholeLine
  parse var WholeLine len . . . . . . File.i .
  if len = '------' then
    count = i-1
  else
    File.i = Strip(File.i,,'^')
end
if Abbrev(FieldName, "NAME") = 0 then do
  say "I don't understand this format.  Name field's title is" FieldName
  exit(1)
end

z = 0
do i=1 to count
  if Stream( File.i, 'C', 'QUERY EXISTS' ) = '' then do
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
  if Abbrev(okay,'Y') then do
    if UsePKZip = 1 then
      '@pkzip -d' Name Strip(DeleteList)
    else
      '@zip -d' Name Strip(DeleteList)
  end
  else
    say "Aborting ->" okay
end
