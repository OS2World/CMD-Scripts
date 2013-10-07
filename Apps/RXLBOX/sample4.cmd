/* ------------------------------------------------------------------ */
/*                                                                    */
/*             sample program to show the use of RXLBOX               */
/*                                                                    */
/*            This program uses the menu file RXLBOX.MEN              */
/*                                                                    */
/* ------------------------------------------------------------------ */

                    /* init some constants                            */
  menuProgName = 'RXLBOX.CMD' 
  menuFileName = 'RXLBOX.MEN'


                    /* search the program and the menu file.          */
                    /* The routine SearchProgramAndFiles sets the     */
                    /* variables MENUFILE, MENUPROG and MENUPROGPATH. */
  call SearchProgramAndFiles

  say 'Now calling ' 
  say ' ' menuProg 
  say 'with the menu file  ' 
  say ' ' menuFile 
  say 'and some further parameter to set the initial menu stack ...'

                    /* temporary change the PATH                      */
                    /* (external REXX routines must be in a directory */
                    /*  in the PATH!)                                 */
  oldPath = value( 'PATH', , 'OS2ENVIRONMENT'  )
  call value 'PATH', menuProgPath || ';' || oldPath, 'OS2ENVIRONMENT'

                    /* init the variable for the dynamic menu         */
  call value 'number', '0', 'OS2ENVIRONMENT'

                    /* set the parameter with the entries for the     */
                    /* initial menu stack                             */

  InitialMenuStack = 'MainMenu,  Menu4,  Menu2,  REXXCmdMenu,' || ,
                     'OS2CmdMenu,This is a hidden menu,' || ,
                     'This is a [menu] with a long section name,' || ,
                     'Menu7'

  userInput = RxLBox( menuFile, initialMenuStack )


                    /* restore the PATH                               */
  call value 'PATH', oldPath, 'OS2ENVIRONMENT'

  say ''
  say 'The result of RXLBOX is: "' || userInput || '"'
exit

/* ------------------------------------------------------------------ */
/* sub routine to search RxLBox.CMD & RxLBox.Men                      */

SearchProgramAndFiles:

                    /* search the program RXLBOX.CMD                  */
  menuProg = directory() || menuProgName
  if stream( menuProg , 'c', 'QUERY EXIST' ) = '' then
  do
    parse source . . thisProgram
    menuProg = fileSpec( 'D', thisProgram ) || ,
               fileSpec( 'P', thisProgram ) || ,
               menuProgName
  end /* if stream( menuProg , 'c', 'QUERY EXIST' ) = '' then */

  if stream( menuProg , 'c', 'QUERY EXIST' ) = '' then
  do 
    say 'Error: ' || menuProgName || ' not found!'
    exit 255
  end  /* if stream( menuProg , 'c', 'QUERY EXIST' ) = '' then */
  else
    menuProgPath = fileSpec( 'D', menuProg ) || ,
                   fileSpec( 'P', menuProg )


                    /* search the menu file RXLBOX.INI                */
  menuFile = directory() || menuFileName
  if stream( menuFile , 'c', 'QUERY EXIST' ) = '' then
  do
    parse source . . thisProgram
    menuFile = fileSpec( 'D', thisProgram ) || ,
               fileSpec( 'P', thisProgram ) || ,
               menuFileName
  end /* if stream( menuFile , 'c', 'QUERY EXIST' ) = '' then */

  if stream( menuFile , 'c', 'QUERY EXIST' ) = '' then
  do 
    say 'Error: ' || menuFileName || ' not found!'
    exit 255
  end  /* if stream( menuFile , 'c', 'QUERY EXIST' ) = '' then */

RETURN

