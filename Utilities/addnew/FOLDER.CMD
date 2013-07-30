/* REXX instructions to create a new folder object on the WPShell */
/* Written by Paul Serice serice@sprynet.com (if you have any problems) */

/* First, you need to extend the basic REXX function calls to include the one you need */
/* However, the function you want may already be loaded. */

HadToAdd=0
IF RxFuncQuery("SysCreateObject")  /* returns TRUE if NOT registered */
   THEN DO
      call RxFuncAdd "SysCreateObject","RexxUtil","SysCreateObject"
      HadToAdd=1
    END

count=1
name="New Folder Object"
done=0

DO UNTIL done
  CALL SysCreateObject "WPFolder",name,"<WP_DESKTOP>"
  IF result=0 THEN  /* apparently, "result" is a built in variable (?) */
     DO
        name="New Folder Object:"||count
        count=count+1
     END
  ELSE done=1
END

IF HadToAdd THEN call RxFuncDrop("SysCreateObject")