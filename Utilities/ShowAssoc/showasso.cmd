 /*                                                                    */
 /* Sample program to display a list of the associations               */
 /*                                                                    */
 /* Usage: ShowAsso {>logfile}                                         */
 /*                                                                    */
 /*                                                                    */
 /* Note:  This program needs Henk Kelders excellent DLL WPTOOLS.DLL!  */
 /*                                                                    */
 /*        Tested under OS/2 WARP Connect. May not work under other    */
 /*        OS/2 versions!                                              */
 /*                                                                    */
 /* History                                                            */
 /*   14.01.1996 v1.00 /bs                                             */
 /*     - initial release (for RXT&T v2.00)                            */
 /*                                                                    */
 /* (c) 1996 Bernd Schemmer, Germany, EMail: 100104.613@compuserve.com */
 /*                                                                    */
 
                     /* turn on the NOVALUE condition                  */
   signal on NOVALUE
 
                     /*  load REXXUTIL functions                       */
   call rxFuncAdd "SysLoadFuncs", "REXXUTIL", "SysLoadFuncs"
   call SysLoadFuncs
 
                     /* get all filter associations                    */
   thisRC = SysIni( "USER", "PMWP_ASSOC_FILTER", "ALL:", "assoc_filter" )
 
                     /* get all type associations                      */
   thisRC = SysIni( "USER", "PMWP_ASSOC_TYPE", "ALL:", "assoc_type" )
 
 
   call lineOut , "Associations by filter"
   call LineOut , "======================"
   call LineOut , ""
 
                     /* display filter associations                    */
   do i = 1 to assoc_filter.0
     curFilter = assoc_filter.i
     curHandle = SysIni( "USER", "PMWP_ASSOC_FILTER", curFilter )
 
     select
 
       when curHandle = "ERROR:" then
         call lineOut , "  " || curFilter || ,
                        ": Error retrieving the value for this key!"
 
       when curHandle = "00"x then
         call lineOut , "  " || curFilter || ,
                        ": No association for this filter."
 
       otherwise
       do
         call CharOut , "  " || curFilter || ": "
 
         cur2Indent = length( curFilter ) + 4 +2
         curIndent = 0
 
                     /* show the data of the associated objects        */
         do until curHandle = ""
 
                     /* handle multiple associations                   */
           parse var curHandle curSubHandle "00"x curHandle
           call ShowObjectData "#" || d2x( curSubHandle ) ,,
                               cur2Indent, curIndent
           curIndent = cur2Indent -2
         end /* until curHandle = "" */
 
       end /* otherwise */
 
     end /* select */
     call LineOut , ""
 
   end /* do i = 1 to assoc_filter.0 */
 
   call lineOut , "Associations by type"
   call LineOut , "===================="
   call LineOut , ""
 
                     /* display filter associations                    */
   do i = 1 to assoc_type.0
     curType = assoc_type.i
     curHandle = SysIni( "USER", "PMWP_ASSOC_TYPE", curType )
 
     select
 
       when curHandle = "ERROR:" then
         call lineOut , "  " || curType || ,
                        ": Error retrieving the value for this key!"
 
       when curHandle = "00"x then
         call lineOut , "  " || curType || ,
                        ": No association for this type."
 
       otherwise
       do
         call CharOut , "  " || curType || ": "
 
         cur2Indent = length( curType ) + 4 +2
         curIndent = 0
 
                     /* show the data of the associated objects        */
         do until curHandle = ""
                     /* handle multiple associations                   */
           parse var curHandle curSubHandle "00"x curHandle
           call ShowObjectData "#" || d2x( curSubHandle ) ,,
                               cur2Indent, curIndent
           curIndent = cur2Indent -2
         end /* until curHandle = "" */
 
       end /* otherwise */
 
     end /* select */
     call LineOut , ""
 
   end /* do i = 1 to assoc_type.0 */
 
 exit
 
  * -------------- insert the routines from the section -------------- *
  *                  General routines for the samples                  *
  * ----------------------------- here! ------------------------------ *
 