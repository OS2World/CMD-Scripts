/*   pci.ids  to pcidevs.txt filter */
/*
 *    Copyright (C) 2012   Greg Jarvis
 *
 *    This program is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * 2012-06-18 SHL Strip spurious spaces
 * 2012-06-20 GJ  corrected pcidevs.txt first line
 * 2012-16-04 GJ  works both on Cassic and Object REXX, version is Craig Hart format
 */
ver = '1.03'
verids = '?'
in  = 'pci.ids'
out = 'pcidevs.txt'
tab = d2c(9)

call RxFuncAdd "SysLoadFuncs", "RexxUtil", "SysLoadFuncs"
call SysLoadFuncs

if stream( out,'c','query exist')<>'' then
   call SysFileDelete out
call stream in,'c','open read'
call stream out,'c','open write'

call lineout out,"; This file has been auto converted to Craig Hart's format by ids2devs.cmd vers" ver   /* 2012-06-20 GJ */
vendor = 'V'
device = 'D'

do while lines(in)
   line = linein(in)

   select
      when length(line)=0 then line = ';'line
      when left(line,1)='#' then do
         if left(line,10)='#'||tab||"Version:" then do
            verids = word(line,2)
            line = '; This is version' verids 'of pci.ids using ids2devs version' ver
            end
         else
            line = ';'line
         end
      when left(line,2)=tab||tab then line = ';'line
      when left(line,1)=tab then do    /* device */
         parse var line (tab) id name
         line = device||tab||translate(id)||tab||strip(name) /* 2012-06-18 SHL */
         end
      otherwise  do                    /* vendor */
         parse var line id name
         if id='C' then do
            vendor = 'C'
            device = 'T'
            parse var name id name
            end
         line = vendor||tab||translate(id)||tab||strip(name) /* 2012-06-18 SHL  */
         end
   end

   say line
   call lineout out,line
end

call stream in,'c','close'
call stream out,'c','close'

say "pcidevs script version" ver
say "pci.ids version" verids
exit(0)

