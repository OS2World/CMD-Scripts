/*------------------------------------------------------------------------*\
|                                                                          |
|           FIXOBJ.CMD   - Version 1.0 - Version Date 1994-11-23           |
|                 Copyright (C) 1994 by C F S Nevada, Inc.                 |
|                                                                          |
|                  by Dick Goran  - Voice    702-732-9616                  |
|                                 - FAX      702-732-3847                  |
|                                 - CIS      71154,2002                    |
|                                 - FIDO     1:209/705                     |
|                                 - IBMLink  DEV4672 at HONE81             |
|                                 - Internet 71154.2002@compuserve.com     |
|                                                                          |
\*------------------------------------------------------------------------*/
/*

   Generate a REXX program which can be used to build objects defined
   in an .RC file by specifying the relevant object ID.

   Calling format:

      FIXOBJ  object_id  [ RC_file_name ]

   Output will be created in FIXOBJnn.CMD in the directory pointed
   to by the TEMP environment variable. "nn" will will be the next
   sequential number following any existing files created by this
   program. The file name created will be shown on the console
   at completion of this program.

   The generated program may be moved to any convenient location or
   left in the \TEMP directory at the user's discretion.

   Prequisites:   OS/2 REXX with REXXUTIL

*/

   SIGNAL ON ERROR                  /* trap object time errors     */
   SIGNAL ON HALT                   /* trap object time errors     */
   SIGNAL ON NOVALUE                /* trap object time errors     */
   SIGNAL ON SYNTAX                 /* trap object time errors     */

GBL. = ''             /* initialize stem */                       /* 0041 */
parse Version         GBL.REXX_version .                          /* 0042 */
parse Source          GBL.operating_system,                       /* 0043 */
                      GBL.calling_environment,                    /* 0044 */
                      GBL.program_path_and_name                   /* 0045 */
GBL.environment     = 'OS2ENVIRONMENT'                            /* 0046 */
GBL.boot_drive      = LEFT( VALUE( 'COMSPEC',, GBL.environment ), 2 )
GBL.program_name    = FILESPEC( 'N', GBL.program_path_and_name )  /* 0048 */
GBL.program_path    = FILESPEC( 'D', GBL.program_path_and_name ) ||,
                      FILESPEC( 'P', GBL.program_path_and_name )  /* 0050 */
                      parse upper value GBL.program_name with fn '.' fe
GBL.program_version = 1.0           /* version / mod of this program */
GBL.error_count     = 0             /* input validation errors */ /* 0053 */
GBL.object_count    = 0             /* number of objects created */
call TIME 'E'                       /* set elapsed timer - sssss.uuuuu */
                                                                  /* 0056 */
say 'Begin' TRANSLATE( GBL.program_name ) 'at' TIME('N')          /* 0057 */
if GBL.operating_system = 'OS/2' then                             /* 0058 */
   do                                                             /* 0059 */
      /*-------------------*\                                     /* 0060 */
      |  Register REXXUTIL  |                                     /* 0061 */
      \*-------------------*/                                     /* 0062 */
      call REGISTER_REQUIRED_FUNCTIONS                            /* 0063 */
   end                                                            /* 0064 */
                                                                  /* 0065 */
/*--------------------------------------------*\                  /* 0066 */
|  Get Object ID value and optionally RC name  |                  /* 0067 */
\*--------------------------------------------*/                  /* 0068 */
parse ARG,                                                        /* 0069 */
   specified_object_id,                                           /* 0070 */
   specified_rc_name                                              /* 0071 */
do while specified_object_id = ''                                 /* 0072 */
   call GET_PARAMETERS_INTERACTIVELY                              /* 0073 */
end                                                               /* 0074 */
                                                                  /* 0075 */
/*---------------------------------------*\                       /* 0076 */
|  Assure format of predefined object ID  |                       /* 0077 */
\*---------------------------------------*/                       /* 0078 */
if LEFT( specified_object_id, 1 ) <> '<' then                     /* 0079 */
   do                                                             /* 0080 */
      specified_object_id = '<' ||,                               /* 0081 */
                            specified_object_id                   /* 0082 */
   end                                                            /* 0083 */
if RIGHT( specified_object_id, 1 ) <> '>' then                    /* 0084 */
   do                                                             /* 0085 */
      specified_object_id = specified_object_id ||,               /* 0086 */
                            '>'                                   /* 0087 */
   end                                                            /* 0088 */
GBL.object_id = TRANSLATE( specified_object_id ) /* always upper case */
                                                                  /* 0090 */
/*---------------------------------*\                             /* 0091 */
|  Vailidate RC path and file name  |                             /* 0092 */
\*---------------------------------*/                             /* 0093 */
if specified_rc_name = '' then                                    /* 0094 */
   do                                                             /* 0095 */
      specified_rc_name = GBL.boot_drive ||,                      /* 0096 */
                          '\OS2\INI.RC'                           /* 0097 */
   end                                                            /* 0098 */
if POS( '.', specified_rc_name ) = 0 then                         /* 0099 */
   do                                                             /* 0100 */
      /*-------------------------------*\                         /* 0101 */
      |  Append default file extension  |                         /* 0102 */
      \*-------------------------------*/                         /* 0103 */
      specified_rc_name = specified_rc_name || '.RC'              /* 0104 */
   end                                                            /* 0105 */
GBL.rc_name = STREAM( specified_rc_name, 'C', 'QUERY EXISTS' )    /* 0106 */
if GBL.rc_name = '' then                                          /* 0107 */
   do                                                             /* 0108 */
      GBL.error_count = GBL.error_count + 1                       /* 0109 */
      say COPIES( ' ', 3 )               ||,                      /* 0110 */
          specified_rc_name              ||,                      /* 0111 */
          ' is not a valid file name'                             /* 0112 */
   end                                                            /* 0113 */
                                                                  /* 0114 */
/*------------------------------------------------*\              /* 0115 */
|  Validate presence of TEMP environment variable  |              /* 0116 */
|  and get next available sequential extension     |              /* 0117 */
\*------------------------------------------------*/              /* 0118 */
temp_directory = VALUE( 'TEMP',, GBL.environment )                /* 0119 */
if temp_directory = '' then                                       /* 0120 */
   do                                                             /* 0121 */
      GBL.error_count = GBL.error_count + 1                       /* 0122 */
      say '   TEMP environment variable must point to a valid directory' ||,
          ' for output file'                                      /* 0124 */
   end                                                            /* 0125 */
else                                                              /* 0126 */
   do                                                             /* 0127 */
      /*-------------------------------------*\                   /* 0128 */
      |  Find next available sequence number  |                   /* 0129 */
      \*-------------------------------------*/                   /* 0130 */
      temp_arg = temp_directory || '\' || fn || '*.*'             /* 0131 */
      call SysFileTree temp_arg, 'temp_stem', 'F'                 /* 0132 */
      next_sequence_number = 0                                    /* 0133 */
      if temp_stem.0 > 0 then                                     /* 0134 */
         do ts = 1 to temp_stem.0                                 /* 0135 */
            parse value temp_stem.ts with,                        /* 0136 */
               file_date,                                         /* 0137 */
               file_time,                                         /* 0138 */
               file_size,                                         /* 0139 */
               file_attr,                                         /* 0140 */
               file_path_and_name                                 /* 0141 */
            file_path_and_name = STRIP( file_path_and_name )      /* 0142 */
            parse value FILESPEC( 'N', file_path_and_name ) with, /* 0143 */
               file_name '.' file_ext                             /* 0144 */
            sequence_number = RIGHT( file_name, 2 )               /* 0145 */
            if DATATYPE( sequence_number ) = 'NUM' then           /* 0146 */
               do                                                 /* 0147 */
                  next_sequence_number = sequence_number + 1      /* 0148 */
               end                                                /* 0149 */
         end                                                      /* 0150 */
   end                                                            /* 0151 */
GBL.output_file   = temp_directory                                        ||,
                    '\' || fn || RIGHT( next_sequence_number, 2, '0' )    ||,
                    '.CMD'                                        /* 0154 */
GBL.program_title = FILESPEC( 'N', GBL.output_file )                      ||,
                    ' - Program to recreate '                             ||,
                    GBL.object_id                                         ||,
                    ' related objects'                            /* 0158 */
                                                                  /* 0159 */
/*----------------------------*\                                  /* 0160 */
|  Check for any prior errors  |                                  /* 0161 */
\*----------------------------*/                                  /* 0162 */
if GBL.error_count > 0 then                                       /* 0163 */
   do                                                             /* 0164 */
      say '   Program cancelled because of above errors'          /* 0165 */
      call EOJ                                                    /* 0166 */
   end                                                            /* 0167 */
                                                                  /* 0168 */
/*------------------------------------------*\                    /* 0169 */
|  Strings for building object REXX program  |                    /* 0170 */
\*------------------------------------------*/                    /* 0171 */
GBL.width      = 76                 /* maximum program line width */
GBL.tl         = '/*-'              /* top left */                /* 0173 */
GBL.tr         = '-*\'              /* top right */               /* 0174 */
GBL.bl         = '\*-'              /* bottom left */             /* 0175 */
GBL.br         = '-*/'              /* bottom right */            /* 0176 */
GBL.horizontal = '-'                /* horizontal fill character */
GBL.left_vert  = '|  '              /* vertical fill character */ /* 0178 */
GBL.right_vert = '  |'              /* vertical fill character */ /* 0179 */
                                                                  /* 0180 */
i= 0                                                              /* 0181 */
i=i+1; GBL.program_init.i =,                                      /* 0182 */
         GBL.tl                                                           ||,
         COPIES( GBL.horizontal, GBL.width - 6 )                          ||,
         GBL.tr                                                   /* 0185 */
i=i+1; GBL.program_init.i =,                                      /* 0186 */
         GBL.left_vert                                                    ||,
         COPIES( ' ', GBL.width - 6 )                                     ||,
         GBL.right_vert                                           /* 0189 */
i=i+1; GBL.program_init.i =,                                      /* 0190 */
         GBL.left_vert                                                    ||,
         CENTER( GBL.program_title, GBL.width - 6 )                       ||,
         GBL.right_vert                                           /* 0193 */
i=i+1; GBL.program_init.i =,                                      /* 0194 */
         GBL.left_vert                                                    ||,
         COPIES( ' ', GBL.width - 6 )                                     ||,
         GBL.right_vert                                           /* 0197 */
i=i+1; GBL.program_init.i =,                                      /* 0198 */
         GBL.left_vert                                                    ||,
         CENTER( 'Created by FIXOBJ - Copyright 1994 by C F S Nevada, Inc.',,
                 GBL.width - 6 )                                          ||,
         GBL.right_vert                                           /* 0202 */
i=i+1; GBL.program_init.i =,                                      /* 0203 */
         GBL.left_vert                                                    ||,
         CENTER( 'Written by Dick Goran - 71154.2002@compuserve.com',,
                 GBL.width - 6 )                                          ||,
         GBL.right_vert                                           /* 0207 */
i=i+1; GBL.program_init.i =,                                      /* 0208 */
         GBL.left_vert                                                    ||,
         COPIES( ' ', GBL.width - 6 )                                     ||,
         GBL.right_vert                                           /* 0211 */
i=i+1; GBL.program_init.i =,                                      /* 0212 */
         GBL.bl                                                           ||,
         COPIES( GBL.horizontal, GBL.width - 6 )                          ||,
         GBL.br                                                   /* 0215 */
i=i+1; GBL.program_init.i = '/*'                                  /* 0216 */
i=i+1; GBL.program_init.i = ' '                                   /* 0217 */
i=i+1; GBL.program_init.i =,                                      /* 0218 */
         COPIES( ' ', 3 )                                                 ||,
         'This program will recreate all of the standard system'          ||,
         ' objects related'                                       /* 0221 */
i=i+1; GBL.program_init.i =,                                      /* 0222 */
         COPIES( ' ', 3 )                                                 ||,
         'to '                                                            ||,
         GBL.object_id                                                    ||,
         ' from the information in '                                      ||,
         GBL.rc_name                                                      ||,
         '.'                                                      /* 0228 */
i=i+1; GBL.program_init.i = ' '                                   /* 0229 */
i=i+1; GBL.program_init.i = '*/'                                  /* 0230 */
i=i+1; GBL.program_init.i = ' '                                   /* 0231 */
i=i+1; GBL.program_init.i =,                                      /* 0232 */
         'call RxFuncAdd "SysLoadFuncs", "REXXUTIL", "SysLoadFuncs"'
i=i+1; GBL.program_init.i =,                                      /* 0234 */
         'call SysLoadFuncs'                                      /* 0235 */
i=i+1; GBL.program_init.i =,                                      /* 0236 */
         'say "Begin' FILESPEC( 'N', GBL.output_file ) 'at" TIME("N")'
i=i+1; GBL.program_init.i = ' '                                   /* 0238 */
       GBL.program_init.0 = i                                     /* 0239 */
                                                                  /* 0240 */
i= 0                                                              /* 0241 */
i=i+1; GBL.program_body.i =,                                      /* 0242 */
         'call SysCreateObject class, title, location, setup_string, "F"'
i=i+1; GBL.program_body.i =,                                      /* 0244 */
         'if RESULT <> 1 then'                                    /* 0245 */
i=i+1; GBL.program_body.i =,                                      /* 0246 */
         '   do'                                                  /* 0247 */
i=i+1; GBL.program_body.i =,                                      /* 0248 */
         '      say "   Unable to create" title'                  /* 0249 */
i=i+1; GBL.program_body.i =,                                      /* 0250 */
         '      if class = "WPFolder" then SIGNAL END_OF_JOB'     /* 0251 */
i=i+1; GBL.program_body.i =,                                      /* 0252 */
         '   end'                                                 /* 0253 */
i=i+1; GBL.program_body.i =,                                      /* 0254 */
         'else'                                                   /* 0255 */
i=i+1; GBL.program_body.i =,                                      /* 0256 */
         '   do'                                                  /* 0257 */
i=i+1; GBL.program_body.i =,                                      /* 0258 */
         '      say "  " title "created in/on" location'          /* 0259 */
i=i+1; GBL.program_body.i =,                                      /* 0260 */
         '   end'                                                 /* 0261 */
i=i+1; GBL.program_body.i = ' '                                   /* 0262 */
       GBL.program_body.0 = i                                     /* 0263 */
                                                                  /* 0264 */
/*----------------------------------------------------------*\    /* 0265 */
|  Process each line in .RC file which references object ID  |    /* 0266 */
\*----------------------------------------------------------*/    /* 0267 */
do while LINES( GBL.rc_name ) > 0                                 /* 0268 */
                                                                  /* 0269 */
   input_line = LINEIN( GBL.rc_name )                             /* 0270 */
   if POS( GBL.object_id, input_line ) = 0 then iterate /* ignore if unrelated */
                                                                  /* 0272 */
   /*----------------------*\                                     /* 0273 */
   |  Isolate setup string  |                                     /* 0274 */
   \*----------------------*/                                     /* 0275 */
   setup_string_beg_ptr = LASTPOS( '"', input_line, LENGTH( input_line ) - 1 )
   if setup_string_beg_ptr = 0 then                               /* 0277 */
      do                                                          /* 0278 */
         say '   Unable to locate setup string for:'              /* 0279 */
         say '   ' ||,                                            /* 0280 */
             input_line                                           /* 0281 */
         iterate                                                  /* 0282 */
      end                                                         /* 0283 */
   setup_string_beg_ptr = setup_string_beg_ptr + 1                /* 0284 */
                                                                  /* 0285 */
   /*------------------------------------------------------*\     /* 0286 */
   |  Isolate class, title, location and optionally option  |     /* 0287 */
   \*------------------------------------------------------*/     /* 0288 */
   parse value input_line with,                                   /* 0289 */
      title_class_location_option   =(setup_string_beg_ptr),      /* 0290 */
      setup_string   '"'                                          /* 0291 */
   parse value title_class_location_option with,                  /* 0292 */
      .                 '"PM_InstallObject"',                     /* 0293 */
      .                 '"',                                      /* 0294 */
      title             ';',                                      /* 0295 */
      class             ';',                                      /* 0296 */
      location_option   '"',                                      /* 0297 */
      .                                                           /* 0298 */
   if POS( ';', location_option ) > 0 then                        /* 0299 */
      do                                                          /* 0300 */
         parse value location_option with,                        /* 0301 */
            location  ';',                                        /* 0302 */
            option                                                /* 0303 */
      end                                                         /* 0304 */
   else                                                           /* 0305 */
      do                                                          /* 0306 */
         location = location_option                               /* 0307 */
         option = ''                                              /* 0308 */
      end                                                         /* 0309 */
                                                                  /* 0310 */
   /*------------------------------*\                             /* 0311 */
   |  Program initialization lines  |                             /* 0312 */
   \*------------------------------*/                             /* 0313 */
   if GBL.object_count = 0 then                                   /* 0314 */
      do i = 1 to GBL.program_init.0                              /* 0315 */
         call LINEOUT GBL.output_file, GBL.program_init.i         /* 0316 */
      end                                                         /* 0317 */
   GBL.object_count = GBL.object_count + 1                        /* 0318 */
                                                                  /* 0319 */
   /*-------------------------------*\                            /* 0320 */
   |  Program lines to build object  |                            /* 0321 */
   \*-------------------------------*/                            /* 0322 */
   output_line = GBL.tl                                                   ||,
                 COPIES( GBL.horizontal, LENGTH( title ) )                ||,
                 GBL.tr                                           /* 0325 */
   call LINEOUT GBL.output_file, output_line                      /* 0326 */
   output_line = GBL.left_vert                                            ||,
                 title                                                    ||,
                 GBL.right_vert                                   /* 0329 */
   call LINEOUT GBL.output_file, output_line                      /* 0330 */
   output_line = GBL.bl                                                   ||,
                 COPIES( GBL.horizontal, LENGTH( title ) )                ||,
                 GBL.br                                           /* 0333 */
   call LINEOUT GBL.output_file, output_line                      /* 0334 */
                                                                  /* 0335 */
   output_line = LEFT( 'title', 12 )                                      ||,
                 ' = "' || title || '"'                           /* 0337 */
   call LINEOUT GBL.output_file, output_line                      /* 0338 */
   output_line = LEFT( 'class', 12 )                                      ||,
                 ' = "' || class || '"'                           /* 0340 */
   call LINEOUT GBL.output_file, output_line                      /* 0341 */
   output_line = LEFT( 'location', 12 )                                   ||,
                 ' = "' || location || '"'                        /* 0343 */
   call LINEOUT GBL.output_file, output_line                      /* 0344 */
   output_line = LEFT( 'setup_string', 12 )                               ||,
                 ' =,'                                            /* 0346 */
   call LINEOUT GBL.output_file, output_line                      /* 0347 */
   do while setup_string <> ''                                    /* 0348 */
      parse value setup_string with,                              /* 0349 */
         token ';' setup_string                                   /* 0350 */
      output_line = COPIES( ' ', 6 )                                      ||,
                    '"' || token || ';"'                          /* 0352 */
      if LENGTH( output_line ) < ( GBL.width - 3 )then            /* 0353 */
         do                                                       /* 0354 */
            output_line = LEFT( output_line, GBL.width - 3 )              ||,
                          '||,'                                   /* 0356 */
         end                                                      /* 0357 */
      else                                                        /* 0358 */
         do                                                       /* 0359 */
            output_line = output_line || ' ||,'                   /* 0360 */
         end                                                      /* 0361 */
      call LINEOUT GBL.output_file, output_line                   /* 0362 */
   end                                                            /* 0363 */
   output_line = COPIES( ' ', 6 )                                         ||,
                 '""'                                             /* 0365 */
   call LINEOUT GBL.output_file, output_line                      /* 0366 */
                                                                  /* 0367 */
   do i = 1 to GBL.program_body.0                                 /* 0368 */
      call LINEOUT GBL.output_file, GBL.program_body.i            /* 0369 */
   end                                                            /* 0370 */
                                                                  /* 0371 */
end                                                               /* 0372 */
call LINEOUT GBL.output_file, 'END_OF_JOB:'                       /* 0373 */
output_line =,                                                    /* 0374 */
   'say "End  ' FILESPEC( 'N', GBL.output_file ) 'at" TIME("N")'  /* 0375 */
call LINEOUT GBL.output_file, output_line                         /* 0376 */
call LINEOUT GBL.output_file, 'exit'                              /* 0377 */
                                                                  /* 0378 */
if GBL.object_count > 0 then                                      /* 0379 */
   do                                                             /* 0380 */
      call STREAM GBL.output_file, 'C', 'CLOSE'                   /* 0381 */
      say '  ' GBL.output_file 'has been created'                 /* 0382 */
   end                                                            /* 0383 */
else                                                              /* 0384 */
   do                                                             /* 0385 */
      say '   Unable to find any objects matching '                       ||,
          GBL.object_id                                           /* 0387 */
   end                                                            /* 0388 */
                                                                  /* 0389 */
call EOJ 0                                                        /* 0390 */
                                                                  /* 0391 */
                                                                  /* 0392 */
/*------------------------------------------------------------------------*\
|                                                                          |
|                  Request paramters be entered manually                   |
|                                                                          |
\*------------------------------------------------------------------------*/
GET_PARAMETERS_INTERACTIVELY:                                     /* 0398 */
say '   Enter object ID of object to be rebuilt'                  /* 0399 */
parse pull specified_object_id                                    /* 0400 */
say '   Enter option .RC file path and name or <Enter> if INI.RC' /* 0401 */
pull specified_rc_name                                            /* 0402 */
return                                                            /* 0403 */
                                                                  /* 0404 */
                                                                  /* 0405 */
!tr! = VALUE('TRACE',,GBL.environment); if !tr! <> '' then do; TRACE(!tr!); nop; end
/*------------------------------------------------------------------------*\
|                                                                          |
|                                End of Job                                |
|                                                                          |
\*------------------------------------------------------------------------*/
EOJ:                                                              /* 0412 */
   Procedure expose,                                              /* 0413 */
      GBL.                                                        /* 0414 */
                                                                  /* 0415 */
if ARG() = 0 then                                                 /* 0416 */
   eoj_rc = 0                                                     /* 0417 */
else                                                              /* 0418 */
   eoj_rc = ARG(1)                                                /* 0419 */
                                                                  /* 0420 */
elapsed_time = TIME('E')            /* get elapsed time - sssss.uuuuu */
parse value elapsed_time with seconds '.' micro_seconds           /* 0422 */
if LEFT( micro_seconds, 1, 1 ) >= 5 then                          /* 0423 */
   seconds = seconds + 1                                          /* 0424 */
ss = FORMAT( seconds // 60, 2 )                                   /* 0425 */
minutes = ( seconds - ss ) / 60                                   /* 0426 */
mm = FORMAT( minutes // 60, 2 )                                   /* 0427 */
hh = FORMAT( ( minutes - mm ) / 60, 2 )                           /* 0428 */
duration = hh':'mm':'ss                                           /* 0429 */
                                                                  /* 0430 */
program_name = TRANSLATE( FILESPEC( 'N', GBL.program_path_and_name ) )
say 'EOJ  ' program_name 'at' TIME('N') ||,                       /* 0432 */
    ', duration' TRANSLATE( duration, '0', ' ' )                  /* 0433 */
exit eoj_rc                                                       /* 0434 */
                                                                  /* 0435 */
/*------------------------------------------------------------------------*\
|                                                                          |
|                   Register external function routines                    |
|                                                                          |
\*------------------------------------------------------------------------*/
REGISTER_REQUIRED_FUNCTIONS:                                      /* 0441 */
   Procedure expose GBL.REXX_version                              /* 0442 */
                                                                  /* 0443 */
/*----------------------------------------*\                      /* 0444 */
|  Load REXXUtil External Function Module  |                      /* 0445 */
\*----------------------------------------*/                      /* 0446 */
module             = 'REXXUTIL'                                   /* 0447 */
entry_name         = 'SysLoadFuncs'                               /* 0448 */
function_name      = 'SysLoadFuncs'                               /* 0449 */
anticipated_return = ''                                           /* 0450 */
call REGISTER_ROUTINE function_name module entry_name anticipated_return
return                                                            /* 0452 */
                                                                  /* 0453 */
                                                                  /* 0454 */
/*---------------------*\                                         /* 0455 */
|  Register Subroutine  |                                         /* 0456 */
\*---------------------*/                                         /* 0457 */
REGISTER_ROUTINE:                                                 /* 0458 */
   Procedure                                                      /* 0459 */
                                                                  /* 0460 */
parse ARG  function_name,                                         /* 0461 */
           module,                                                /* 0462 */
           entry_name,                                            /* 0463 */
           anticipated_return                                     /* 0464 */
                                                                  /* 0465 */
if RxFuncQuery(function_name) = 0 then return      /* function registered */
                                                                  /* 0467 */
if LENGTH(module) > 8 then                                        /* 0468 */
   do                                                             /* 0469 */
      dll_drive = FILESPEC( 'D', module )                         /* 0470 */
      dll_path  = STRIP( FILESPEC( 'P', module ), 'T', '\' )      /* 0471 */
      module    = FILESPEC( 'N', module )                         /* 0472 */
      '@' || dll_drive                                            /* 0473 */
      '@cd' dll_drive || dll_path                                 /* 0474 */
   end                                                            /* 0475 */
else                                                              /* 0476 */
   do                                                             /* 0477 */
      dll_drive = ''                                              /* 0478 */
   end                                                            /* 0479 */
                                                                  /* 0480 */
parse var module module_fname '.' module_fext                     /* 0481 */
if RxFuncAdd( function_name, module_fname, entry_name ) = 0 then  /* 0482 */
   do                                                             /* 0483 */
      register_call = 'call' function_name                        /* 0484 */
      interpret register_call                                     /* 0485 */
      if WORD( RESULT, 1 ) <> WORD( anticipated_return, 1 ) then  /* 0486 */
         do                                                       /* 0487 */
            Say function_name 'returned' RESULT '-',              /* 0488 */
                                         anticipated_return 'was expected'
            exit 255                                              /* 0490 */
         end                                                      /* 0491 */
   end                                                            /* 0492 */
else                                                              /* 0493 */
   do                                                             /* 0494 */
      Say 'RxFuncAdd returned' RESULT 'registering' module        /* 0495 */
      exit 254                                                    /* 0496 */
   end                                                            /* 0497 */
if dll_drive <> '' then                                           /* 0498 */
   do                                                             /* 0499 */
      Parse Source . . GBL.program_path_and_name                  /* 0500 */
      '@' || LEFT( GBL.program_path_and_name, 2 )                 /* 0501 */
   end                                                            /* 0502 */
return                                                            /* 0503 */
                                                                  /* 0504 */
/*------------------------------------------------------------------------*\
|                                                                          |
|                              Trap Routines                               |
|                                                                          |
\*------------------------------------------------------------------------*/
ERROR:   call TRAP_PROCESSING SIGL, 'ERROR',   RC                 /* 0510 */
FAILURE: call TRAP_PROCESSING SIGL, 'FAILURE', RC                 /* 0511 */
HALT:    call TRAP_PROCESSING SIGL, 'HALT',    ''                 /* 0512 */
NOVALUE: call TRAP_PROCESSING SIGL, 'NOVALUE', ''                 /* 0513 */
SYNTAX:  call TRAP_PROCESSING SIGL, 'SYNTAX',  RC                 /* 0514 */
                                                                  /* 0515 */
/* Rev. 94/06/14 */                                               /* 0516 */
TRAP_PROCESSING:                                                  /* 0517 */
   parse Source . . TRAP.path_and_program                         /* 0518 */
   if POS( ':', TRAP.path_and_program ) > 0 then                  /* 0519 */
      /* get source line if it is available */                    /* 0520 */
      do                                                          /* 0521 */
         trap_source_line = STRIP( SOURCELINE(ARG(1)) )           /* 0522 */
      end                                                         /* 0523 */
   else                                                           /* 0524 */
      /* program is running in macrospace */                      /* 0525 */
      do                                                          /* 0526 */
         TRAP.path_and_program = VALUE( 'TEMP',, 'OS2ENVIRONMENT' ) ||,
                                 TRAP.path_and_program            /* 0528 */
         trap_source_line = 'Source line is not available.'       /* 0529 */
      end                                                         /* 0530 */
                                                                  /* 0531 */
   parse value FILESPEC( 'N', TRAP.path_and_program ) with,       /* 0532 */
      TRAP.fn '.' TRAP.fe                                         /* 0533 */
   trap_file_name = FILESPEC( 'D', TRAP.path_and_program ) ||,    /* 0534 */
                    FILESPEC( 'P', TRAP.path_and_program ) ||,    /* 0535 */
                    TRAP.fn || '.' || 'DMP'                       /* 0536 */
                                                                  /* 0537 */
   /*------------------------------------------*\                 /* 0538 */
   |  check for reason not to create .DMP file  |                 /* 0539 */
   \*------------------------------------------*/                 /* 0540 */
   if ARG(2) = 'HALT' then                                        /* 0541 */
      do                                                          /* 0542 */
         trap_file_name = ''                                      /* 0543 */
      end                                                         /* 0544 */
   if RxFuncQuery( 'VARDUMP' ) <> 0 then                          /* 0545 */
      do                                                          /* 0546 */
         trap_file_name = ''                                      /* 0547 */
      end                                                         /* 0548 */
   if POS( ':', trap_file_name ) = 0 then                         /* 0549 */
      do                                                          /* 0550 */
         trap_file_name = ''                                      /* 0551 */
      end                                                         /* 0552 */
                                                                  /* 0553 */
   /*------------------------*\                                   /* 0554 */
   |  Build trap message box  |                                   /* 0555 */
   \*------------------------*/                                   /* 0556 */
   dbl.h    = 'CD'x                 /* Í double line - horizontal   */
   dbl.v    = 'BA'x                 /* º double line - vertical     */
   dbl.bl   = 'C8'x                 /* È double line - bottom left  */
   dbl.br   = 'BC'x                 /* ¼ double line - bottom right */
   dbl.tl   = 'C9'x                 /* É double line - top left     */
   dbl.tr   = 'BB'x                 /* » double line - top right    */
   say ' '                                                        /* 0563 */
   trap_error_description =,                                      /* 0564 */
      'Error line = ' || ARG(1) ||,                               /* 0565 */
      '; ' ||,                                                    /* 0566 */
      ARG(2) ||,                                                  /* 0567 */
      ' error.'                                                   /* 0568 */
   if ARG(3) <> '' then                                           /* 0569 */
      trap_error_description = trap_error_description ||,         /* 0570 */
                               '  Return code = ' || ARG(3)       /* 0571 */
   say dbl.tl || COPIES( dbl.h, LENGTH(trap_error_description) + 2 ) || dbl.tr
   say dbl.v  || COPIES( ' ',   LENGTH(trap_error_description) + 2 ) || dbl.v
   say dbl.v CENTER( TRAP.fn || '.CMD', LENGTH(trap_error_description)) dbl.v
   say dbl.v               trap_error_description                       dbl.v
   if trap_file_name <> '' then                                   /* 0576 */
      do                                                          /* 0577 */
   say dbl.v  || COPIES( ' ',   LENGTH(trap_error_description) + 2 ) || dbl.v
   say dbl.v     CENTER( 'See: ' || trap_file_name,,              /* 0579 */
                                      LENGTH(trap_error_description) )  dbl.v
      end                                                         /* 0581 */
   say dbl.v  || COPIES( ' ',   LENGTH(trap_error_description) + 2 ) || dbl.v
   say dbl.bl || COPIES( dbl.h, LENGTH(trap_error_description) + 2 ) || dbl.br
   say ' '                                                        /* 0584 */
   say 'Source line at time of trap:'                             /* 0585 */
   say '   ' || trap_source_line                                  /* 0586 */
   say ' '                                                        /* 0587 */
                                                                  /* 0588 */
   /*---------------------------------*\                          /* 0589 */
   |  Create .DMP file if appropriate  |                          /* 0590 */
   \*---------------------------------*/                          /* 0591 */
   if trap_file_name <> '' then                                   /* 0592 */
      do                                                          /* 0593 */
         call SysFileDelete trap_file_name                        /* 0594 */
         /* remove meaningless labels from dump for clarity */    /* 0595 */
         drop dbl. TRAP. RC RESULT SIGL !tr!                      /* 0596 */
         call VARDUMP trap_file_name  /* write variables to program.DMP file */
      end                                                         /* 0598 */
   exit 254                                                       /* 0599 */
/*---------  REXX Cross Reference  - Created: 11/24/94 3:36pm ----------*\

---- VARIABLES ----
!tr!                0406<  0406   0406   0596
GBL.                0041<  0414
GBL.REXX_version    0042   0442
GBL.bl              0175<  0213   0331
GBL.boot_drive      0047<  0096
GBL.br              0176<  0215   0333
GBL.calling_environment
                    0044
GBL.environment     0046<  0047   0119   0406
GBL.error_count     0053<  0109<  0109   0122<  0122   0163
GBL.horizontal      0177<  0184   0214   0324   0332
GBL.left_vert       0178<  0187   0191   0195   0199   0204   0209   0327
GBL.object_count    0054<  0314   0318<  0318   0379
GBL.object_id       0089<  0157   0225   0271   0387
GBL.operating_system
                    0043   0058
GBL.output_file     0152<  0155   0237   0316   0326   0330   0334   0338
                    0341   0344   0347   0362   0366   0369   0373   0375
                    0376   0377   0381   0382
GBL.program_body.0  0263<  0368
GBL.program_body.i  0242<  0244<  0246<  0248<  0250<  0252<  0254<  0256<
                    0258<  0260<  0262<  0369
GBL.program_init.0  0239<  0315
GBL.program_init.i  0182<  0186<  0190<  0194<  0198<  0203<  0208<  0212<
                    0216<  0217<  0218<  0222<  0229<  0230<  0231<  0232<
                    0234<  0236<  0238<  0316
GBL.program_name    0048<  0051   0057
GBL.program_path    0049<
GBL.program_path_and_name
                    0045   0048   0049   0050   0431   0500   0501
GBL.program_title   0155<  0192
GBL.program_version
                    0052<
GBL.rc_name         0106<  0107   0227   0268   0270
GBL.right_vert      0179<  0189   0193   0197   0202   0207   0211   0329
GBL.tl              0173<  0183   0323
GBL.tr              0174<  0185   0325
GBL.width           0172<  0184   0188   0192   0196   0201   0206   0210
                    0214   0353   0355
RC                  0510   0511   0514   0596
RESULT              0486   0488   0495   0596
SIGL                0510   0511   0512   0513   0514   0596
TRAP.               0596
TRAP.fe             0533
TRAP.fn             0533   0536   0574
TRAP.path_and_program
                    0518   0519   0527<  0528   0532   0534   0535
Version             0042
anticipated_return  0450<  0451   0464   0486   0489
class               0296   0340
dbl.                0596
dbl.bl              0559<  0583
dbl.br              0560<  0583
dbl.h               0557<  0572   0583
dbl.tl              0561<  0572
dbl.tr              0562<  0572
dbl.v               0558<  0573   0573   0574   0574   0575   0575   0578
                    0578   0579   0580   0582   0582
dll_drive           0470<  0473   0474   0478<  0498
dll_path            0471<  0474
duration            0429<  0433
elapsed_time        0421<  0422
entry_name          0448<  0451   0463   0482
eoj_rc              0417<  0419<  0434
fe                  0051
file_attr           0140
file_date           0137
file_ext            0144
file_name           0144   0145
file_path_and_name  0141   0142<  0142   0143
file_size           0139
file_time           0138
fn                  0051   0131   0153
function_name       0449<  0451   0461   0466   0482   0484   0488
hh                  0428<  0429
i                   0181<  0182<  0182   0186<  0186   0190<  0190   0194<
                    0194   0198<  0198   0203<  0203   0208<  0208   0212<
                    0212   0216<  0216   0217<  0217   0218<  0218   0222<
                    0222   0229<  0229   0230<  0230   0231<  0231   0232<
                    0232   0234<  0234   0236<  0236   0238<  0238   0239
                    0241<  0242<  0242   0244<  0244   0246<  0246   0248<
                    0248   0250<  0250   0252<  0252   0254<  0254   0256<
                    0256   0258<  0258   0260<  0260   0262<  0262   0263
                    0315   0368
input_line          0270<  0271   0276   0276   0281   0289
location            0302   0307<  0343
location_option     0297   0299   0301   0307
micro_seconds       0422   0423
minutes             0426<  0427   0428
mm                  0427<  0428   0429
module              0447<  0451   0462   0468   0470   0471   0472<  0472
                    0481   0495
module_fext         0481
module_fname        0481   0482
next_sequence_number
                    0133<  0148<  0153
option              0303   0308<
output_line         0323<  0326   0327<  0330   0331<  0334   0336<  0338
                    0339<  0341   0342<  0344   0345<  0347   0351<  0353
                    0355<  0355   0360<  0360   0362   0364<  0366   0374<
                    0376
program_name        0431<  0432
register_call       0484<  0485
seconds             0422   0424<  0424   0425   0426
sequence_number     0145<  0146   0148
setup_string        0291   0348   0349   0350
setup_string_beg_ptr
                    0276<  0277   0284<  0284   0290
specified_object_id
                    0070   0072   0079   0081<  0082   0084   0086<  0086
                    0089   0400
specified_rc_name   0071   0094   0096<  0099   0104<  0104   0106   0111
                    0402
ss                  0425<  0426   0429
temp_arg            0131<  0132
temp_directory      0119<  0120   0131   0152
temp_stem.0         0134   0135
temp_stem.ts        0136
title               0295   0324   0328   0332   0337
title_class_location_option
                    0290   0292
token               0350   0352
trap_error_description
                    0564<  0570<  0570   0572   0573   0574   0575   0578
                    0580   0582   0583
trap_file_name      0534<  0543<  0547<  0549   0551<  0576   0579   0592
                    0594   0597
trap_source_line    0522<  0529<  0586
ts                  0135
with                0051   0136   0143   0289   0292   0301   0349   0422
                    0532
x                   0557   0558   0559   0560   0561   0562

---- LABELS ----
EOJ                 0166   0390   0412:
ERROR               0036   0510:
FAILURE             0511:
GET_PARAMETERS_INTERACTIVELY
                    0073   0398:
HALT                0037   0512:
NOVALUE             0038   0513:
REGISTER_REQUIRED_FUNCTIONS
                    0063   0441:
REGISTER_ROUTINE    0451   0458:
SYNTAX              0039   0514:
TRAP_PROCESSING     0510   0511   0512   0513   0514   0517:

---- FUNCTIONS ----
ARG                 0416   0419   0522   0541   0565   0567   0569   0571
CENTER              0192   0200   0205   0574   0579
COPIES              0110   0184   0188   0196   0210   0214   0219   0223
                    0324   0332   0351   0364   0572   0573   0578   0582
                    0583
DATATYPE            0146
FILESPEC            0048   0049   0050   0143   0155   0237   0375   0431
                    0470   0471   0472   0532   0534   0535
FORMAT              0425   0427   0428
LASTPOS             0276
LEFT                0047   0079   0336   0339   0342   0345   0355   0423
                    0501
LENGTH              0276   0324   0332   0353   0468   0572   0573   0574
                    0578   0580   0582   0583
LINEIN              0270
LINEOUT             0316   0326   0330   0334   0338   0341   0344   0347
                    0362   0366   0369   0373   0376   0377
LINES               0268
POS                 0099   0271   0299   0519   0549
RIGHT               0084   0145   0153
RxFuncAdd           0482
RxFuncQuery         0466   0545
SOURCELINE          0522
STREAM              0106   0381
STRIP               0142   0471   0522
SysFileDelete       0594
SysFileTree         0132
TIME                0055   0057   0421   0432
TRACE               0406
TRANSLATE           0057   0089   0431   0433
VALUE               0047   0119   0406   0527
VARDUMP             0597
WORD                0486   0486

\*-------------------  End of REXX Cross Reference  -------------------*/
