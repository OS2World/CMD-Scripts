/*
 *      README.CMD - 2HOBBES - Christian Langanke 2001-2003
 */

 PARSE SOURCE . . CallName;
 SlashPos = LASTPOS( '\', CallName);
 InfPath  = LEFT( CallName, SlashPos - 1);

 InfStem  = '2hobbes';
 DefPanel = '2hobbes';

 /* determine panel to show */
 PARSE ARG Panel;
 IF (STRIP(Panel) = '') THEN
    Panel = DefPanel;


 /* launch it */
 '@START VIEW' InfPath'\'InfStem '"'Panel'"';

 EXIT(rc);

