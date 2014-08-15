/* rexx */
/* this will create an easel listing file to stdout */
/* trace results*/
ARG filenam.1

/*------------------------------------------------------------*/
/*   CHECK IF ARGUMENT WAS ENTERED, IF NOT REQUEST FILE NAME  */
/*------------------------------------------------------------*/
IF LENGTH(filenam.1) = 0 THEN
   DO
   SAY 'ENTER DRIVER FILE NAME: '
   PULL filenam.1
   END

pad = "000"
filenumber = 1
lines.1 = 0
fileptr = 1
filedone.1 = "no"
numberofsubs = 0
CRLF = D2C(13) || D2C(10)    /* setup crlf string */

/*------------------------------------------------------------*/
/* DO UNTIL EOF                                               */
/*------------------------------------------------------------*/
INREC = LINEIN(filenam.1)
DO while filedone.1 = "no"
   do while filedone.fileptr = "no"         /*lines(filenam.fileptr) > 0*/
      lines.fileptr = lines.fileptr + 1     /* increment line counter
                                               for current file         */
      if fileptr < 10 then                  /* adjust spacing for file  */
         filestring = "0" || fileptr
      else
         filestring = fileptr

      linestring = lines.fileptr            /* setup header string      */
      linestring = substr(pad,1,(4 -length(linestring))) || linestring
      CurrentLine = filestring || "." || linestring || " " || INREC
      say CurrentLine    /* put the line w/ number to stdout */

      if (CheckforVar('include "')) then
         call ProcessInclude
      if (CheckforVar('subroutine ')) then
         call ProcessSubroutine
      if (CheckforVar('call ')) then
         call ProcessCall

      if (insub = 'yes') then       /* in process of subroutine */
         if (CheckforVar(')')) then  /* end of sub dec */
            do
               insub = 'no'
               if (CheckforVar(' is')) then  /* found definition */
                  def.foundsub = def.foundsub substr(CurrentLine,1,8)
               else                          /* found declaration */
                  dec.foundsub = dec.foundsub substr(CurrentLine,1,8)
            end


      if lines(filenam.fileptr) = 0 then     /* done w/ this file */
         filedone.fileptr = "yes"
      else
         INREC = LINEIN(filenam.fileptr)

   end   /* while current file */
   filedone.fileptr = "yes"
   junk = lineout(filenam.fileptr)   /* close the file */
   fileptr = fileptr - 1
   INREC = LINEIN(filenam.fileptr)   /* get the next previous file */
end

/*******************************/
/*  now create the xref report */
/*******************************/
say ""
say "***-----------***"
say "*   File Xref   *"
say "***-----------***"
say
do X = 1 to filenumber
   if X<10 then
      say "0" || X || " " || filenam.X
   else
      say X || " " || filenam.X
end
say
say "***-------------***"
say "* Subroutine Xref *"
say "***-------------***"
say
do Y = 1 to numberofsubs
   say 'sub:' sub.Y
   say 'dec:' dec.Y
   say 'def:' def.Y
   say 'cal:' cal.Y
   say
end
exit

/* search for the name of the subroutine for xref */
SearchSub:
   foundsub = 0
   if (numberofsubs > 0) then
      do x=1 to numberofsubs
         if sub.x = subname then
            do
               foundsub = x
               leave
            end
      end
   if foundsub = 0 then
      do
         numberofsubs = numberofsubs + 1
         foundsub = numberofsubs
         sub.numberofsubs = subname
         def.numberofsubs = ""
         dec.numberofsubs = ""
         cal.numberofsubs = ""
         calwidth.numberofsubs = 6
      end
   return 0

/* get the subroutine name to search and set insub to yes to continue
    processing until ')' found */
ProcessSubroutine:
   subsearch1 = 'subroutine '
   subsearch2 = '('
   parse var INREC (subsearch1) subname (subsearch2) junk
   subname = word(subname,1)
   call SearchSub
   insub = 'yes'
   /* foundsub = index number */
   return 0

/* get the subroutine name to search and xref */
ProcessCall:
   callsearch1 = 'call '
   callsearch2 = '('
   parse var INREC (callsearch1) subname (callsearch2) junk
   subname = word(subname,1)
   call SearchSub
   /* foundsub = index number */
   cal.foundsub = cal.foundsub substr(CurrentLine,1,7)
   calwidth.foundsub = calwidth.foundsub + 8
   if (calwidth.foundsub) > 77 then   /* set word wrap */
      do
         cal.foundsub = cal.foundsub || CRLF || "     "
         calwidth.foundsub = 6
      end
   return 0

/* setup next file for include */
ProcessInclude:
   incsearch = 'include "'
   parse var INREC (incsearch) incfile
   incfile = word(incfile,1)
   incfile = substr(incfile,1,(length(incfile)-1))
   if (LINES(incfile) > 0) then
      do
         say ""
         say "***---------------------***"
         say "*   " incfile
         say "***---------------------***"
         say " "
         filenumber = filenumber + 1
         filedone.filenumber = "no"
         fileptr = filenumber
         filenam.filenumber = incfile
         lines.fileptr = 0
      end
   return 0

/* search for occurance of searchval and return 1 or 0 */
CheckforVar:

PARSE ARG searchval

   incfile = ""
   PARSE VAR currentline comment '"' rest  /* get rid of quoted strings! */
   comment = comment || '"'
   PARSE VAR comment front '#' rest        /* get rid of comments! */

   if (SUBSTR(searchval,1,1) <> "#") then
      PARSE VAR front testsearch (searchval) junk
      if (LENGTH(testsearch) = LENGTH(front)) then
         return 0
      else
         return 1

