/* ------------------------------------------------------------------ */
/*                                                                    */
/*             sample program to show the use of RXLBOX               */
/*                                                                    */
/*            This program uses the menu file SETVARS.INI             */
/*                                                                    */
/* The menu file used in this sample is a real world sample. It's a   */
/* menu file we're using in our CID installations.                    */
/* ------------------------------------------------------------------ */

                    /* names of the environment variables used to     */
                    /* pass data between RxLBox and SAMPLE3.CMD       */
  envVars = ,
    'M_MACHINETYPE',
    'M_LOCATION',
    'M_LANGUAGE',
    'M_FDISKFILE',
    'M_DISPLAY',
    'M_CDROM',
    'M_SOUNDCARD',
    'M_TRAdapter',
    'M_CDROM',
    'M_TCPID',
    'M_MODEL_NUM',
    'M_SERIAL_NUM',
    'M_PLANT_MFG',
    'M_MACHINE_TYPE',
    ''

                    /* do some initializations (set the default       */
                    /* values)                                        */
                    /*                                                */
                    /* (In our CID installation MINIMENU executes the */
                    /* section INITMINIMENU from the menu file to     */
                    /* init the variables)                            */
  call value 'M_LOCATION',        'ESCHBORN',                     'OS2ENVIRONMENT'
  call value 'M_LANGUAGE',        'German',                       'OS2ENVIRONMENT'
  call value 'M_FDISKFILE',       '1_GB_HD_(200/rest)',           'OS2ENVIRONMENT'
  call value 'M_MACHINETYPE',     'Desktop PC',                   'OS2ENVIRONMENT'
  call value 'M_DISPLAY',         'VGA',                          'OS2ENVIRONMENT'
  call value 'M_CDROM',           'SCSI',                         'OS2ENVIRONMENT'
  call value 'M_SOUNDCARD',       'MULTIMEDIA_WITHOUT_SOUND',     'OS2ENVIRONMENT'
  call value 'M_TRAdapter',       '3COM',                         'OS2ENVIRONMENT'
  call value 'M_CDROM',           'DETECT_CDROM',                 'OS2ENVIRONMENT'
  call value 'M_TCPID',           '123',                          'OS2ENVIRONMENT'
  call value 'M_MACHINE_TYPE',    'P166',                         'OS2ENVIRONMENT'
  call value 'M_MODEL_NUM',       'ATI',                          'OS2ENVIRONMENT'
  call value 'M_SERIAL_NUM',      'R000',                         'OS2ENVIRONMENT'
  call value 'M_PLANT_MFG',       '55',                           'OS2ENVIRONMENT'

                    /* fully qualified name of the menu file          */
  menuFile = directory() || '\setvars.ini'

                    /* call RxLBox                                    */
  thisRC = rxlbox( menuFile )

                    /* print the results to the screen                */
                    /*                                                */
                    /* (In our CID installation MINIMENU uses the     */
                    /* section ALIASSE and the other sections to      */
                    /* create the file SETVARS.CMD)                   */

  say
  say
  say 'RC = "' || thisRC || '"'

                    /* print the user choosen values to the screen    */
  do i = 1 to words( envVars )
    curEnvVar = word( envVars,i )
    say curEnvVar || '="' || value( curEnvVar,, 'OS2ENVIRONMENT' ) || '"'
  end /* do i = 1 to words( envVars ) */

                    /* delete the environment variables used to pass  */
                    /* data between RxLBox and SAMPLE3.CMD            */
                    /*                                                */
                    /* (In our CID installation MINIMENU executes the */
                    /* section EXITTMINIMENU from the menu file to    */
                    /* delete the variables)                          */
  do i = 1 to words( envVars )
    curEnvVar = word( envVars,i )
    call value curEnvVar, '', 'OS2ENVIRONMENT'
  end /* do i = 1 to words( envVars ) */
exit 0
