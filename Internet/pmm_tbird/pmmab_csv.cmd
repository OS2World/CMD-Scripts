/****************************************************************/
/*   Exports e-mail addresses from the PMMail address book,     */
/*   as CSV files suitable for importing into Thunderbird.      */
/*                                                              */
/*           Author:       Peter Moylan                         */
/*           Started:      27 February 2005                     */
/*           Last revised: 5 January 2006                       */
/*                                                              */
/*   Usage:                                                     */
/*           pmmab_CSV SourceDirectory DestinationDirectory     */
/*                                                              */
/*           where SourceDirectory is the directory that        */
/*           contains the files BOOK.DB and ADDR.DB, and        */
/*           DestinationDirectory is the directory where the    */
/*           CSV output files will be created.                  */
/*                                                              */
/*           The arguments are optional; the program assumes    */
/*           the current directory as the default.              */
/*                                                              */
/*   The *.DB file formats are for PMMail version 1.96, but     */
/*   are probably compatible with other versions.               */
/*                                                              */
/****************************************************************/

/* Check command line arguments. */

PARSE ARG InDirectory OutDirectory
IF InDirectory \= "" & LASTPOS('\', InDirectory) \= LENGTH(InDirectory) THEN
    InDirectory = InDirectory'\'
IF OutDirectory \= "" & LASTPOS('\', OutDirectory) \= LENGTH(OutDirectory) THEN
    OutDirectory = OutDirectory'\'

/* Read the books database, create output files. */

DataFile = InDirectory"BOOKS.DB"

DO WHILE lines(DataFile) = 1
    PARSE VALUE linein(DataFile) WITH BookName 'Þ' . 'Þ' . 'Þ' BookNumber 'Þ'
    CALL MakeFileName BookNumber BookName
    SAY BookNumber'. 'BookName
END

/* Now read the address database. */

DataFile = InDirectory"ADDR.DB"
DO WHILE lines(DataFile) = 1

    /* PMMail (v1.96) ADDR.DB format */

    PARSE VALUE linein(DataFile) WITH,
        EMail 'Þ' Alias 'Þ' Name 'Þ' Popup 'Þ' Company 'Þ' Title 'Þ',
        H_Street 'Þ' H_Building 'Þ' H_City 'Þ' H_State 'Þ' H_Code 'Þ',
        H_Phone 'Þ' H_Ext 'Þ' H_Fax 'Þ',
        B_Street 'Þ' B_Building 'Þ' B_City 'Þ'B_State 'Þ' B_Code 'Þ',
        B_Phone 'Þ' B_Ext 'Þ' B_Fax 'Þ',
        Notes 'Þ' BookNumber 'Þ' H_Country 'Þ' B_Country 'Þ'

    /* Split the name into components FirstName, LastName. */

    comma = 1
    k = LastPos( ',', Name )
    IF k = 0 THEN DO
        k = LastPos( ' ', Name )
        comma = 0
    END

    IF k = 0 THEN DO
        FirstName = STRIP(Name)
        LastName = ""
    END
    ELSE DO
        FirstName = STRIP(LEFT(Name, k-1))
        LastName = STRIP(SUBSTR(Name, k+1))
    END

    IF comma > 0 THEN DO
        temp = FirstName
        FirstName = LastName
        LastName = temp
    END

    /* Some fields might contain commas. */

    LastName = CommaCheck(LastName)
    Name = CommaCheck(Name)
    Alias = CommaCheck(Alias)
    H_Street = CommaCheck(H_Street)
    H_Building = CommaCheck(H_Building)
    H_City = CommaCheck(H_City)
    H_State = CommaCheck(H_State)
    H_Country = CommaCheck(H_Country)
    B_Street = CommaCheck(B_Street)
    B_Building = CommaCheck(B_Building)
    B_City = CommaCheck(B_City)
    B_State = CommaCheck(B_State)
    B_Country = CommaCheck(B_Country)
    Title = CommaCheck(Title)
    Company = CommaCheck(Company)
    Notes = CommaCheck(Notes)

    /* Thunderbird CSV format. */

    result = FirstName','LastName','Name','Alias',',
        EMail',,'B_Phone' 'B_Ext','H_Phone' 'H_Ext','H_Fax'  'B_Fax',,,',
        H_Street','H_Building','H_City','H_State','H_Code','H_Country',',
        B_Street','B_Building','B_City','B_State','B_Code','B_Country',',
        Title',,'Company',,,,,,,,,,'Notes

    result = TRANSLATE(result, '', 'á')

    /* Special case to watch out for: a single entry can be in  */
    /* more than one address book.                              */

    DO WHILE pos(';', BookNumber) \= 0
         PARSE var BookNumber j ';' BookNumber
         ret = lineout( OutputFile.j, result )
    END /* DO */
    ret = lineout( OutputFile.BookNumber, result )

END
EXIT

/***************************************************/
/* Procedure to put quote marks around a string    */
/* if it contains a comma.                         */
/***************************************************/

CommaCheck: PROCEDURE
    PARSE ARG str
    k = POS( ',', str )
    IF k = 0 THEN RETURN str
    ELSE RETURN '"'||str||'"'

/***************************************************/
/* Procedure to create the name of an output file, */
/* creating a backup if necessary.                 */
/***************************************************/

MakeFileName:
    PARSE ARG j BookName

    /* Watch out for characters that can't be part of a file    */
    /* name. To keep things simple I'm also translating spaces. */

    BookName = TRANSLATE(BookName, '__________', ' \/:*?"<>|')

    name = OutDirectory||BookName
    bakname = name'.bak'
    name = name'.csv'
    IF stream(name, 'c', 'query exists') \= "" THEN
        DO
            IF stream(bakname, 'c', 'query exists') \= "" THEN
                '@'del bakname
            '@'rename name bakname
        END
    OutputFile.j = name
    RETURN


