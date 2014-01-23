#define INCL_WINWORKPLACE
#include <os2.h>
#include <string.h>

HOBJECT openobj;
char *keystring="PARAMETERS=";
char paramstring[500];
char *space=" ";

main(int argc, char *argv[])
{
   int i;

   strcat(paramstring,keystring);
   if (argc>1) {

/* Get the object handle, the first argument on the list */

      openobj=(HOBJECT)(atoi(argv[1]));

/* All the remaining command line arguments will be put into paramstring */
/* and passed directly to the viewer.                                    */

      for (i=2;i<argc;i++) {
         strcat(paramstring,argv[i]);
         strcat(paramstring,space);
      }

/* We now put the parameter list into the PARAMETERS field of the program   */
/* object.  You can open up the object's settings and see the argument list */

      WinSetObjectData(openobj,paramstring);

/* This call tells OS/2 to open the object, this causes it to perform the */
/* default setting (which should start the program.                       */

      WinSetObjectData(openobj,"OPEN=DEFAULT");
   }
}



