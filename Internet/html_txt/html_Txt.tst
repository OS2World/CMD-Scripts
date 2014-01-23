                            *** HTML_TXT manual ***                             
 
�[1]Intro� || �[2]Install&Run�|| �[3]Features�|| �[4]Parameters� || 
�[5]Troubleshooting�|| �[6]Disclaimer and Contact� 
 
                      HTML_TXT: An HTML to Text Converter                       
 
 I) Introduction  
 
HTML_TXT, version 1.09, is used to convert an �HTML� file to a TEXT file. HTML_
TXT is written in REXX and is meant to be run under OS/2. However, it also runs 
under other REXX interpreters, such as Regina REXX for DOS. 
 
HTML_TXT will attempt to maintain the format of the �HTML� document by using 
appropriate spacing and ASCII characters. HTML_TXT can use ASCII art �(lines and 
boxes)�, as well as other high-ascii characters, to improve the appearance of 
the output (text) file. 
 
HTML_TXT can be customized in a number of ways. For example, you can:

   @ suppress the use of line art and other high ASCII characters (your output 
     will be rougher, but will suffer from fewer compatability problems). 
 
   @ display tables (including nested tables) in a tabular format with 
     auto-sized columns 
 
   @ change the bullet characters used in ordered lists
 
   @ display <HN> �headings� as an hierarchical outline
 
   @ change characters used to signify logical elements (emphasis, anchors, list 
     bullets, etc.) 
 
                     ______________________________________                     
 
 II) Installling and Executing HTML_TXT 
 
HTML_TXT is easy to install and run:

  1. Copy HTML_TXT.CMD to a directory.
 
  2. Open up an OS/2 prompt, change to the directory containing HTML_TXT.CMD, 
     and type HTML_TXT at the command prompt. 
 
  3. Follow the instructions.
 
�No other libraries or support files are needed.�
 
    The READ.ME file describes how to install HTML_TXT if you are a Regina 
    REXX user. 
 
 II.a)  Running from the command line  
 
You can also run HTML_TXT from the command line. The syntax is (where x:\HTMLTXT 
is the directory containing HTML_TXT.CMD): 
    x:\HTMLTXT>HTML_TXT FILE.HTM FILE.TXT /VAR VAR1=VAL1 ; VAR2=VAL2
where :

  #  FILE.HTM is the input file (an HTML document)
 
  #  FILE.TXT is the output file (a text document)
 
  #  /VAR VAR1=VAL1 ; VAR2=VAL2 is an OPTIONAL list of parameters to modify.
 
                                                                                 
�Example:     D:\HTMLTXT>HTML_TXT FOO.HTM FOO.TXT /VAR LINEART=0 ; LAGUL=* $     
                                                                                 
ALTERNATIVELY, you can run HTML_TXT from an (OS/2) prompt without any arguments; 
you will then be asked for an input and output file, and will be permitted to 
change the values of several of the more important parameters. 
 
                     ______________________________________                     
 
 III) Features  
 
HTML_TXT attempts to support many HTML options; including nested tables, nested 
lists, centering, and recognition of FORM elements. 
 
The following summarizes HTML_TXT's capabilities.
 
       �This table assumes that you have a basic familiarity with HTML.�        

                                                                                
TYPE OF    DISCUSSION                                      �[7]CUSTOMIZATION�   
FEATURE                                                                         
                                                                                
                                                                                
  ___________________________________________________________________________   
                                                                                
                                                                                
CHARACTER  HTML_TXT uses a few tricks to identify where     �DOCAPS� specifies  
DISPLAY    emphasis (italics, bold, etc.) are used in an    when to use         
           HTML document. These include:                    CAPITALIZATION as   
                                                            an emphasis         
              @ Capitalization of BOLD emphasis                                 
                                                            �DOULINE� specifies 
              @ Underlining of underlined emphasis          when to use under_  
                                                            linining as an      
              @ "quoting" of �italic� and �[8]<A>nchor�     emphasis.           
                emphasis                                                        
                                                            �DOQUOTE� specifies 
              @ "quoting" of the labels used to identify    when to use         
                image elements. Image elements consist of   "quotes" as an      
                <IMG>s and <AREA>s �(the ALT attribute, or  emphasis            
                the source image filename, is used as the   �(suggestion: you   
                label)�.                                    might want to add   
                                                            FONT to DOQUOTE)�   
                                                            �QUOTESTRING1 and   
                                                            QUOTESTRING2�       
                                                            specify the         
                                                            characters to use   
                                                            "as quotes"         
                                                                                
                                                            �PREA and POSTA�    
                                                            specify the         
                                                            characters used to  
                                                            identify <A>nchors. 
                                                                                
                                                            �PREIMG and         
                                                            POSTIMG� specify    
                                                            the characters to   
                                                            use as "quotes"     
                                                            around image        
                                                            labels.             
                                                            �IMGSTRING_MAX� is  
                                                            used to control how 
                                                            to display an image 
                                                            label.              
                                                                                
                                                                                
  ___________________________________________________________________________   
                                                                                
                                                                                
LISTS      HTML_TXT supports nested lists -- with                               
           successively deeper indentations used to                             
           display nested lists. Supported lists include    �FLAGUL� and        
           <UL> and <MENU> unordered lists, <OL> ordered    �FLAGMENU�          
           lists, <DL> definition lists, and                specifies the       
           <BLOCKQUOTE>�both-side indented� blocks. You     bullets to use in   
           can:                                             <UL> and <MENU>     
                                                            (unordered) lists   
              @ Change the bullet styles used in <UL> and                       
                <MENU> lists -- with different bullets      �OL_NUMBERS�        
                used at different nesting levels.           specifies the       
                                                            "numbers" to use in 
              @ Change the numbering style used (by         an <OL> (ordered)   
                default) for <OL> lists. Note that HTML_    list.               
                TXT will use TYPE and START attributes of                       
                <OL> lists, and will use the VALUE                              
                attribute (if specified) of a <LI>.                             
                                                                                
  ___________________________________________________________________________   
                                                                                
                                                                                
HEADINGS   HTML_TXT supports two methods of displaying                          
           <Hn> headings (where n=1,2,..,7).                �PREH1 and POSTH1�  
                                                            specify the "quote" 
             1. Headings can be "quoted"                    character to use    
                                                            for <H1> headings,  
             2. Headings can be used to create a            �PREHN and POSTHN�  
                hierarchical outline.                       specify the "quote" 
                                                            character to use    
           A hierarchical outline refers to headers that    for other <Hn>      
           identify a section. For example:                 headings            
                                                            (n=2,..,7).         
            I)Main section                                                      
                 I.a)Subsection                             �HN_OUTLINE�        
                 I.a.1) Sub subsection                      specifies at what   
                 I.b)Sub section 2                          heading level to    
                                                            start the           
           In the above example: the I) and I.A) could be   hierarchical index  
           used by HTML_TXT to display an <H2> and an <H3>  at �(i.e.; you      
           heading (respectively)                           probably do not     
                                                            want <H1> headings  
                                                            to be the "top      
                                                            level numbers" of   
                                                            an index)�          
                                                                                
                                                            HN_NUMBERS.n        
                                                            (n=1,2,.,7)         
                                                            specifies numbering 
                                                            styles to use       
                                                                                
                                                                                
  ___________________________________________________________________________   
                                                                                
                                                                                
TABLES     HTML_TXT supports tabluar display of nested                          
           tables. Many (but not all) <TABLE> attributes    �IGNORE_WIDTH� can  
           are supported, including:                        be used to suppress 
                                                            use of WIDTH        
              ~ Display of CAPTION, either at the top or    attributes, and to  
                bottom of the table (depending on the       suppress            
                value of the CAPTION ALIGN attribute).      auto-sizing of      
                                                            columns.            
              ~ WIDTH attributes of <TABLE> and <TD>. If                        
                WIDTH is not specified, HTML_TXT will       �TABLE_BORDER� can  
                "auto-size" columns, assigning more width   be used to write a  
                to columns with wider content (that is,     table border by     
                that would have longer lines of text if     default; it can     
                horizontal space was not limited).          also be used to     
                                                            override a �no      
              ~ COLSPAN and ROWSPAN attributes are          border� (a          
                recognized. ROWSPAN is only partially       BORDER=0) attribute 
                supported, and may not work properly in                         
                complicated tables (tables with lots of     �NOSPAN� can be     
                ROWSPANs and COLSPANs).                     used to suppress    
                                                            COLSPAN and ROWSPAN 
              ~ ALIGN and VALIGN attributes of <TR> and     options.            
                <TD>                                                            
                                                            �SUPPRESS_EMPTY_    
              ~ BORDER attribute of <TABLE> (either a       TABLE� can be used  
                single or double line is drawn, depending   to enable, or       
                on the value of the BORDER= attribute).     suppress, the       
                                                            display of tables   
              ~ FRAME="VOID" and RULES="NONE" attributes    rows.               
                of <TABLE>(suppress outer and inner                             
                border, respectively)                       �TABLEMODE,         
                                                            TABLEMODE2, and     
              ~ the ALIGN attribute of <TABLE> is           TABLEMAXNEST� can   
                partially supported:                        be used to control  
                                                            when (if ever) to   
                 1. ALIGN=LEFT in a top level table (that   convert tables to   
                    is not nested in another table)         lists.              
                    enablers other text (and other tables)                      
                    to flow around this table. Note that a  �TABLEFILLER� can   
                    <BR CLEAR=LEFT > will break in this     be used to fill     
                    flow (subsequent text is displayed      blank spaces in a   
                    below the table)                        table with          
                                                            something other     
                 2. ALIGN=LEFT, RIGHT, or CENTER in a       then a space (say,  
                    nested table will align the table       with a white box).  
                    (relative to the table cell it is                           
                    nested within). However, text flow      �TD_ADD� can be     
                    will not be attempted -- when nested    used to adjust      
                    tables are encountered, a paragraph     minimum cell widths 
                    break (a new line) is always added.                         
                                                            �TABLEVERT and      
              ~ Empty tables, and empty rows, can be        TABLEHORIZ� can be  
                suppressed.                                 used to specify     
                                                            characters to use   
           Alternatively, HTML_TXT can display tables (or   when drawing        
           highly nested tables) as nested lists.           horizontal and      
                                                            vertical borders.   
                                                            These are only used 
                                                            if high ascii       
                                                            characters are      
                                                            suppressed (using   
                                                            �LINEART�);         
                                                            otherwise, ascii    
                                                            line-art characters 
                                                            are used to draw    
                                                            table borders.      
                                                                                
                                                                                
  ___________________________________________________________________________   
                                                                                
                                                                                
FORMS      HTML_TXT displays FORM elements using several                        
           tricks, including:                              @ �RADIOBOX and      
                                                             RADIOBOXCHECK� can 
              $ FILE and TEXT boxes are displayed as a       be used to specify 
                �bracketed dotted� line.                     which characters   
                                                             to use as �radio   
              $ TEXTAREA boxes are displayed as a box        buttons�           
                surrounding default text.                                       
                                                           @ �CHECKBOX and      
              $ RADIO and CHECKBOX boxes are displayed       CHECKBOXCHECK� can 
                using special characters (by default,        be used to specify 
                high-ascii boxes are used)                   which characters   
                                                             to use as          
              $ SELECT (and it's OPTIONS) are displayed as   �checkbox boxes�   
                a bulleted list (with length controlled by                      
                the SIZE option of SELECT) -- with special @ �SUBMITMARK1 and   
                lines bracketing the top and bottom of the   SUBMITMARK2� can   
                list.                                        be used to specify 
                                                             "quote" characters 
              $ SUBMIT and RESET are displayed as "quoted"   for SUBMIT and     
                strings.                                     RESET              
                                                                                
                                                           @ �TEXTMARK1,        
                                                             TEXTMARK2, and     
                                                             TEXTMARK� can be   
                                                             used to specify    
                                                             characters used to 
                                                             construct          
                                                             �bracketed dotted� 
                                                             lines.             
                                                                                
                                                           @ �SHOWALLOPTS� can  
                                                             be used to         
                                                             suppress the SIZE  
                                                             attribute of       
                                                             SELECT lists (so   
                                                             as to force        
                                                             display of all     
                                                             OPTIONs).          
                                                                                
                                                           @ �FORM_BR� is used  
                                                             to force a new     
                                                             line (a BR) after  
                                                             the end of a FORM  
                                                                                
                                                                                
  ___________________________________________________________________________   
                                                                                
                                                                                
MISCELLANE                                                                      
              @ <CENTER>, <DIV>, and <P ALIGN=LEFT, CENTER, or RIGHT> alignment 
                instructions are recognized                                     
                                                                                
              @ �LINELEN� can be used to specify the width of the text file (in 
                characters). �CHARWIDTH� is used to map "pixels to character    
                size" -- it is used when interpreting WIDTH attributes.         
                                                                                
              @ �NO_WORDWRAP� is used to suppress word wrapping in a paragraph. 
                This yields an �infinitely long� line, which is suitable for    
                reading by a word processor. NO_WORDWRAP is ONLY applied to     
                NON-TABLE lines, and to lines that are NOT CENTERed or RIGHT    
                justified. In addition, indentations (at the beginning of these 
                �infinitely long� lines) will be replaced with tabs (which can  
                be converted to INDENT characters by your word processor).      
                                                                                
              @ �TOOLONGWORD� controls whether to trim, or wrap, words that     
                won't fit into a line (or into a cell of a table).              
                                                                                
              @ �LINEART� controls whether to use high ascii characters to draw 
                table borders, list bullets, and "quote characters". �LINK_     
                DISPLAY� controls whether to create a "reference list" of URLs  
                                                                                
              @ �SUPPRESS_BLANKLINES� suppresses output of sequential blank     
                lines.                                                          
                                                                                
              @ �DISPLAY_ERRORS� controls the amount of error reporting (of     
                HTML syntax)                                                    
                                                                                
              @ HTML_TXT ignores embedded <SCRIPT>s and <APPLET>s               
                                                                                
                                                                                

                     ______________________________________                     
 
 IV)  Changing Parameters  
 
As noted in the customization column of the above table, HTML_TXT contains a 
number of user configurable parameters. 
 
Although the default values of these parameters work well in most cases, you can 
change them by editing HTML_TXT.CMD with your favorite text editor �(look for 
the "user configurable parameters" section)� 
 
Alternatively, you can temporarily changes values using the /VAR command line 
option. In fact, by specifying a PLIST=file.ext (in the /VAR section), you can 
create custom instructions for sets of HTML documents. 
 
The following lists the more important parameters. �Of particular interest are 
the NOANSI, LINEART, TABLEMAXNEST, TABLEMODE2 and TOOLONGWORD parameters.� 
 
����������������������������������������������������������������������������Ŀ
�                              General Controls                              �
����������������������������������������������������������������������������Ĵ
�                                                                            �
�                                                                            �
�DOCAPS             Captialization is used to indicate these "logical and    �
�                   physical" elements                                       �
�                                                                            �
�DOULINE            Spaces are replaced with underscores to indicate these   �
�                   elements                                                 �
�                                                                            �
�DOQUOTE            "quotes" are used to indidate these elements.            �
�                                                                            �
�DISPLAY_ERRORS     Set level of error reporting (of html coding errors      �
�                   encountered)                                             �
�                                                                            �
�FORM_BR            If enabled a line BReak is added after the end of every  �
�                   FORM                                                     �
�                                                                            �
�HN_OUTLINE         Create a hierarchical outline from <HN> elements         �
�                                                                            �
�                   Controls how <IMG> labels are displayed. For example, you�
�                   can display the ALT attribute, a [], a reference to a    �
�IMGSTRING_MAX      list (at the bottom of the document), or you can display �
�                   nothing (so that the text document ignores all IMG       �
�                   elements)                                                �
�                                                                            �
�IGNORE_WIDTH       Ignore WIDTH option in <TD> elements (and/or suppress    �
�                   auto-sizing)                                             �
�                                                                            �
�LINEART            Suppress use of high ascii (non keyboard) characters.    �
�                                                                            �
�                   controls whether or not URL information should be        �
�                   displayed (when displaying links). You can suppress      �
�LINK_DISPLAY       display of URL info, display a number into a reference   �
�                   list (that will be written to the end of the text output �
�                   file), or include the URL in the body of the text.       �
�                                                                            �
�NOANSI             Suppress use of ANSI screen controls.                    �
�                                                                            �
�SHOWALLOPTS        display all OPTIONS in a SELECT list.                    �
�                                                                            �
�SUPPRESS_          Suppress display of consecutive blank lines              �
�BLANKLINES                                                                  �
�                                                                            �
�TOOLONG WORD       trim long strings.                                       �
�                                                                            �
�                                                                            �
����������������������������������������������������������������������������Ĵ
�  ������������������������������������������������������������������������  �
�                                                                            �
�                               Table Controls                               �
�                                                                            �
�Display of tables, in a tabular format, can be tricky. In particular, nested�
�tables may tax the resources of your 80 character text display. HTML_TXT    �
�allows you to modify table specific display options, and convert tables into�
�lists.                                                                      �
����������������������������������������������������������������������������Ĵ
�                                                                            �
�                                                                            �
�SUPPRESS_EMPTY_TABLE suppress display of empty rows and empty tables        �
�                                                                            �
�TABLEMODE            Suppress "tabular" display of tables (use lists        �
�                     instead)                                               �
�                                                                            �
�TABLEMODE2           Suppress tabular display of �nested� tables            �
�                                                                            �
�TD_ADD               Used to increase minimum cell widths (useful if narrow �
�                     cells are clipping short words)                        �
�                                                                            �
�TABLEBORDER          type of default table borders                          �
�                                                                            �
�                                                                            �
����������������������������������������������������������������������������Ĵ
�  ������������������������������������������������������������������������  �
�                                                                            �
�                              Display Controls                              �
�                                                                            �
�Since it's NOT possible to use �italics�, BOLD, font styles, and other such �
�visual aids in a text file, HTML_TXT uses a few tricks instead.             �
�                                                                            �
�   @ Capitalization can be used -- by default, BOLD, STRONG and TYPEWRITER  �
�     emphasis is indicated with capitalization.                             �
�                                                                            �
�   @ Spaces can be replaced with underscores -- this is used to indicate    �
�     Underline_emphasis                                                     �
�                                                                            �
�   @ "quote strings" can be placed around emphasised strings.               �
�                                                                            �
�The last trick, the use of "quote strings", is frequently used by HTML_TXT; �
�with different sets of quote strings used for different emphasis. For       �
�example,                                                                    �
�                                                                            �
�  #  �EM and I emphasis�,                                                   �
�                                                                            �
�  #  �[9]anchors�,                                                          �
�                                                                            �
�  #  submit �SUBMIT� fields,                                                �
�                                                                            �
�  #  and < src="xxx" alt="in-line images"> in-line images                   �
�                                                                            �
�are indicated with unique sets of "quote strings".                          �
�                                                                            �
����������������������������������������������������������������������������Ĵ
�                                                                            �
�CHECKBOX and         Character used as a CHECKBOX button, and a �selected�  �
�CHECKBOXCHECK        CHECKBOX button                                        �
�                                                                            �
�FLAGMENU             bullets used in <MENU> lists.                          �
�                                                                            �
�FLAGUL               bullets used in <UL> lists.                            �
�                                                                            �
�FLAGSELECT and       character used to signify OPTION and a �selected�      �
�FLAGSELECT2          OPITON (in a SELECT list), respectively                �
�                                                                            �
�HN_NUMBERS.n         characters to use when outlining <HN> headings         �
��(n=1,2,..,7)�                                                              �
�                                                                            �
�HRBIG                character used to make large <HR> bars.                �
�                                                                            �
�OL_NUMBERS           Characters (i.e.; roman numerals, numbers, or letters) �
�                     as bullets in <OL> (ordered lists)                     �
�                                                                            �
�PRETITLE and         Strings used before and after the doucment TITLE       �
�POSTTITLE                                                                   �
�                                                                            �
�PREA and             characters used before and after <A>ANCHORS            �
�POSTA                                                                       �
�                                                                            �
�PREH1 and            characters used before and after <H1>HEADINGS          �
�POSTH1                                                                      �
�                                                                            �
�PREHN and            characters used before and after <Hn1> (n>1) HEADINGS  �
�POSTHN                                                                      �
�                                                                            �
�PREIMG and           characters used before and after <IMGgt; NAMES OF      �
�POSTIMG              IN-LINE IMAGES                                         �
�                                                                            �
�QUOTESTRING1 and     characters used to �quote� emphasize                   �
�QUOTESTRING2                                                                �
�                                                                            �
�RADIOBOX and         Character used as a RADIO button, and a �selected�     �
�RADIOBOXCHECK        RADIO button                                           �
�                                                                            �
�SUBMITMARK1 and      characters used before and after a <SUBMIT> and <RESET>�
�SUBMITMARK2          field                                                  �
�                                                                            �
�TEXTMARK1,           characters to use on the left, right, and middle of a  �
�TEXTMARK2,           FILE and TEXT field.                                   �
�and TEXTMARK                                                                �
�                                                                            �
�TABLEVERT and        characters to use as vertical, and horizontal, lines in�
�TABLEHORIZ           tables (used only when lineart is suppressed)          �
�                                                                            �
�TABLEFILLER          character to used to fill empty spaces in tables and   �
�                     textbox's                                              �
�                                                                            �
�                                                                            �
������������������������������������������������������������������������������

    �For detailed descriptions of these parameters, see HTML_TXT.CMD.�
 
                     ______________________________________                     
 
 V) Troubleshooting HTML_TXT 
 
The following lists possible troubles you might have, and suggested solutions.

     � HTML_TXT display all kinds of wierd garbage (such as $ and [ characters)
 
         You don't have ANSI support installed. You should either install 
         ANSI.SYS (for example, include a DEVICE=C:\OS2\MDOS\ANSI.SYS in your 
         OS/2 CONFIG.SYS file), or set NOANSI=1 (in HTML_TXT.CMD).. 
 
     � Nested tables aren't displaying properly (this is especially likely to 
     happen when running under Regina REXX for DOS). 
 
         You can try using lists instead of tables -- set TABLEMAXNEST=0 (in 
         HTML_TXT.CMD). . 
 
     � Tables have unappealing characters used as vertical and horizontal lines
 
         Either your output device (say, your printer) does not support 
         high-ascii characters, or your code page is somewhat unusual. You can 
         use standard characters (- and !) for line borders by setting LINEART=0 
         (in HTML_TXT.CMD).. 
 
     � Unappealing characters are being used as bullets and to "quote" text 
     strings 
 
         This can also occur if your code page is somewhat unusual. You can 
         either change the various "display control parameters" (in HTML_
         TXT.CMD), or you can set LINEART=-1; in which case some default, 
         standard charactes (such as * and @ for bullets) will be used. . 
 
     � Long words (such as URLs) are being lost.
 
         You can change the "trimming" action to "word wrap", or to "extend 
         beyond margins", by setting the TOOLONGWORD parameter. 
 
     � The display of headings is not informative
 
         You can set HN_OUTLINE=2, heading will then be displayed in an "outline 
         format". You can even change the numbering style (say, 2.a.ii versus 
         II.2.b) by changing the HN_NUMBERS.n parameters. 
 
                     ______________________________________                     
 
 VI) Disclaimer and Contact Information 
 
  

 
 VI.a) Disclaimer 
 
  
  
   This is freeware that is to be used at your own risk -- the author
   and any potentially affiliated institutions disclaim all responsibilties
   for any consequence arising from the use, misuse, or abuse of
   this software.
  
  
   You may use this, or subsets of this program, as you see fit,
   including for commercial  purposes; so long as  proper attribution
   is made, and so long as such use does not preclude others from making
   similar use of this code.
  

 
 VI.b) Contact Information 
 
Do you have the �[10]latest version of HTML_TXT�?
 
If you find errors in this program, would like to make suggestions, or otherwise 
wish to commment.... please contact �[11]Daniel Hellerstein� 
 
      =============================== 
          Reference List of URLs     
      =============================== 
 
[   1] #intro
[   2] #cmdline
[   3] #features
[   4] #parameters
[   5] #troubles
[   6] #disclaim
[   7] #parameters
[   8] #features
[   9] #display
[  10] http://www.srehttp.org/apps/html_txt/
[  11] mailto:danielh@econ.ag.gov
 
      =============================== 
          Reference List of IMGs     
      =============================== 
 
