/* REXX script to read icequote files */
/* and attach them to PMMail e-mails  */
/* (c) 1997 Ahmad Al-Nusif            */
/*          morpheus@moc.kw           */
/*		Version 2.6	      */

Parse Arg destfile
'@echo off'

/* if the file you're using is different, change the name below */
File='pqf4.quo'
Index="pqf4.idx"
call rxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call sysloadfuncs


call SysFileDelete index
call IndexIt
rc = LineOut(,"Done. The file produced is "index)

IndexIt:
            charcount='0'
	    cnt = '0'
	    line='0'
	    tlines='0'
            do While Lines(File) > 0
		rc=lineout(index,charcount)
			/* i think it's counting the CR+LF at the end of each line */
               do forever
		  line=line+1
		  /* tlines=tlines+1 */
                  tmpline=LineIn(File)
		  charcount=charcount+length(tmpline)
                  test=pos('#',tmpline)
                  if test\='0' then do
			rc=lineout(index,line)
			charcount=charcount+(line*2)
			line='0'
			leave
                     end
                end
            end
return

CountLines:
            count = 0
            do While Lines(File) > 0
               count = count + 1
               tmp=linein(file)
            end
return
