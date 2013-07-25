/* Java WorkShop startup script                                           */
/* This file was created by Cristiano Guadagnino (herbie@elettrodata.it)  */
/* Latest release of this file: 13/05/1997                                */
/*                                                                        */
/* Release notes:                                                         */
/* This script assumes that JAVA_HOME environment variable is already set */
/* and that it is run from \$JWS_HOME$\OS2\BIN, where $JWS_HOME$ is your  */
/* Java WorkShop home directory. Note that jws.ut.platform is hardcoded.  */
/*                                                                        */
/* The original Copyright statement is below:                             */


/*                                                                        */
/* @(#)jws       1.75 96/07/30                                            */
/*                                                                        */
/* Copyright (c) 1994 Sun Microsystems, Inc. All Rights Reserved.         */
/*                                                                        */
/* Permission to use, copy, modify, and distribute this software          */
/* and its documentation for NON-COMMERCIAL purposes and without          */
/* fee is hereby granted provided that this copyright notice              */
/* appears in all copies. Please refer to the file "copyright.html"       */
/* for further important copyright and licensing information.             */
/*                                                                        */
/* SUN MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF    */
/* THE SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED     */
/* TO THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A            */
/* PARTICULAR PURPOSE, OR NON-INFRINGEMENT. SUN SHALL NOT BE LIABLE FOR   */
/* ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR    */
/* DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES.                         */
/*                                                                        */

/*                    */
/* Determine JWS_HOME */
/*                    */

if VALUE('_SS_JWS_HOME',,'OS2ENVIRONMENT') = "" then do
    curdir = directory()
    homedir = directory("..\..")
    SS_JWS_HOME = homedir
    call directory curdir
end

/*                    */
/* Determine JDK_HOME */
/*                    */

if VALUE('JAVA_HOME',,'OS2ENVIRONMENT') = "" then do
    say
    say "JAVA_HOME environment variable is not set"
    say "Please set JAVA_HOME to point to your JDK directory"
    say "   (e.g. SET JAVA_HOME=C:\JavaOS2)"
    say
    exit
    end
else do
    SS_JDK_HOME = VALUE('JAVA_HOME',,'OS2ENVIRONMENT')
    CALL VALUE '_SS_JDK_HOME', SS_JDK_HOME, 'OS2ENVIRONMENT'
end

ARCH = 'OS2'

/*            */
/* Set paths  */
/*            */

RUNCLASSPATH = SS_JWS_HOME'\classes;'SS_JWS_HOME'\lib\jws.zip;'SS_JDK_HOME'\lib\classes.zip'
CLASSPATH = SS_JDK_HOME'\lib\classes.zip'
CALL VALUE 'CLASSPATH', CLASSPATH, 'OS2ENVIRONMENT'

newpath = VALUE('PATH',,'OS2ENVIRONMENT')||';'SS_JWS_HOME'\OS2\BIN'
CALL VALUE 'PATH', newpath, 'OS2ENVIRONMENT'

JWS_BIN=SS_JWS_HOME'\OS2\BIN'

CALL VALUE 'LD_LIBRARY_PATH', JWS_BIN, 'OS2ENVIRONMENT'

/*                        */
/* Create .jws directory  */
/*                        */

dummy = VALUE('HOME', , 'OS2ENVIRONMENT')||'\.jws'
/* say 'Creating 'dummy' directory' */
if directory(dummy)="" then
    'md 'dummy
else
    CALL directory curdir

prog = 'javapm'
main_class = 'sun.jws.Main'
opts = ''

/*                                                                     */
/* Parse arguments                                                     */
/* the -debug option is assumed to have a value associated with it.    */
/* transform '-debug <file>' to '-debug -Djws.startup.props=<file>'    */

args=""
debug_prop=""

numopts = ARG()
i = 1
do while i <= numopts
    argn = ARG(i, 'N')
    select
        when argn = '-debug' then do
            prog = 'javapm_g'
            main_class = 'sun.jws.Debugger.Agent'
            debug_prop = '-Ddebug.browser=yes'
            opts = opts||'-noasyncgc'
            end
        when argn = '-classpath' then
            RUNCLASSPATH = ARG(i+1, 'N')||';'||RUNCLASSPATH
        when LEFT(argn, 1) = '-' then
            opts = opts||argn
        otherwise
            args = args||argn
    end
    i = i + 1
end

java = SS_JDK_HOME'\bin\'prog

/*                      */
/* Add WWW_HOME option  */
/*                      */

if VALUE('WWW_HOME', , 'OS2ENVIRONMENT') \= "" then
    opts = opts||'-Dwww.home='VALUE('WWW_HOME', , 'OS2ENVIRONMENT')

JWSLOG=dummy'\weblog'
CALL VALUE 'JWSLOG', JWSLOG, 'OS2ENVIRONMENT'

if prog = 'javapm_g' then
    java' -classpath 'RUNCLASSPATH' -Djws.home='SS_JWS_HOME' -Dhotjava.home='SS_JWS_HOME' -Djws.bin='JWS_BIN' -Djdk.bin='SS_JDK_HOME'\bin -Djws.ut.user='VALUE('USER' , , 'OS2ENVIRONMENT')' -Djws.ut.platform="OS/2 4.0 i386" -Djws.build.classes='VALUE('CLASSPATH', , 'OS2ENVIRONMENT')' 'debug_prop' 'opts' 'main_class' 'args
else
    java' -classpath 'RUNCLASSPATH' -Djws.home='SS_JWS_HOME' -Dhotjava.home='SS_JWS_HOME' -Djws.bin='JWS_BIN' -Djdk.bin='SS_JDK_HOME'\bin -Djws.ut.user='VALUE('USER' , , 'OS2ENVIRONMENT')' -Djws.ut.platform="OS/2 4.0 i386" -Djws.build.classes='VALUE('CLASSPATH', , 'OS2ENVIRONMENT')' 'debug_prop' 'opts' 'main_class' 'args' >& \dev\nul'

