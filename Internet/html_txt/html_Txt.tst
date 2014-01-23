                            *** HTML_TXT manual ***                             
 
®[1]Intro¯ || ®[2]Install&Run¯|| ®[3]Features¯|| ®[4]Parameters¯ || 
®[5]Troubleshooting¯|| ®[6]Disclaimer and Contact¯ 
 
                      HTML_TXT: An HTML to Text Converter                       
 
 I) Introduction  
 
HTML_TXT, version 1.09, is used to convert an ôHTMLõ file to a TEXT file. HTML_
TXT is written in REXX and is meant to be run under OS/2. However, it also runs 
under other REXX interpreters, such as Regina REXX for DOS. 
 
HTML_TXT will attempt to maintain the format of the ôHTMLõ document by using 
appropriate spacing and ASCII characters. HTML_TXT can use ASCII art ô(lines and 
boxes)õ, as well as other high-ascii characters, to improve the appearance of 
the output (text) file. 
 
HTML_TXT can be customized in a number of ways. For example, you can:

   @ suppress the use of line art and other high ASCII characters (your output 
     will be rougher, but will suffer from fewer compatability problems). 
 
   @ display tables (including nested tables) in a tabular format with 
     auto-sized columns 
 
   @ change the bullet characters used in ordered lists
 
   @ display <HN> ôheadingsõ as an hierarchical outline
 
   @ change characters used to signify logical elements (emphasis, anchors, list 
     bullets, etc.) 
 
                     ______________________________________                     
 
 II) Installling and Executing HTML_TXT 
 
HTML_TXT is easy to install and run:

  1. Copy HTML_TXT.CMD to a directory.
 
  2. Open up an OS/2 prompt, change to the directory containing HTML_TXT.CMD, 
     and type HTML_TXT at the command prompt. 
 
  3. Follow the instructions.
 
ôNo other libraries or support files are needed.õ
 
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
 
                                                                                 
ôExample:     D:\HTMLTXT>HTML_TXT FOO.HTM FOO.TXT /VAR LINEART=0 ; LAGUL=* $     
                                                                                 
ALTERNATIVELY, you can run HTML_TXT from an (OS/2) prompt without any arguments; 
you will then be asked for an input and output file, and will be permitted to 
change the values of several of the more important parameters. 
 
                     ______________________________________                     
 
 III) Features  
 
HTML_TXT attempts to support many HTML options; including nested tables, nested 
lists, centering, and recognition of FORM elements. 
 
The following summarizes HTML_TXT's capabilities.
 
       ôThis table assumes that you have a basic familiarity with HTML.õ        

                                                                                
TYPE OF    DISCUSSION                                      ®[7]CUSTOMIZATION¯   
FEATURE                                                                         
                                                                                
                                                                                
  ___________________________________________________________________________   
                                                                                
                                                                                
CHARACTER  HTML_TXT uses a few tricks to identify where     ôDOCAPSõ specifies  
DISPLAY    emphasis (italics, bold, etc.) are used in an    when to use         
           HTML document. These include:                    CAPITALIZATION as   
                                                            an emphasis         
              @ Capitalization of BOLD emphasis                                 
                                                            ôDOULINEõ specifies 
              @ Underlining of underlined emphasis          when to use under_  
                                                            linining as an      
              @ "quoting" of ôitalicõ and ®[8]<A>nchor¯     emphasis.           
                emphasis                                                        
                                                            ôDOQUOTEõ specifies 
              @ "quoting" of the labels used to identify    when to use         
                image elements. Image elements consist of   "quotes" as an      
                <IMG>s and <AREA>s ô(the ALT attribute, or  emphasis            
                the source image filename, is used as the   ô(suggestion: you   
                label)õ.                                    might want to add   
                                                            FONT to DOQUOTE)õ   
                                                            ôQUOTESTRING1 and   
                                                            QUOTESTRING2õ       
                                                            specify the         
                                                            characters to use   
                                                            "as quotes"         
                                                                                
                                                            ôPREA and POSTAõ    
                                                            specify the         
                                                            characters used to  
                                                            identify <A>nchors. 
                                                                                
                                                            ôPREIMG and         
                                                            POSTIMGõ specify    
                                                            the characters to   
                                                            use as "quotes"     
                                                            around image        
                                                            labels.             
                                                            ôIMGSTRING_MAXõ is  
                                                            used to control how 
                                                            to display an image 
                                                            label.              
                                                                                
                                                                                
  ___________________________________________________________________________   
                                                                                
                                                                                
LISTS      HTML_TXT supports nested lists -- with                               
           successively deeper indentations used to                             
           display nested lists. Supported lists include    ôFLAGULõ and        
           <UL> and <MENU> unordered lists, <OL> ordered    ôFLAGMENUõ          
           lists, <DL> definition lists, and                specifies the       
           <BLOCKQUOTE>ôboth-side indentedõ blocks. You     bullets to use in   
           can:                                             <UL> and <MENU>     
                                                            (unordered) lists   
              @ Change the bullet styles used in <UL> and                       
                <MENU> lists -- with different bullets      ôOL_NUMBERSõ        
                used at different nesting levels.           specifies the       
                                                            "numbers" to use in 
              @ Change the numbering style used (by         an <OL> (ordered)   
                default) for <OL> lists. Note that HTML_    list.               
                TXT will use TYPE and START attributes of                       
                <OL> lists, and will use the VALUE                              
                attribute (if specified) of a <LI>.                             
                                                                                
  ___________________________________________________________________________   
                                                                                
                                                                                
HEADINGS   HTML_TXT supports two methods of displaying                          
           <Hn> headings (where n=1,2,..,7).                ôPREH1 and POSTH1õ  
                                                            specify the "quote" 
             1. Headings can be "quoted"                    character to use    
                                                            for <H1> headings,  
             2. Headings can be used to create a            ôPREHN and POSTHNõ  
                hierarchical outline.                       specify the "quote" 
                                                            character to use    
           A hierarchical outline refers to headers that    for other <Hn>      
           identify a section. For example:                 headings            
                                                            (n=2,..,7).         
            I)Main section                                                      
                 I.a)Subsection                             ôHN_OUTLINEõ        
                 I.a.1) Sub subsection                      specifies at what   
                 I.b)Sub section 2                          heading level to    
                                                            start the           
           In the above example: the I) and I.A) could be   hierarchical index  
           used by HTML_TXT to display an <H2> and an <H3>  at ô(i.e.; you      
           heading (respectively)                           probably do not     
                                                            want <H1> headings  
                                                            to be the "top      
                                                            level numbers" of   
                                                            an index)õ          
                                                                                
                                                            HN_NUMBERS.n        
                                                            (n=1,2,.,7)         
                                                            specifies numbering 
                                                            styles to use       
                                                                                
                                                                                
  ___________________________________________________________________________   
                                                                                
                                                                                
TABLES     HTML_TXT supports tabluar display of nested                          
           tables. Many (but not all) <TABLE> attributes    ôIGNORE_WIDTHõ can  
           are supported, including:                        be used to suppress 
                                                            use of WIDTH        
              ~ Display of CAPTION, either at the top or    attributes, and to  
                bottom of the table (depending on the       suppress            
                value of the CAPTION ALIGN attribute).      auto-sizing of      
                                                            columns.            
              ~ WIDTH attributes of <TABLE> and <TD>. If                        
                WIDTH is not specified, HTML_TXT will       ôTABLE_BORDERõ can  
                "auto-size" columns, assigning more width   be used to write a  
                to columns with wider content (that is,     table border by     
                that would have longer lines of text if     default; it can     
                horizontal space was not limited).          also be used to     
                                                            override a ôno      
              ~ COLSPAN and ROWSPAN attributes are          borderõ (a          
                recognized. ROWSPAN is only partially       BORDER=0) attribute 
                supported, and may not work properly in                         
                complicated tables (tables with lots of     ôNOSPANõ can be     
                ROWSPANs and COLSPANs).                     used to suppress    
                                                            COLSPAN and ROWSPAN 
              ~ ALIGN and VALIGN attributes of <TR> and     options.            
                <TD>                                                            
                                                            ôSUPPRESS_EMPTY_    
              ~ BORDER attribute of <TABLE> (either a       TABLEõ can be used  
                single or double line is drawn, depending   to enable, or       
                on the value of the BORDER= attribute).     suppress, the       
                                                            display of tables   
              ~ FRAME="VOID" and RULES="NONE" attributes    rows.               
                of <TABLE>(suppress outer and inner                             
                border, respectively)                       ôTABLEMODE,         
                                                            TABLEMODE2, and     
              ~ the ALIGN attribute of <TABLE> is           TABLEMAXNESTõ can   
                partially supported:                        be used to control  
                                                            when (if ever) to   
                 1. ALIGN=LEFT in a top level table (that   convert tables to   
                    is not nested in another table)         lists.              
                    enablers other text (and other tables)                      
                    to flow around this table. Note that a  ôTABLEFILLERõ can   
                    <BR CLEAR=LEFT > will break in this     be used to fill     
                    flow (subsequent text is displayed      blank spaces in a   
                    below the table)                        table with          
                                                            something other     
                 2. ALIGN=LEFT, RIGHT, or CENTER in a       then a space (say,  
                    nested table will align the table       with a white box).  
                    (relative to the table cell it is                           
                    nested within). However, text flow      ôTD_ADDõ can be     
                    will not be attempted -- when nested    used to adjust      
                    tables are encountered, a paragraph     minimum cell widths 
                    break (a new line) is always added.                         
                                                            ôTABLEVERT and      
              ~ Empty tables, and empty rows, can be        TABLEHORIZõ can be  
                suppressed.                                 used to specify     
                                                            characters to use   
           Alternatively, HTML_TXT can display tables (or   when drawing        
           highly nested tables) as nested lists.           horizontal and      
                                                            vertical borders.   
                                                            These are only used 
                                                            if high ascii       
                                                            characters are      
                                                            suppressed (using   
                                                            ôLINEARTõ);         
                                                            otherwise, ascii    
                                                            line-art characters 
                                                            are used to draw    
                                                            table borders.      
                                                                                
                                                                                
  ___________________________________________________________________________   
                                                                                
                                                                                
FORMS      HTML_TXT displays FORM elements using several                        
           tricks, including:                              @ ôRADIOBOX and      
                                                             RADIOBOXCHECKõ can 
              $ FILE and TEXT boxes are displayed as a       be used to specify 
                ôbracketed dottedõ line.                     which characters   
                                                             to use as ôradio   
              $ TEXTAREA boxes are displayed as a box        buttonsõ           
                surrounding default text.                                       
                                                           @ ôCHECKBOX and      
              $ RADIO and CHECKBOX boxes are displayed       CHECKBOXCHECKõ can 
                using special characters (by default,        be used to specify 
                high-ascii boxes are used)                   which characters   
                                                             to use as          
              $ SELECT (and it's OPTIONS) are displayed as   ôcheckbox boxesõ   
                a bulleted list (with length controlled by                      
                the SIZE option of SELECT) -- with special @ ôSUBMITMARK1 and   
                lines bracketing the top and bottom of the   SUBMITMARK2õ can   
                list.                                        be used to specify 
                                                             "quote" characters 
              $ SUBMIT and RESET are displayed as "quoted"   for SUBMIT and     
                strings.                                     RESET              
                                                                                
                                                           @ ôTEXTMARK1,        
                                                             TEXTMARK2, and     
                                                             TEXTMARKõ can be   
                                                             used to specify    
                                                             characters used to 
                                                             construct          
                                                             ôbracketed dottedõ 
                                                             lines.             
                                                                                
                                                           @ ôSHOWALLOPTSõ can  
                                                             be used to         
                                                             suppress the SIZE  
                                                             attribute of       
                                                             SELECT lists (so   
                                                             as to force        
                                                             display of all     
                                                             OPTIONs).          
                                                                                
                                                           @ ôFORM_BRõ is used  
                                                             to force a new     
                                                             line (a BR) after  
                                                             the end of a FORM  
                                                                                
                                                                                
  ___________________________________________________________________________   
                                                                                
                                                                                
MISCELLANE                                                                      
              @ <CENTER>, <DIV>, and <P ALIGN=LEFT, CENTER, or RIGHT> alignment 
                instructions are recognized                                     
                                                                                
              @ ôLINELENõ can be used to specify the width of the text file (in 
                characters). ôCHARWIDTHõ is used to map "pixels to character    
                size" -- it is used when interpreting WIDTH attributes.         
                                                                                
              @ ôNO_WORDWRAPõ is used to suppress word wrapping in a paragraph. 
                This yields an ôinfinitely longõ line, which is suitable for    
                reading by a word processor. NO_WORDWRAP is ONLY applied to     
                NON-TABLE lines, and to lines that are NOT CENTERed or RIGHT    
                justified. In addition, indentations (at the beginning of these 
                ôinfinitely longõ lines) will be replaced with tabs (which can  
                be converted to INDENT characters by your word processor).      
                                                                                
              @ ôTOOLONGWORDõ controls whether to trim, or wrap, words that     
                won't fit into a line (or into a cell of a table).              
                                                                                
              @ ôLINEARTõ controls whether to use high ascii characters to draw 
                table borders, list bullets, and "quote characters". ôLINK_     
                DISPLAYõ controls whether to create a "reference list" of URLs  
                                                                                
              @ ôSUPPRESS_BLANKLINESõ suppresses output of sequential blank     
                lines.                                                          
                                                                                
              @ ôDISPLAY_ERRORSõ controls the amount of error reporting (of     
                HTML syntax)                                                    
                                                                                
              @ HTML_TXT ignores embedded <SCRIPT>s and <APPLET>s               
                                                                                
                                                                                

                     ______________________________________                     
 
 IV)  Changing Parameters  
 
As noted in the customization column of the above table, HTML_TXT contains a 
number of user configurable parameters. 
 
Although the default values of these parameters work well in most cases, you can 
change them by editing HTML_TXT.CMD with your favorite text editor ô(look for 
the "user configurable parameters" section)õ 
 
Alternatively, you can temporarily changes values using the /VAR command line 
option. In fact, by specifying a PLIST=file.ext (in the /VAR section), you can 
create custom instructions for sets of HTML documents. 
 
The following lists the more important parameters. ôOf particular interest are 
the NOANSI, LINEART, TABLEMAXNEST, TABLEMODE2 and TOOLONGWORD parameters.õ 
 
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³                              General Controls                              ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                                                                            ³
³                                                                            ³
³DOCAPS             Captialization is used to indicate these "logical and    ³
³                   physical" elements                                       ³
³                                                                            ³
³DOULINE            Spaces are replaced with underscores to indicate these   ³
³                   elements                                                 ³
³                                                                            ³
³DOQUOTE            "quotes" are used to indidate these elements.            ³
³                                                                            ³
³DISPLAY_ERRORS     Set level of error reporting (of html coding errors      ³
³                   encountered)                                             ³
³                                                                            ³
³FORM_BR            If enabled a line BReak is added after the end of every  ³
³                   FORM                                                     ³
³                                                                            ³
³HN_OUTLINE         Create a hierarchical outline from <HN> elements         ³
³                                                                            ³
³                   Controls how <IMG> labels are displayed. For example, you³
³                   can display the ALT attribute, a [], a reference to a    ³
³IMGSTRING_MAX      list (at the bottom of the document), or you can display ³
³                   nothing (so that the text document ignores all IMG       ³
³                   elements)                                                ³
³                                                                            ³
³IGNORE_WIDTH       Ignore WIDTH option in <TD> elements (and/or suppress    ³
³                   auto-sizing)                                             ³
³                                                                            ³
³LINEART            Suppress use of high ascii (non keyboard) characters.    ³
³                                                                            ³
³                   controls whether or not URL information should be        ³
³                   displayed (when displaying links). You can suppress      ³
³LINK_DISPLAY       display of URL info, display a number into a reference   ³
³                   list (that will be written to the end of the text output ³
³                   file), or include the URL in the body of the text.       ³
³                                                                            ³
³NOANSI             Suppress use of ANSI screen controls.                    ³
³                                                                            ³
³SHOWALLOPTS        display all OPTIONS in a SELECT list.                    ³
³                                                                            ³
³SUPPRESS_          Suppress display of consecutive blank lines              ³
³BLANKLINES                                                                  ³
³                                                                            ³
³TOOLONG WORD       trim long strings.                                       ³
³                                                                            ³
³                                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³  ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ  ³
³                                                                            ³
³                               Table Controls                               ³
³                                                                            ³
³Display of tables, in a tabular format, can be tricky. In particular, nested³
³tables may tax the resources of your 80 character text display. HTML_TXT    ³
³allows you to modify table specific display options, and convert tables into³
³lists.                                                                      ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                                                                            ³
³                                                                            ³
³SUPPRESS_EMPTY_TABLE suppress display of empty rows and empty tables        ³
³                                                                            ³
³TABLEMODE            Suppress "tabular" display of tables (use lists        ³
³                     instead)                                               ³
³                                                                            ³
³TABLEMODE2           Suppress tabular display of ônestedõ tables            ³
³                                                                            ³
³TD_ADD               Used to increase minimum cell widths (useful if narrow ³
³                     cells are clipping short words)                        ³
³                                                                            ³
³TABLEBORDER          type of default table borders                          ³
³                                                                            ³
³                                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³  ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ  ³
³                                                                            ³
³                              Display Controls                              ³
³                                                                            ³
³Since it's NOT possible to use ôitalicsõ, BOLD, font styles, and other such ³
³visual aids in a text file, HTML_TXT uses a few tricks instead.             ³
³                                                                            ³
³   @ Capitalization can be used -- by default, BOLD, STRONG and TYPEWRITER  ³
³     emphasis is indicated with capitalization.                             ³
³                                                                            ³
³   @ Spaces can be replaced with underscores -- this is used to indicate    ³
³     Underline_emphasis                                                     ³
³                                                                            ³
³   @ "quote strings" can be placed around emphasised strings.               ³
³                                                                            ³
³The last trick, the use of "quote strings", is frequently used by HTML_TXT; ³
³with different sets of quote strings used for different emphasis. For       ³
³example,                                                                    ³
³                                                                            ³
³  #  ôEM and I emphasisõ,                                                   ³
³                                                                            ³
³  #  ®[9]anchors¯,                                                          ³
³                                                                            ³
³  #  submit ÌSUBMIT¹ fields,                                                ³
³                                                                            ³
³  #  and < src="xxx" alt="in-line images"> in-line images                   ³
³                                                                            ³
³are indicated with unique sets of "quote strings".                          ³
³                                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                                                                            ³
³CHECKBOX and         Character used as a CHECKBOX button, and a ôselectedõ  ³
³CHECKBOXCHECK        CHECKBOX button                                        ³
³                                                                            ³
³FLAGMENU             bullets used in <MENU> lists.                          ³
³                                                                            ³
³FLAGUL               bullets used in <UL> lists.                            ³
³                                                                            ³
³FLAGSELECT and       character used to signify OPTION and a ôselectedõ      ³
³FLAGSELECT2          OPITON (in a SELECT list), respectively                ³
³                                                                            ³
³HN_NUMBERS.n         characters to use when outlining <HN> headings         ³
³ô(n=1,2,..,7)õ                                                              ³
³                                                                            ³
³HRBIG                character used to make large <HR> bars.                ³
³                                                                            ³
³OL_NUMBERS           Characters (i.e.; roman numerals, numbers, or letters) ³
³                     as bullets in <OL> (ordered lists)                     ³
³                                                                            ³
³PRETITLE and         Strings used before and after the doucment TITLE       ³
³POSTTITLE                                                                   ³
³                                                                            ³
³PREA and             characters used before and after <A>ANCHORS            ³
³POSTA                                                                       ³
³                                                                            ³
³PREH1 and            characters used before and after <H1>HEADINGS          ³
³POSTH1                                                                      ³
³                                                                            ³
³PREHN and            characters used before and after <Hn1> (n>1) HEADINGS  ³
³POSTHN                                                                      ³
³                                                                            ³
³PREIMG and           characters used before and after <IMGgt; NAMES OF      ³
³POSTIMG              IN-LINE IMAGES                                         ³
³                                                                            ³
³QUOTESTRING1 and     characters used to ôquoteõ emphasize                   ³
³QUOTESTRING2                                                                ³
³                                                                            ³
³RADIOBOX and         Character used as a RADIO button, and a ôselectedõ     ³
³RADIOBOXCHECK        RADIO button                                           ³
³                                                                            ³
³SUBMITMARK1 and      characters used before and after a <SUBMIT> and <RESET>³
³SUBMITMARK2          field                                                  ³
³                                                                            ³
³TEXTMARK1,           characters to use on the left, right, and middle of a  ³
³TEXTMARK2,           FILE and TEXT field.                                   ³
³and TEXTMARK                                                                ³
³                                                                            ³
³TABLEVERT and        characters to use as vertical, and horizontal, lines in³
³TABLEHORIZ           tables (used only when lineart is suppressed)          ³
³                                                                            ³
³TABLEFILLER          character to used to fill empty spaces in tables and   ³
³                     textbox's                                              ³
³                                                                            ³
³                                                                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    ôFor detailed descriptions of these parameters, see HTML_TXT.CMD.õ
 
                     ______________________________________                     
 
 V) Troubleshooting HTML_TXT 
 
The following lists possible troubles you might have, and suggested solutions.

     É HTML_TXT display all kinds of wierd garbage (such as $ and [ characters)
 
         You don't have ANSI support installed. You should either install 
         ANSI.SYS (for example, include a DEVICE=C:\OS2\MDOS\ANSI.SYS in your 
         OS/2 CONFIG.SYS file), or set NOANSI=1 (in HTML_TXT.CMD).. 
 
     Ê Nested tables aren't displaying properly (this is especially likely to 
     happen when running under Regina REXX for DOS). 
 
         You can try using lists instead of tables -- set TABLEMAXNEST=0 (in 
         HTML_TXT.CMD). . 
 
     É Tables have unappealing characters used as vertical and horizontal lines
 
         Either your output device (say, your printer) does not support 
         high-ascii characters, or your code page is somewhat unusual. You can 
         use standard characters (- and !) for line borders by setting LINEART=0 
         (in HTML_TXT.CMD).. 
 
     Ì Unappealing characters are being used as bullets and to "quote" text 
     strings 
 
         This can also occur if your code page is somewhat unusual. You can 
         either change the various "display control parameters" (in HTML_
         TXT.CMD), or you can set LINEART=-1; in which case some default, 
         standard charactes (such as * and @ for bullets) will be used. . 
 
     Í Long words (such as URLs) are being lost.
 
         You can change the "trimming" action to "word wrap", or to "extend 
         beyond margins", by setting the TOOLONGWORD parameter. 
 
     Î The display of headings is not informative
 
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
 
Do you have the ®[10]latest version of HTML_TXT¯?
 
If you find errors in this program, would like to make suggestions, or otherwise 
wish to commment.... please contact ®[11]Daniel Hellerstein¯ 
 
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
 
