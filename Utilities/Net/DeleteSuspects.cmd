/* */
/************************************************
5-8-01 jjs  Use to find sessions that meet the criteria for
            causing net3101, then delete those session unless
            they have open files.
            EzPage the lists.
*************************************************/

'd:'
'cd \net3101'
'md Logs'
'md Logs\'date('s')

/***** Start of NEW DELETE SECTION ********/
   '@rxqueue /clear'
/*   'call net sess | find /i " 00:0" | find /i "                         OS/2 LS 3.0" | find /i "  0  " | rxqueue' */
   'call net sess | find /i " 00:0" | find /i "                         OS/2 LS 3.0" | rxqueue'
   s=0
   do queued()
     pull data
     if data<>'' then do
        s=s+1
        pcdata.s=data
        pcname.s=strip(word(data,1))
       '@echo 'date('s')' 'left(time(),5)' 'pcdata.s'  >> Logs\'date('s')'\SuspectList.txt'
        end 
     end /* queued */
    totalS=s
    s=0
    d=0
    n=0
    NoDelete=''
    DeleteNames=''
    do totalS
      s=s+1
      if pos("  0  ",pcdata.s)<>0 then do
        d=d+1
        DeleteNames=DeleteNames' 'strip(pcname.s,L,'\')
        '@echo 'date('s')' 'left(time(),5)' 'pcdata.s'  >> Logs\'date('s')'\DeleteList.txt'
        'call net sess 'pcname.s' /delete'
        end
      else do
        n=n+1
        NoDelete=NoDelete' 'strip(pcname.s,L,'\')
        '@echo 'date('s')' 'left(time(),5)' 'pcdata.s'  >> Logs\'date('s')'\NoDeleteList.txt'
        end
      end /* totalS */
   /* if DeleteNames<>'' then 'call ezpage pcserver Net3101 problem Deleted 'deletenames */
   say 'Deleted 'deletenames
   /* if NoDelete<>'' then 'call ezpage pcserver Net3101 problem Did NOT Delete 'nodelete */
   say 'Did NOT Delete 'nodelete

/*****   End of NEW DELETE SECTION ********/


EXIT
