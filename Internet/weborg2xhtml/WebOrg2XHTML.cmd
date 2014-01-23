/*
 * Filename: WebOrg2XHTML.cmd
 *   Author: Michael DeBusk, m_debusk@despammed.com
 *  Created: 2005-04-10
 *  Purpose: Alters pages created by Web Organizer so that
 *           they use valid XHTML and CSS
 */

SAY 'WebOrganizer-to-XHTML conversion tool'
SAY 'Initial release, 2005-04-10'
SAY ''

/* Load RexxUtil Library */
IF RxFuncQuery('SysLoadFuncs') THEN
DO
    CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
    CALL SysLoadFuncs
END

/* Get the filenames */
CALL SysFileTree '*.htm', 'files.', 'FO'

/* We want an alias for the carriage return + line feed */
hrt = '0d0a'x

DO n = 1 TO files.0
    /* Read the file into a variable */
    buffer = CharIn(files.n, 1, Chars(files.n))
    rc = STREAM(files.n,'c','close')
    
    /*
     * append an "l" to the name of the current file
     * to get the name of the file to be written.
     * This step requires the files not be on FAT
     */
    fnOut = files.n || 'l'
    IF Stream(fnOut, 'C', 'QUERY EXISTS') <> '' THEN
    DO /* Delete the write-out file if it exists */
        rc = SysFileDelete(fnOut)
    END /* Delete the write-out file if it exists */
    
    /* Cut away the old head and foot, getting the title in the process */
    PARSE VAR buffer . '<b>' title '</b>' . '<menu>' buffer '</menu>' bttm
    
    /*
     * Parse the list of URLs and reshape them.
     * Note on "DO WHILE buffer <> hrt": Initial
     * parsing leaves a hard return at the end
     * of the buffer; rather than strip it, let's
     * use it to mark the end.
     */
    i = 0 /* First, zero the counter */
    DO WHILE buffer <> hrt
        i = i + 1
        PARSE VAR buffer . '\pics\' clss '.gif">' (hrt) url '<!' . (hrt) lbl (hrt) '<br>' buffer
        IF clss = 'folder' THEN
        DO /* Change links to other local pages */
            url = Insert('./', url, Pos('"', url))
            url = Insert('l', url, LastPos('"', url)-1)
        END /* Change links to other local pages */
        ELSE
        DO
            url = AmpEsc(url)
            clss = 'url'
        END
        menu.i = '<li class="' || clss || '">' || hrt || url
        menu.i = menu.i || lbl || '</a>' || hrt || '</li>'
    END /* WHILE buffer <> hrt */
    menu.0 = i
    
    IF Pos('href', bttm) <> 0 THEN
    DO /* If there's a nav bar at the bottom */
        pgNav = '<hr />' || hrt || '<div id="bttmNav">' || hrt || '<ul class="bttmNav">'
        PARSE VAR bttm . '[' bttm ']' .
        DO WHILE bttm <> ''
            PARSE VAR bttm lnk '|' bttm
            lnk = '<li>' || Strip(lnk) || '</li>' || hrt
            lnk = Insert('./', lnk, Pos('"', lnk))
            lnk = Insert('l', lnk, LastPos('"', lnk)-1)
            pgNav = pgNav || lnk
        END /* WHILE bttm <> '' */
        pgNav = pgNav || '</ul>' || hrt || '</div>'
    END /* If there's a nav bar at the bottom */
    
    CALL GetHeadAndFoot
    
    /* Create the new file */
    /* Write the header first */
    CALL CharOut fnOut, head
    /* And now the links in the body */
    DO k = 1 TO menu.0
        CALL LineOut fnOut, menu.k
    END /*  k = 1 TO menu.0 */
    /* And now close the list and the div */
    CALL LineOut fnOut, '</ul>' || hrt || ' </div>'
/*     
 *  All but main.html have a navigation menu at the bottom.
 *  If there is one in the current page, variable 'pgNav' will
 *  contain its contents; if not, it will be the Rexx default
 */
    IF pgNav <> 'PGNAV' THEN
    DO
        CALL CharOut fnOut, pgNav
        CALL LineOut fnOut, hrt || hrt || '</body>' || hrt || hrt || '</html>'
    END
    ELSE
    DO 
        CALL CharOut fnOut, foot
    END
    
    rc = STREAM(fnOut,'c','close')
    SAY 'Writing of' fnOut || ', "' || title || '", complete.'
END

EXIT

/* Thanks to Brian Inglis for this procedure */
AmpEsc:
    PARSE ARG url
    ampPos = Pos('&', url, 1)
    
    DO WHILE ampPos > 0
        IF Translate(SubStr(url, ampPos, 5)) \= '&AMP;'
        THEN url = Insert('amp;', url, ampPos)
        
        ampPos = Pos('&', url, ampPos + 5)
    END
    
RETURN url
    
GetHeadAndFoot:
/* The new, good first part */
    head = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"' || hrt
    head = head || ' "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">' || hrt
    head = head || '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">' || hrt
    head = head || hrt
    head = head || '<head>' || hrt
    head = head || '<meta http-equiv="content-type" content="text/html; charset=ISO-8859-1" />' || hrt
    head = head || '<link href="weborg.css" rel="stylesheet" type="text/css" />' || hrt
    head = head || '<title>' || title || '</title>' || hrt
    head = head || '</head>' || hrt
    head = head || hrt
    head = head || '<body>' || hrt
    head = head || '<div id="header">' || hrt
    head = head || '<h1>' || title || '</h1>' || hrt
    head = head || '<hr />' || hrt
    head = head || '</div>' || hrt
    head = head || hrt
    head = head || '<div id="content">' || hrt || '<ul>'|| hrt

    
    /* The new, good last part */
    foot = hrt
    foot = foot || '<div id="footer">' || hrt
    foot = foot || '<address>' || hrt
    foot = foot || '<hr />' || hrt
    foot = foot || 'To contact the author E-Mail at: <a href="mailto:info@ongsw.com">info@ongsw.com</a><br />' || hrt
    foot = foot || 'To visit our HomePage: <a href="http://www.ongsw.com">http://www.ongsw.com</a><br />' || hrt
    foot = foot || 'Please come and visit our OS/2 Links page at: <a href="http://www.ongsw.com/links/links.html">http://www.ongsw.com/links/links.html</a><br />' || hrt
    foot = foot || '<br />' || hrt
    foot = foot || "Created by ONG SoftWare's Web Organizer V.02.00.01 GA<br />" || hrt
    foot = foot || '<em><small>Copyright (c) ONG SoftWare 1996, 1997. All rights reserved.</small></em>' || hrt
    foot = foot || '</address>' || hrt
    foot = foot || '</div>' || hrt
    foot = foot || hrt
    foot = foot || '</body>' || hrt
    foot = foot || hrt
    foot = foot || '</html>' || hrt
RETURN