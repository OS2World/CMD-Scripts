/*----------------------------------------------*/
/* OLBOX.CMD -  Listbox In OREXX                */
/* 1999 (C) Antal Koos,                         */
/* Version: see LibVersion method!              */
/*----------------------------------------------*/
/* Load the RexxUtil in your program or in the startup.cmd! */
/* Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs';*/
/* Call SysLoadFuncs;*/

return;

/*-------------------------------------*/
::CLASS OLBox Public
/*-------------------------------------*/
/*-------------------------------------*/
::METHOD LibVersion
return ( 'Listbox in OREXX v1.00, 1999-06-08 (C) Antal Koos');
/*-------------------------------------*/
::METHOD String /* returns the last selected item number */
expose LD. item.
        i=LD.SItem;
Return item.i;
/*-------------------------------------*/
::METHOD Init
expose LD. item. selected. /* LD. = Listbox Descriptor */
        use arg list., nlines, x, y, width
/* list.0 = the number of item strings */
/* nlines = the number of the visible lines */
/* x, y =  upper left coordinate         */
/* width = the displayed length of item strings */
        
        if var('list.1')=0 then do
           item.0=2;
           item.1='The listbox is not initialized!';
           item.2='Use the ~SetList method!';
        end
           else item.= list.~copy;
        if var('nlines')=0 then nlines= min( item.0, 3);
        if var('x')=0 then x=1;
        if var('y')=0 then y=1;
        if var('width')=0 then do
           mx=length( item.1);      
           do i=2 to item.0
                l=length( item.i)
                if mx<l then mx=l;
           end /* do */
        width= mx;
        end /* do */
        

        LD.SItem=1;         /* SItem - Selected Item */ 
        LD.PrevSItem=0;      
        LD.FDItem=1;       /* FDItem - First Displayed Item */ 
        LD.PrevFDItem=0;
        LD.ilength= width;
        LD.vlines= nlines;  /* number of visible lines */
        LD.row= y; LD.col= x;
        LD.MSelection=.false; /* multiply selection disabled */
        LD.MSKey=d2c(32);     /* default selection key: space */
        LD.MSFoundLast=0;

        selected.=.false;

Return;
/*-------------------------------------*/
::METHOD SetMulSelection
expose LD.
        use arg flag, key
        if flag=.true then LD.MSelection=.true
        else if flag=.false then LD.MSelection=.false;
        if var('key')\=0 then LD.MSkey=key;
Return;        
/*-------------------------------------*/
::METHOD GetFirstSelected
expose LD. item. selected.
        LD.MSFoundLast=0;
Return Self~GetNextSelected;
/*-------------------------------------*/
::METHOD GetNextSelected
expose LD. item. selected.
        found.index=0;
        do i=LD.MSFoundLast+1 to item.0
           if selected.i then do
                found.index= i;
                found.str= item.i;
                LD.MSFoundLast=i;
                Return found.
           end /* do */
        end /* do */
Return found.;

/*-------------------------------------*/
::METHOD SetCorner
expose LD.
        use arg x, y
        LD.row= y; LD.col= x;
Return;
/*-------------------------------------*/
::METHOD SetList
expose LD. item.
        use arg list., width
        if var('width')=0 then Self~Init( list., LD.vlines, LD.col, LD.row)
         else Self~Init( list., LD.vlines, LD.col, LD.row, width); 
Return;
/*-------------------------------------*/
::METHOD GetList
expose item.
Return item.~copy;
/*-------------------------------------*/
::METHOD SetWidth
expose LD. item.
        use arg width
        LD.ilength= width;
/*        do i=1 to item.0
           item.i= left( item.i, LD.ilength);
        end */
Return;
/*-------------------------------------*/
::METHOD SetHeight
expose LD. item.
        use arg h
        if h<1 | h>item.0 then LD.vlines=item.0
        else LD.vlines=h;
Return;
/*-------------------------------------*/
::METHOD Execute
/* return: .true if Enter pressed; .false if Esc pressed. */
expose LD. item. ufunc. selected.

        k_Enter=d2c(13);   k_Esc=d2c(27);     k_Up=d2c(72);
        k_Down=d2c(80);    k_PGUp=d2c(73);    k_PGDown=d2c(81);
        k_Home=d2c(71);    k_End=d2c(79);     k_CtrlPgUp=d2c(132);
        k_CtrlPgDown=d2c(118);

        Call SysCurState('OFF');
        Self~Refresh;
        DO FOREVER
                pkey= Self~GetKey;
                LD.PrevSItem= LD.SItem; 
                LD.PrevFDItem= LD.FDItem;
                if pkey=k_Enter then do
                        /* in single selection mode: selected one item by Enter */ 
                        if \LD.MSelection then do 
                                t=LD.SItem;
                                selected.t=.true;
                        end;
                        Leave;
                end;
                if pkey=k_Esc then do /* cancel by user */
                        selected.=.false;
                        Leave;
                end;
                if LD.MSelection & LD.MSkey=pkey then do /* Multiply selection? */
                        index=LD.SItem;
                        if selected.index then selected.index=.false
                        else selected.index=.true;
                        Self~Refresh;
                        Iterate;
                end;
                /* calling user function */
                if var('ufunc.pkey') then do
                        parse value SysCurPos() with row col /* save cursor */
                        if Self~UserFunction( ufunc.pkey) then Self~Refresh;
                        Call SysCurPos row, col; /* restore cursor */
                        Iterate;
                end /* do */
                
                if length(pkey)=2 then do
                   key= right(pkey,1);
                   select
                     when key= k_Up then do 
                        LD.SItem= max(1, LD.SItem-1); 
                        if LD.SItem<LD.FDItem then LD.FDItem=LD.SItem;
                     end /* do */
                     when key=k_Down then do
                        LD.SItem= min( LD.SItem +1, item.0);
                        if LD.SItem>=LD.FDItem+LD.vlines then LD.FDItem=LD.FDItem+1;
                     end
                     when key=k_PGUp then do
                        LD.SItem= max( 1, LD.SItem-LD.vlines);
                        if LD.SItem<LD.FDItem then LD.FDItem=LD.SItem;
                     end
                     when key=k_PGDown then do
                        LD.SItem= min(LD.SItem+LD.vlines, item.0);
                        if LD.SItem>=LD.FDItem+LD.vlines then LD.FDItem=LD.SItem;
                        if (item.0-LD.FDItem)<LD.vlines then LD.FDItem=item.0-LD.vlines+1;
                     end
                     when key=k_CtrlPgUp then do 
                        LD.SItem= 1; LD.FDItem=1;
                     end /* do */
                     when key=k_CtrlPgDown then do
                        LD.SItem= item.0; 
                        LD.FDItem= max( 1, item.0 -LD.vlines+1);
                     end /* do */
                     when key=k_Home then LD.SItem= LD.FDItem;
                     when key=k_End then LD.SItem= min( item.0, LD.FDItem+LD.vlines-1);
                   otherwise Iterate;
                   end;  /* select */
                   Self~Show;
                end;
        END /* forever */
        Call SysCurState('ON'); Call SysCurPos 0,0; 

if pkey=k_Enter then return .true;
Return .false;

/*---------------------------------------------*/
::METHOD Refresh
        expose LD.
        LD.PrevFDItem=0; /* forcing 'show' to redisplay */
        Self~Show;
return;
/*---------------------------------------------*/
::METHOD GetKey
 key=SysGetKey('NOECHO');
 if key=d2c(0) | key=d2c(224) then key=key||SysGetKey('NOECHO');
return key;
/*---------------------------------------------*/

::METHOD Show
 expose LD. item. selected.
 pointer='->';
 mulselchar='+';
 empty_pointer='  ';
 more='...';
 no_more='   ';

        y=LD.row;

        if LD.PrevFDItem = LD.FDItem then do
           if LD.PrevSItem = LD.SItem then return;
           Call SysCurPos y+1 + LD.PrevSItem - LD.FDItem, LD.col;
           say empty_pointer;
           Call SysCurPos y+1 + LD.SItem - LD.FDItem, LD.col;
           say pointer;
           return; 
        end;

        Call SysCurPos y, LD.col;
        if LD.FDItem>1 then say more
         else say no_more;

        y=y+1;
        DO i= LD.FDItem to (LD.FDItem + LD.vlines -1)
           Call SysCurPos y, LD.col; 
           ms='';
           if LD.MSelection then ms=' ';
           IF i<=item.0 then do
                if LD.Mselection & selected.i then ms=mulselchar;
                if i=LD.SItem then say pointer||ms||left( item.i, LD.ilength);
                else say empty_pointer||ms||left( item.i, LD.ilength); 
           END 
           ELSE say ms||left(' ',LD.ilength+2);
           y=y+1;
        END;

        Call SysCurPos y, LD.col;
        if (LD.FDItem + LD.vlines -1)<item.0 then say more
          else say no_more;

Return;

/*-------------------------------------*/
::METHOD SetDefaultItem
        expose LD. item.
        use arg itemno;

        if itemno<1 | itemno>item.0 then return .false;
        LD.SItem= itemno;
        LD.FDItem= itemno - LD.vlines%2;
        if LD.FDItem<1 then LD.FDItem=1;
        if (item.0 - LD.FDItem)<LD.vlines then LD.FDItem= item.0 - LD.vlines+1;
        return .true;
/*-------------------------------------*/
::METHOD SetUserFunc
        expose ufunc.
        use arg key, !instr

        ufunc.key= !instr;

return;
/*-------------------------------------*/
::METHOD UnSetUserFunc
        expose ufunc.
        use arg key

        drop ufunc.key;

return;
/*-------------------------------------*/
::METHOD UserFunction
        expose LD. item.
        use arg !instr;

        Interpret !instr
        
if refresh=.true then return .true;
return .false;
/*-------------------------------------*/
/* (Very) simple sort */
::METHOD Sort
expose item.
        if item.0 = 1 then Return;

        top=item.0;
        do while top>1
           m=item.1; indx=1;
           do i= 2 to top
                if m < item.i then do
                        m= item.i; 
                        indx= i;
                end /* do */
           end;
           tmp= item.top;
           item.top= m;
           item.indx= tmp;
           top= top-1;
        end /* do */
Return;
