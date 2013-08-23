/* CHNGBCKG.CMD - Change Warp Background Bitmap randomly */
/* Please email comments to pauls@xanax.apana.org.au */
/* Change this to the directory, where your ZIPped BMP's are stored but   */
/* you MUST include the final backslash!           */
BACKDIR = 'e:\utilities\pmjpeg\backgrounds\'

/* Change this to whatever drive you boot from     */
BOOTDRIVE = 'd:'

call RxFuncAdd "SysLoadFuncs", "RexxUtil", "SysLoadFuncs"
call SysLoadFuncs

call SysFileTree BACKDIR'*.zip', "bckgr.", "O"
   i = random(1,bckgr.0)
   'unzip 'bckgr.i
call SysFileTree BACKDIR'*.bmp', "bmp.", "O"
   /* t = random(1,bmp.0) */
   'copy 'bmp.1' 'BOOTDRIVE'\os2\bitmap\os2backg.bmp'
   'del *.bmp' 
exit
