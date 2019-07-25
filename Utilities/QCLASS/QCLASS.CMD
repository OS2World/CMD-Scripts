/* QCLASS.CMD - Display list of available object classes */

Call RxFuncAdd "SysLoadFuncs", "RexxUtil", "SysLoadFuncs"
Call SysLoadFuncs;

call SysQueryClassList "list."
Call SysCls
Say '';Say '';
Say 'Pinnacle Technology, Inc. (c) 1995,  Query Classes'
Say 'Listing class info.,        Class   and   DLL'; Say '';
parse value SysTextScreenSize() with row col
j=row-10
Do i=1 to list.0
   If trunc(i/j)==i/j Then Do
      Say '';Say 'Press any key to show next screen...'
      key=SysGetKey()
      Call SysCls
      Say '';Say '';
      Say 'Pinnacle Technology, Inc. (c) 1995,  Query Classes'
      Say 'Listing class info.,        Class   and   DLL'; Say '';
   End
   parse var list.i Class dll
   Say 'Class' left( i, 3, ' ') 'is' right( Class, 20,' ' ) '       ' dll
End
Exit
