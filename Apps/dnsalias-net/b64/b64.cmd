/*************************************************************************
* PROGRAM: B64.CMD (REXX script)
*
* Intelligent Base64 encoder/decoder. Uses BASE64 API from MD5RX.DLL.
*
* Created by Teet Kõnnussaar (teet@aetec.estnet.ee)
*
* This program is *freeware*, which means that you don't have to pay
* for it and you may use/modify it whatever way you want.
* But: This program is distributed AS IS, and with NO warranties,
*   neither implied or expressed.
*
* Usage:
*    B64 ( e | d ) [infile [outfile]]
*        e - for encoding (file -> base64)
*        d - for decoding (mail -> file)
*
* Encoding notes:
*     writes 3-line MIME-compliant header
*     if in-file not specified, reads standard input for data to encode
*     if outfile not specified, writes to standard output
*
* Decoding notes:
*     if in-file not specified, reads from standard input
*     auto-detects encoded data postition in file (should have at 
*        least 3 lines of encoded data to detect correctly)
*     if outfile not given, guesses filename to decode or writes to
*        b64out.$$?. Does not overwrite out-files, never.
*
*************************************************************************/

/* Note: there might be need for some error handler.
   Do it yourself, if you need it */

call rxfuncadd 'B64encode','md5rx','B64encode'
call rxfuncadd 'B64decode','md5rx','B64decode'

parse arg mode file ofile
mode=translate(mode)

if      mode="D" then call B64Dfile file, ofile
else if mode="E" then call B64Efile file, ofile
else do
  say "Usage: B64 <mode-letter> [infile [<outfile>]]"
  say "    mode-letter is either 'e' or 'd'"
end

exit 0

B64EFile: procedure; parse arg f, fo
  buf = "";i=0
  call lineout fo, "Content-Transfer-Encoding: base64"
  call lineout fo, "Content-Type: application/octet-stream;"||,
                   " charset=US-ASCII; name="""||f||""""
  call lineout fo, ""
  do while chars(f)>0
    li = chars(f); if li>189 then li=189
    buf = buf || B64Encode(charin(f,,li))
    do while length(buf) >= 76
      call lineout fo, left(buf,76)
      buf = substr(buf,77)
    end
  end
  if length(buf)>0 then call lineout fo, buf
  call stream f ,"c","close"
  if fo<>"" then call stream fo,"c","close"
return

B64DFile: procedure; parse arg f, fo0
  if fo0<>"" then if stream(fo0,"c","query exists")<>"" then do
     say "File" fname||fnext "already exists, aborting"
     say "0 files decoded"
     return
  end
  np=0;fname="";fnext=""
  b64sym = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="
  fnsym = xrange("A","Z")||xrange("a","z")||xrange("0","9")||,
                          ".~$!-_#@{[()]}"
  filecount = 0; li = 1
  do forever
    hit=0; buf = "";l1 = 0;
    call charout ,"Searching.."
    do li=li while lines(f)>0
      if li//100 = 0 then call charout ,"."
      l = linein(f);ll = length(l)
      if \hit & ll >= 70 & ll <= 80 & verify(l,b64sym)=0 then do
        l1 = ll; buf = l; hit = 1
      end
      else if hit & l1 = ll & verify(l,b64sym)=0 then do
        say;say "Found BASE64 encoded data at line" li-1
        filecount = filecount + 1
        buf = buf || l
        leave
      end
      else if hit then do
        hit=0; buf = ""
      end
      else do
        if fo0=="" then do
          np=pos("name",l)
          if np<>0 &,
              pos(substr(l,np+4,1),fnsym)=0 then do
            fncand=substr(l,np+5)
            np=verify(fncand,fnsym,"M")
            if np<>0 then fncand=substr(fncand,np)
            np=verify(fncand,fnsym,"N")
            if np<>0 then fncand=left(fncand,np-1)
            if length(fncand)>2 then do
              fname=fncand
              fnext=""
              np = lastpos(".",fncand)
              if np<>0 then do
                fname=left(fncand,np-1)
                fnext=substr(fncand,np)
              end
/*              say "Found possible file name at" li": '"fname||fnext"'"*/
            end
          end
        end
      end
    end
    if lines(f) = 0 then do
      say;say filecount "file(s) decoded"
      call stream f ,"c","close"
      return
    end
    if fo0=="" then do
      if fname="" & fnext="" then do
        fname="b64out"; fnext=".$$0"
      end
      if stream(fname||fnext,"c","query exists")<>"" then do
        say "File" fname||fnext "already exists"
        do fnn=1 while stream(fname||fnext,"c","query exists")<>""
          fnext = "."||right("$$"||fnn,3)
        end
      end
      fo = fname||fnext
    end
    else do
      fo = fo0
    end
    say "Decoding" fo
    do li=li while lines(f)>0
      if li//25 = 0 then call charout ,"#"
      l = linein(f)
      if l=="" then leave
      if verify(l,b64sym)<>0 then leave
      buf = buf || l
      do while length(buf)>340
        lb = length(buf)%4*4; if lb>340 then lb=340
        call charout fo,B64Decode(left(buf,lb))
        buf = substr(buf,lb+1)
      end
      if pos("=",l)<>0 then leave
    end
    say "- done!"
    do while length(buf)>340
       lb = length(buf)%4*4; if lb>340 then lb=340
       call charout fo,B64Decode(left(buf,lb))
       buf = substr(buf,lb+1)
    end
    if length(buf)>0 then call charout fo, B64Decode(buf)
    call stream fo,"c","close"
    if fo0<>"" then do
      call stream f ,"c","close"
      say "1 file decoded"
      return
    end
  end
  call stream f ,"c","close"
return

