/* test.cmd, Antal Koos */

Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs';
Call SysLoadFuncs;

kF1=d2c(0)||d2c(59);/* Try pkey.cmd! */ 
kF5=d2c(0)||d2c(63);
kF3=d2c(0)||d2c(61); 

list.0=10;
do i=1 to 10
   list.i=date('L',date('B')+i,'B');
end;

menu= .OLBox~new( list.); 
menu~SetCorner( 25,5);
menu~SetHeight( 6);
menu~SetDefaultItem( 8);
menu~SetMulSelection(.true);
/* menu~SetMulSelection(.true,kF3); */

F5func="i=LD.SItem; item.i=reverse(item.i); refresh=.true;";
F1func="Call SysCurPos 1,1; i=LD.SItem; say left('What are you going to do on '||item.i||'?',70);";

menu~SetUserFunc(kF5,F5func );
menu~SetuserFunc(kF1,F1func);

Call SysCls;
say 'F1: demo1; F5: demo2; Space: toggle selection';
rtcd= menu~Execute; /* Displaying listbox. */

Call SysCurPos 15,1;
if rtcd then say 'Selection accepted.'
else say 'Selection canceled.';

say 'Selected items:';
found.=menu~GetFirstSelected;
do while found.index>0
    say 'index='found.index' str='found.str;
    found.=menu~GetNextSelected;
end /* do */

EXIT;

::REQUIRES 'olbox.cmd'
