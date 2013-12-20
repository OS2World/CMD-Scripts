/* REXX script to read icequote files */
/* and attach them to PMMail e-mails  */
/* (c) 1997 Ahmad Al-Nusif            */
/*          morpheus@moc.kw           */
/*               ___        _____              ______           */
/*              |_ _|___ __|_   _|_ _  __ _   / /___ \          */
/*               | |/ __/ _ \| |/ _` |/ _` | / /  __) |         */
/*               | | (_|  __/| | (_| | (_| |/ /  / __/          */
/*              |___\___\___||_|\__,_|\__, /_/  |_____|         */
/*                                    |___/                     */
/*                                                      V 2.6   */
/*--------------------------------------------------------------*/

/*               _   _               ___      _                 */
/*              | | | |___ ___ _ _  / __| ___| |_ _  _ _ __     */
/*              | |_| (_-</ -_) '_| \__ \/ -_)  _| || | '_ \    */
/*               \___//__/\___|_|   |___/\___|\__|\_,_| .__/    */
/*                                                    |_|       */


/* Do you want to confirm each quote before it is applied to an
   outgoing e-mail? (0=NO - 1=Yes)                              */

Confirm=0

/* Do you want a string inserted before each quote?             */
/* (0=NO - 1=Yes)                                               */

insert_prefix=0

/* If you want a prefix other than the one below, change the
   value between the quotes.                                    */

prefix="... "

/* Do you want a newline inserted before the quote?             */
/* (0=NO - 1=Yes)                                               */

insert_newline=0

/* Do you want to replace the X-Mailer line in your header?     */
/* (0=NO - 1=Yes)                                               */

replace_xmailer=0

/* If answered YES to the above question then you can change the
   change the value below to something you prefer to replace the
   X-Mailer line with. Leaving nothing between the quotes removes
   the X-Mailer line completely.                                */

new_XMailer=""

/*--------------------------------------------------------------*/
/* End of User Setup section                                    */
/* Please don't change anything below this line                 */

Parse Arg destfile


tempfile = left( destfile, length( destfile ) - 4)


i=1

do while lines( destfile ) > 0
   line = linein( destfile )
   if word( line, 1 ) = 'X-Mailer:' then
     do
        if \ replace_xmailer then
           do
                rc=lineout(tempfile, line);
                if i then do
                  rc=lineout(tempfile, 'X-Tag: <| IceTag/2 v2.6 |> by Ahmad Al-Nusif (morpheus@moc.kw)')
                  end /* if i */
                i=0
           end /* if \ replace */
        if replace_xmailer then
           do
                if new_xmailer\= "" then rc=lineout(tempfile,new_XMailer)
                if i then do
                   rc=lineout(tempfile, 'X-Tag: <| IceTag/2 v2.6 |> by Ahmad Al-Nusif (morpheus@moc.kw)')
                   end /* if i */
                i=0
           end /* if replace */
        end /* if word */
   else rc=lineout(tempfile,line)
end

rc=stream(destfile, 'c', 'close')
rc=stream(tempfile, 'c', 'close')

'@copy' tempfile destfile '>nul'
'@del' tempfile '>nul'

/* if the file you're using is different, change the name below */
File='pqf4.quo'
Index="pqf4.idx"

call rxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call sysloadfuncs


call ReadIndex

Main:
pick = RANDOM(1, nq2)   /* choose a random quote */
pick2=(pick*2)-1        /* calc stem index of starting line */
mark=quotes.pick2 +1    /* get line number in the quote file */
pick3=pick*2            /* calc stem index of the length (in lines) of the quote */
count=quotes.pick3      /* get the number of lines of the quote */

/* advance to the desired position in a file by reading all the rest */
/* which was my intention to do without from the start */
/* but I couldn't find a REXX function that takes as an argument */
/* a line number and number of lines to return them in a stem */


rc=stream(destfile,'c','open write')
rc=stream(file,'c','open read')
rc=stream(file,'c','seek ='mark)

dummy="             "

if insert_newline then rc=lineout(destfile,dummy);


i=0
do while count\='0'
   tmp=linein(file)
   count=count-1
   i=i+1        /* i is the index of the stem that holds the quote lines */
   if count='0' then do
      test=pos('#',tmp)
      tmpline2=left(tmp,test-1)
      tmp=tmpline2
      end
   quotelines.0=i
   quotelines.i=tmp
end

rc=stream(file,'c','close')

i=0



if \ confirm then do
        if insert_prefix then rc=charout(destfile,prefix);
        do quotelines.0
                i=i+1
                rc=lineout(destfile,quotelines.i)
                end
end /* if */

if confirm then do
say ""
i=0
if insert_prefix then rc=charout(,prefix)
do quotelines.0
        i=i+1
        say quotelines.i
        end
say ""
Say "Do you feel that this quote is appropriate (Y/N) ?"
parse upper pull response

select
        when (response='Y' | response='YES') then do
                i=0
                if insert_prefix then rc=charout(destfile,prefix);
                do quotelines.0
                        i=i+1
                        rc=lineout(destfile,quotelines.i)
                        end
                end
        when (response='N' | response='NO') then do
                say
                say "Choosing another quote..."
                say
                call Main
                leave
                end
end /* select */
end /* if confirm */

exit

ReadIndex:
          nq=0  /* The number of quotes x2 */
          do while lines(index)>0
             nq=nq+1
             quotes.0=nq
             quotes.nq=linein(index)
           end
           nq2=(nq)/2
return
