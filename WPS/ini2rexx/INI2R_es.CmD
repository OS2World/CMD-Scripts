/**/
if RxFuncQuery('SysLoadFuncs') then do
  call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
  call SysLoadFuncs
 end
if RxFuncQuery('FastIniStart') then do
  call RxFuncAdd  "FastIniStart", "FastIni", "FastIniStart"
  call RxFuncAdd  "FastIniEnd", "FastIni", "FastIniEnd"
 end

version = '0.1.2'

call cfg

Parse upper arg nombre
if pos('.INI',nombre)=0 then do
  archini=nombre||'.INI'
  rexx=nombre||'.CMD'
 end
else do
  nombre=delstr(nombre,pos('.INI',nombre))
  archini=nombre||'.INI'
  rexx=nombre||'.CMD'
 end

parse source . . myself
say 'INI2Rexx version '||version
if nombre='' then do
  say 'Uso: '||myself||' INI file'
  exit 1
 end

call rexx_head
inifileRC = FastIniStart(archini, "inifileHandle")

call sysini archini,'ALL:','arbol'
do i=1 to arbol.0
  call rama arbol.i
  say left(arbol.i,40)||' - Apl. '||right(i,3)||'/'||arbol.0||' OK'
 end

call FastIniEnd inifileHandle
call rexx_tag

exit

cfg:
  textp  = 0.75  /* Lower limit to the proportion of text chars to make text dumps of keys */
  limite = 256   /* Upper limit to make text dumps of keys */
  ct     = x2c('00')
  intro  = x2c('0D0A')
  initsp = copies(' ',6)
  commsp = copies(' ',1)
  dataseg = 20
  sl      = 60
                /* npc stands for non_printable_chars */
  npc     = x2c('000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1FFBFCFDFEFF')
  spc     = copies('ú',length(npc))  /* some printable chars */
return

textchars:
  parse arg data
  ranger = 1
  chars  = 0
  l      = length(data)
  do while ranger<=l
    c1=substr(data,ranger,1)
    if pos(c1,npc)=0 then
      chars=chars+1
    ranger=ranger+1
   end
return chars

textdump:
  parse arg data
  ranger = 1
  l      = length(data)
  text   = ""
  newln  = 1
  do while ranger <= l
    c1 = right(left(data,ranger),1)
    c0 = right(left(data,ranger-1),1)
    if pos(c1,npc)=0 & c1<>"'" then do
      select
        when newln = 1 then do
          nwtxt = "'"||c1
         end
        when pos(c0,npc)=0 & c0<>"'" then do
          nwtxt = nwtxt||c1
         end
        when pos(c0,npc)>0 | c0= "'" then do
          nwtxt = nwtxt||"'x||'"||c1
         end
        otherwise nop
       end
      newln = 0
      if ranger = l then do
        nwtxt=nwtxt||"'"
        text = text||nwtxt
       end
      else if length(nwtxt)>= sl then do
        nwtxt = nwtxt||"'||,"||intro
        text = text||nwtxt||initsp
        newln=1
       end
     end
    else do
      select
        when newln = 1 then do
          nwtxt = "'"||c2x(c1)
         end
        when pos(c0,npc)=0 & c0<>"'"  then do
          nwtxt = nwtxt||"'||'"||c2x(c1)
         end
        when pos(c0,npc)>0 | c0 ="'" then do
          nwtxt = nwtxt||c2x(c1)
         end
        otherwise nop
       end
      newln = 0
      if ranger = l then do
        nwtxt=nwtxt||"'x"
        text = text||nwtxt
       end
      else if length(nwtxt)>= sl then do
        nwtxt = nwtxt||"'x||,"||intro
        text = text||nwtxt||initsp
        newln=1
       end
     end
    ranger = ranger + 1
   end
return text

hexdump:
  parse arg data
  ranger = 1
  text   = ''
  l      = length(data)
  do while ranger<=l
    unparsed=l-ranger+1
    if unparsed < dataseg then bytejunk = substr(data,ranger,unparsed)
    else bytejunk = substr(data,ranger,dataseg)
    ranger = ranger+dataseg
    hexa = c2x(bytejunk)
    do while pos('*/',hexa)>0
      hexa=insert(' ',hexa,pos('*/',hexa))
     end
    txt  = translate(bytejunk,spc,npc)
    if ranger<=l then sep = "'||,"
    else sep = "'   "
    text=text||"'"||hexa||sep||commsp||copies(' ',2*dataseg-length(hexa))||"/* "||txt||" */"||intro||initsp
   end
return text

rama:
  parse arg apl
  call lineout rexx,'/* Aplicaci¢n: '||apl||' */'
  call lineout rexx,''
  call lineout rexx,"Apl='"||apl||"'"
  call lineout rexx,"say 'Escribiendo aplicaci¢n: '||Apl"
  call lineout rexx,''
  call sysini archini,apl,'ALL:',hoja
  do j=1 to hoja.0
    valor=sysini(archini,apl,hoja.j)
    call lineout rexx,"Clave="||textdump(hoja.j)||'  /* ASCII: '||textchars(valor)||,
                      ' caracteres de '||length(valor)||' */'
    if length(valor)=0 then call lineout rexx,"Valor=''"
    else do
      if (length(valor) >= limite) | (textchars(valor)/length(valor) < textp) then do
        call lineout rexx,"Hexa ="||hexdump(valor)
        call lineout rexx,"Valor=X2C(Hexa)"
       end
      else call lineout rexx,"Valor="||textdump(valor)
     end
    call lineout rexx,"Call SysInI Arch,Apl,Clave,Valor"
    call lineout rexx,''
   end
return

rexx_head:
  call lineout rexx,"/* Script REXX para re-crear el archivo "||archini||" */"
  call lineout rexx,'/* Archivo: '||archini||' */'
  call lineout rexx,''
  call lineout rexx,"Arch='"||archini||"'"
  call lineout rexx,"say 'Archivo: '||Arch"
  call lineout rexx,''
  call lineout rexx,'Say "Pulse S + Enter para seguir ..."'
  call lineout rexx,'PULL respuesta'
  call lineout rexx,'IF respuesta = "S" THEN DO'
  call lineout rexx,''
  call lineout rexx,"if RxFuncQuery('SysLoadFuncs') then do"
  call lineout rexx,"  call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'"
  call lineout rexx,"  call SysLoadFuncs"
  call lineout rexx," end"
  call lineout rexx,"if RxFuncQuery('FastIniStart') then do"
  call lineout rexx,'  call RxFuncAdd  "FastIniStart", "FastIni", "FastIniStart"'
  call lineout rexx,'  call RxFuncAdd  "FastIniEnd", "FastIni", "FastIniEnd"'
  call lineout rexx,' end'
  call lineout rexx,'mymkfileRC = FastIniStart(Arch, "mymkfileHandle")'
  call lineout rexx,''
  call lineout rexx,''
  say 'Cabecera del archivo REXX - OK'
return

rexx_tag:
  call lineout rexx,'call FastIniEnd mymkfileHandle'
  call lineout rexx,''
  call lineout rexx,'Say " "'
  call lineout rexx,'Say "Terminado"'
  call lineout rexx,'Say " "'
  call lineout rexx,'end'
  call lineout rexx,''
  call lineout rexx,'Exit'
  call lineout rexx,''
  call lineout rexx
return
