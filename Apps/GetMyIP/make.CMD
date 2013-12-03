/*****************************************************************************************************/
/*                                              GetMyIP                                              */
/*                              by Peter Lueersen <Peter.Lueersen@web.de>                            */
/*                                              V 1.0.8                                              */
/*****************************************************************************************************/
/* This program is free software                                                                     */
/* you can redistribute it and/or modify it under the terms of the GNU General Public License        */
/* as published by the Free Software Foundation; either version 2 of the License,                    */
/* or (at your option) any later version.                                                            */
/*                                                                                                   */
/* This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY          */
/* without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.         */
/* See the GNU General Public License for more details.                                              */
/*                                                                                                   */
/* You should have received a copy of the GNU General Public License along with this program         */  
/* if not, write to the                                                                              */
/* Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.           */  
/*****************************************************************************************************/
cls
'mode 80,80'
cls
say '*******************************************************************************'
say '*                               GetMyIP MAKE                                  *'
say '*******************************************************************************'
say '*        by Peter Lueersen                          Version 1.0.8             *'
say '*                 GetMyIP     (c) Peter LÅersen 2006                          *'
say '*                Email address: Peter@warp-ecs-owl.de                         *'
say '*                  Program URL: www.warp-ecs-owl.de                           *'
say '*                               www.warp-ecs-owl.de/Peter_GetMyIP.html        *'
say '*******************************************************************************'
'rexx2exe GetMyIP.cmd GetMyIP.EXE /K'
'rexx2exe WPGetMyIP.cmd WPGetMyIP.EXE /K' 
'rexx2exe WPGetMyIP_all5m.cmd WPGetMyIP_all5m.EXE /K' 
'del ..\GetMyIP*.zip'
'copy GetMYIP.exe ..\GetMyIP.EXE'
'del GetMyIP.exe'
'copy WPGetMYIP.exe ..\WPGetMyIP.EXE'
'del WPGetMyIP.exe'
'copy WPGetMyIP_all5m.EXE ..\WPGetMyIP_all5m.EXE'
'del WPGetMyIP_all5m.EXE'
cd..
'del *.zip'
'RES\zip.exe -r -D -9 -u -v GetMyIP108.zip *.*'
