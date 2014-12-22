/**/
 PARSE SOURCE . . CallName;
 SlashPos = LASTPOS( '\', CallName);
 InfName = LEFT( CallName, SlashPos)'nosac.inf';

 PARSE ARG Section;
 IF (STRIP(Section) = '') THEN
    Section = 'OS/2 Netlabs Open Source'

 '@START VIEW' InfName '"'Section'"';
