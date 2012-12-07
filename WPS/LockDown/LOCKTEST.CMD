/********************************************************************
                                                         LOCKTEST.CMD

                                                      28 January 1998

                                                  by Kathleen L. Long
                                                        k2lan@aol.com

Simple REXX script to create a folder, complete with objectid, for
  test manipulation by LOCKDOWN.CMD

********************************************************************/

   icondir = directory()||'\LOCKDOWN.ICO'

   classname='WPFolder'
   title='LOCKDOWN.CMD^Test Folder'
   location='<WP_DESKTOP>'
   setup='OBJECTID=<WP_LOCKDOWN>;'||,
         'ICONFILE='||ICONDIR||';'||,
         'BACKGROUND=(none),,,C,255 222 255;'
 
   rc=SysCreateObject(classname,title,location,setup)

RETURN

