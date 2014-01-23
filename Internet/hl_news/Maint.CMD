/*****************************************************************************/
/*                                                                           */
/* Maint displays the Sites List for HL_News  */
/*                                                                           */
/* Requires Personal REXX or REXXLIB (cursor, dosdir, inkey, parsefn,        */
/* doschdir, dosdrive, doscd, dosenv, scrread, scrput, scrsize, pcvideomode  */
/* functions) and RXWINDOW functions.                                        */
/*                                                                           */
/*                                                                           */
/*****************************************************************************/

call rxfuncadd 'RexxLibRegister','REXXLIB','rexxlibregister'
call RexxLibRegister
call rxfuncadd 'w_register', 'rxwin30', 'rxwindow'
call w_register





/* processing */
call initialize
curpos = cursor()
Call CursorType ,,0  /* remove cursor from screen */


/* Check sites drectory set up */

       rc=DosIsDIR('SITES')

              if rc<>1 then  do
               Quiet=1
          '@echo off'
         '@call HL_install.cmd 'Quiet
         '@echo on'
         end

rc=DosIsFile(sitesdir'site.list')
if rc<>1 then do
   call fileread 'site_list','mk_site.'
rc=filewrite(sitesdir'site.list','mk_site.','R')
/*rc=DosCopy('site_list',sitesdir'site.list','R')*/
if rc<>1 then return rc

end /* do */


call fileread sitesdir'site.list','sites.'
top = 1
 curline = 2
 /*do until rc=0*/
 height = scr_height - 5
width = 80
w = w_open(2,1,height+2,width,normal)
call w_border w,,,,,border

 do  forever
    call scrwrite 1,1,center('Headline News Maintenance',80),,,30 
rc=display() 
   if rc<>1 then do;call w_close w; leave;end
end
/* termination */
parse var curpos row col
call cursor row, col
return 1
exit


/* display the results in a window */
display:
type=0
if add.1>'' then do
nul_line.1=add.1
/*
if add.0>1 then call arraydelete 'add.',1,1
else add.1=''
*/
 if sites.1='' then do
    call arrayinsert 'add.','sites.',1,1
 end /* do */

end /* do */


do i=1 to sites.0
   parse var sites.i site .' ['com']'
   line.i=site '('com')'
   if sites.i='' then line.i=''
end /* do */
  count=sites.0
old_top = 0
newdir = 1
do forever
    if top \= old_top then
       call show
    old_top = top
    current = top + curline - 2
   call scrwrite scr_height-1,1, 'Keys: help f1 <PageUp> <PageDown> <> <> Ctrl<PageUp> Ctrl<PageDown> f2 Save', 80,,30
    if nul_line.1='' then call scrwrite scr_height,1,'f7 (Add <HR>: 'copies('Ä',20)') f4 Delete f5 Edit Name f9 Move Site f3 Exit',80,,normal
    else do
       parse var nul_line.1 site .' ['com']' 
   /* call scrwrite scr_height, 1,'F7 F8 Add: 'site '('com')', 80,,28*/
   call scrwrite scr_height, 1,'F7 F8 Add: ',80,,30
   sitlen=length(com)+length(site)+3
   call scrwrite scr_height, 13,site '('com')',sitlen,,reverse
     end
    newdir = 0
    key = inkey()
    select
       when key=pf1 then call showhelp

        when key = pf2 then do
           rc=filewrite(sitesdir'site.list','sites.','R')
           if rc<>1 then do

            dw = w_open(4,5,5,50,normal)
            call w_border dw,,,,,border
            call w_put dw, 2, 3, 'Save Site List failed! 'rc
             inkey()
            call w_close dw
              type=1

           end /* do */
            else type=0
            leave
            end
        when key = pf3 then
            leave

        when key = pf4 then do

            rc=call arraydelete('sites.',current,1)
            if sites.0<1 then do
                   addtop=1
                   addcurline = 2

                   rc=0
                  do  forever
                  
                  rc=add_sites() 
                  if rc<>0 then leave
                  end
                  if add.1='' then do
                     type=0
                     leave
                  end /* do */
                  else do
                     call arraycopy 'add.','sites.',1,1,1
                     call arraydelete 'add.',1,1
                  end /* do */
            end /* do */
                if curline =1 then curline= curline+1
                if current=count then curline=curline-1
            help_on=0
              type= 1
              leave
            
        end /* do */
        when key = pf5 then do
              if sites.current='' then iterate
             parse var sites.current site href' ['com']' 

            call edit site href com /* edit site*/
            new.0=1
            new.1=site href' ['com']'
           call arraycopy 'new.','sites.',1,current,1
                  help_on=0
                 type=1
                 leave
            end
            when key = pf6 then do

               if add.1>'' then do

                  dropadd=add.0
                  call arraydelete 'add.',1,dropadd
                  add.0=1
                  add.1=''
                  nul_line.1=''
            end /* do */
                addtop = 1
               addcurline = 2
                 rc=0
               /*do until rc=0*/
               do  forever

                  rc=add_sites() 
                  if rc<>0 then leave
                  end
                  help_on=0
                  type=1
                  leave
              end
        when key = pf7 then do

           
                if nul_line.1='' & current=count then iterate
                else do
              rc = call arrayinsert('nul_line.','sites.',1,current+1)
              if rc>0 then do           
                   if add.0>1 then call arraydelete 'add.',1,1
                   else add.1=''

                  if curline>19 then top=top+1                  
                  else curline=curline+1

                 nul_line.1=''
                 help_on=0
               type=1
               leave
               end
               end
               end
        when key = pf8 & nul_line.1\='' then do

              rc = call arrayinsert('nul_line.','sites.',1,current)
              if rc>0 then do           
                 if add.0>1 then call arraydelete 'add.',1,1
                 else add.1=''

                 nul_line.1=''
                 help_on=0
               type=1
               leave
               end
               end

        when key = pf9 then do
        if nul_line.1>'' then iterate
        nul_line.1=sites.current
        type=1
        rc=call arraydelete('sites.',current,1)
        leave
        end /* do */
        when key = down then do
            if current = count then
                iterate
            if curline <= height then do
                call w_attr w, curline, 3, width-4, normal
                curline = curline + 1
                current = top + curline - 2
                call highlight line.current, curline
                end
            else
                top = top + 1
            end
        when key = up then do
            if current = 1 then
                iterate
            if curline > 2 then do
                call w_attr w, curline, 3, width-4, normal
                curline = curline - 1
                current = top + curline - 2
                call highlight line.current, curline
                end
            else
                top = top - 1
            end
        when key = pgdn then do
            if count >= top + height
                then top = top + height
            if top + curline - 2 > count then
                curline = count - top + 2
            end
        when key = pgup then do
            if top - height > 0  then top = top - height
               
            else
                top = 1
            end
        when key = home then do
            top = 1
            curline=2
            type=1
            leave
            end

        when key = ctrlpgup then do
            top = 1
            end
        when key = endkey then do
            if count - height + 1 > 0
                then top = count - height + 1
                curline=height+1
                type=1
                leave
            end

        when key = ctrlpgdn then do
            if count - height + 1 > 0
                then top = count - height + 1
            end
        otherwise nop
        end
   end
return type


/* add some sites to site list*/
/*--- Add some sites ---*/
Add_sites:
/*sites.0=0*/
call w_hide w
choices.0=0
hits=0
 call fileread 'site_list','choices.'
 hits=choices.0
if sites.0>0 then do i=1 to sites.0
   if sites.i='' then iterate 
   parse var sites.i site href' ['.
  /* if choices.i='' then iterate*/
   dead=0
   found.1=0
   call arraysearch 'choices.','found.',site' 'href,'s'
   if found.1>0 then do;dead=found.1;call arraydelete 'choices.',dead,1 ;hits=hits-1;end
        end
if hits<1 then do/*; call popup  hits'all the sites are copied to the list'choices.0,1,'X' ;return ;end*/
dw = w_open(4,5,5,50,144)
call w_border dw
call w_put dw, 3, 3, center('No Sites to Add to Site List!',44)
call inkey
call w_close dw

call w_unhide w
return 1
end


add_count=1
height = scr_height - 5
width = 80
addw = w_open(2,1,height+2,width,normal)
call w_border addw,,,,,border

do forever

rc=add_display()
if rc=1 then do;call w_close addw; leave;end

end
call w_unhide w
return 1


/* display the results in a window */
add_display:
type=0
do i=1 to choices.0
   parse var choices.i site . com
   addline.i=site com
end /* do */

  count=choices.0
  
addold_top = 0
newdir = 1
do forever
    if addtop \= addold_top then
       call addshow
    addold_top = addtop
    addcurrent = addtop + addcurline - 2
   call scrwrite scr_height-1,1, 'Select all sites you wish to add then press <f3> to add sites to Site List', 80,,30 
    if newdir then
        call scrwrite scr_height, 1, 'Keys: <Enter> Add site <PageUp> <PageDown> <> <> Ctrl<PageUp> Ctrl<PageDown>', 80,,normal
    newdir = 0
    key = inkey()
    select
      /* when key=pf1 then call showhelp*/

        when key = enter then do
             if choices.0<1 then do;type=1;call w_close addw; leave;end
            /*nul_line.1=choices.addcurrent*/
            if add.1='' then rc= arraycopy('choices.','add.',addcurrent,add_count,1)
            else rc= arrayinsert('choices.','add.',addcurrent,add_count,1)
             if rc=1 then do
                add_count=add_count+1
                call arraydelete 'choices.',addcurrent,1
                if addcurline=1 then addcurline=addcurline+1
                if addcurrent=count then do; addtop=addtop-height
                   addcurline=2
                   if choices.0<1 then type=1
                end /* do */

             end /* do */
            leave
        end /* do */
        when key = pf3 then do
        type=1
            leave
            end

         when key = down then do
            if addcurrent = count then
                iterate
            if addcurline <= height then do
                call w_attr addw, addcurline, 3, width-4, normal
                addcurline = addcurline + 1
                addcurrent = addtop + addcurline - 2
                call addhighlight addline.addcurrent, addcurline
                end
            else
                addtop = addtop + 1
            end
        when key = up then do
            if addcurrent = 1 then
                iterate
            if addcurline > 2 then do
                call w_attr addw, addcurline, 3, width-4, normal
                addcurline = addcurline - 1
                addcurrent = addtop + addcurline - 2
                call addhighlight addline.addcurrent, addcurline
                end
            else
                addtop = addtop - 1
            end
        when key = pgdn then do
            if count >= addtop + height
                then addtop = addtop + height
            if addtop + addcurline - 2 > count then
                addcurline = count - addtop + 2
            end
        when key = pgup then do
            if addtop - height > 0  then addtop = addtop - height
               
            else
                addtop = 1
            end
        when key = ctrlpgup then do
            addtop = 1
            end
        when key = ctrlpgdn then do
            if count - height + 1 > 0
                then addtop = count - height + 1
            end

        otherwise nop
        end
   end
if choices.1='' then type=1
return type       



/* show a portion of the tree */
addshow:
call w_hide addw, 'n'
do i = 0 to height-1
    j = addtop + i
    if j>count then call w_put addw,i+2,3,copies(' ',width-6),width-4
    else do
    if addline.j='' then call w_put addw, i+2,3,copies('Ä',width-6),width-4
    else call w_put addw, i+2, 3, addline.j, width-4
    end
    if i+2 = addcurline then
        call addhighlight addline.j, i+2
    end
call w_unhide addw
return

/* highlight the directory name */
addhighlight:
line = arg(1)
row = arg(2)

col = lastpos(d2c(196),line) + 3
call w_attr addw, row, col, length(line) - col + 3, reverse
return



/* show a portion of the tree */
show:
call w_hide w, 'n'
do i = 0 to height-1
    j = top + i
    if j>count then call w_put w,i+2,3,copies(' ',width-6),width-4
    else do
    if line.j='' then call w_put w, i+2,3,copies('Ä',width-6),width-4
    else call w_put w, i+2, 3, line.j, width-4
    end
    if i+2 = curline then
        call highlight line.j, i+2
    end
call w_unhide w
return

/* highlight the directory name */
highlight:
line = arg(1)
row = arg(2)
col = lastpos(d2c(196),line) + 3
if line='' then line=copies('Ä',width-6)
call w_attr w, row, col, length(line) - col + 3, reverse
return


/* edit site name */
Edit:
parse arg site href com
com1=''
com2=''
 call scrwrite 25,1,center(site' 'href,80),,,31
/*temp=W_Open(2,1,23,80,artcolor)*/
Call ScrClear 0,,2,1,23,80

temp=W_Open(7,1,11,80,39)
Call W_Border temp,1,1,1,1
call W_Scrwrite temp,2,3,center('Change the name for this site!',76),,39
/*call W_Scrwrite temp,4,3,center('Type the New name in the entry field',76),,39*/
call W_Scrwrite temp,6,3,center('Enter a new site title, or press <esc> to keep this one!',76),,39
call W_Scrwrite temp,8,3,center(com,76),,39
com1=W_Get(temp,10,18,46,,112,,'N')

 if com1='' then do
     call W_Close(temp)
     com1=com
 end /* do */
else do  

/*check name*/
call W_Clear temp,39,' ',1,1,11,80
call W_Border temp,1,1,1,1
call W_Scrwrite temp,3,3,center('Is the new name acceptable?',76),,39
call W_Scrwrite temp,5,3,center('Enter a new title or press <esc> to save this one.',76),,39
call W_Scrwrite temp,7,3,center(com1,76),,39
com2=W_Get(temp,9,18,46,,112,,'N')

call w_Close(temp)
end
if com2='' then com=com1
else com=com2
return com


/* display the help window */
showhelp:

helpw = w_open(3,35,help_lines+2,44,118)
call w_border helpw
do i = 1 to help_lines
   if i=8 then call w_put helpw,i+1,3, center(help_line.i,38),,112
   else call w_put helpw, i+1, 3, help_line.i
    end
call inkey
call w_close helpw
return



/* preserve screen contents */
save_screen:
saved_screen = scrread(1,1,scr_height*scr_width,'b')
return

/* restore screen contents */
restore_screen:
call scrput 1, 1, saved_screen, 'b'
return


/* initialize variables */
initialize:
esc = '1b'x
enter = '0d'x
ansiclear = esc'[2J'
up = '0048'x
down = '0050'x
pgup = '0049'x
pgdn = '0051'x
home = '0047'x
endkey = '004f'x
ctrlpgup = '0084'x
ctrlpgdn = '0076'x
pf1 = '003b'x
pf2 = '003c'x
pf3 = '003d'x
pf4 = '003e'x
pf5 = '003f'x
pf6 = '0040'x
pf7 = '0041'x
pf8 = '0042'x
pf9 = '0043'x
pf10 = '0044'x


/*      Set universal values.  */
homedir=Directory()
loadsdir=homedir'\LOADS\'
sitesdir=homedir'\SITES\'

/* add rule nul line */
nul_line.1=''
nul_line.0=1
help_on=0
add.0=1
add.1=''




parse value scrsize() with scr_height scr_width .

parse value pcvideomode() with irc colors . .
if irc = 1 & colors < 4 then do
   reverse = 112
   normal = 7
   border = 15
   end
else do
   reverse = 112
   normal = 31
   border = 30
   end
help_line.1 = "F2 - Save Sites List"
help_line.2 = "F3 - Exit"
help_line.3 = "F4 - Delete Highlighted site or line"
help_line.4 = "F5 - Edit Site Name"
help_line.5 = "F6 - Add Sites"
help_line.6 = "F7 - Add Horizontal rule one line below"
help_line.7 = "F9 - Move Site"
help_line.8 = "Adding Sites" /* adjust showhelp */  
help_line.9 = "F7 -  One line below Highlighted line"
help_line.10= "F8 -  One line above Highlighted line"
/* help_line.n = "F5 - Your new option..." */
help_lines = 10     /* must be kept in synch */
return
