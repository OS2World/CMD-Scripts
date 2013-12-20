/* Do checks common to both pinstall and pppcnt */

    Parse Arg acct .


/* Look for TCPOS2.INI file */

            inif=SysSearchPath("ETC","tcpos2.ini")
            If(inif="") Then
               Do
                Say "TCPOS2.INI file not found, perhaps TCPIP is not installed."
                Return ""
               End

/* This account found in TCPOS2.INI? */

            ty=SysIni(inif, acct, 'SERVICE')         /* test INI for account  */
            If(ty='ERROR:') Then
               Do
                Say "Create" acct "in Dial Other Providers, Account not found."
                Return ""
               End
            ty=Delstr(ty, Length(ty))

/* Service set for SLIP or PPP? */

            If(ty<>'PPP') Then
               Do
                Say "Check" acct "in Dial Other Providers, Not a PPP account!"
                Return ""
               End

               Return inif

