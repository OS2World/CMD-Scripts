/*****************************************************************************/
/* Intelligent E                             (c) 1993 by Carsten Wimmer      */
/* For use with Rexx/2                                   cawim@train.fido.de */
/*****************************************************************************/
/* This is a small rexx script that blows some intelligence into the         */
/* system editor of OS/2. I always hated E for asking me to associate        */
/* a file type. This script takes care of the file type and prevents E       */
/* from asking anymore.                                                      */
/* Send suggestions and bug-reports to my email address.                     */
/*****************************************************************************/

/* Load the system functions */
Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs

/* Get the filename from the command-line and convert it to upper case */
parse upper arg file

/* Save the extension for later reference (only if there is one!) */
if length(file) > 4 then do
  len = length(file)-4
  ext = delstr(file, 1, len)
end
else ext = "foobar"       /* No extension. It's a plain text! */

/* If there is already an associated file type, skip the rest */
call SysGetEA file, ".TYPE", "typeinfo"
parse var typeinfo 11 oldtype
if oldtype == "" then do

/* Set file type according to the extension */
  if ext = ".CMD" then newtype = "OS/2 Command File"
  else if ext = ".BAT" then newtype = "DOS Command File"
       else newtype = "Plain Text"

/* Create EA data */
  EAdata = 'DFFF00000100FDFF'x || d2c(length(type)) || '00'x || newtype
/* Write EA data to the file */
  call SysPutEA file, ".TYPE", EAdata
end

/* Finally, start E */
'start "E" /fg c:\os2\e.exe' file

/* EOF */
