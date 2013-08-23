/* Zaˆo¾enie cienia obiektu podanego jako parametr w katalogu podanym jako drugi parametr */

call RxFuncAdd "SysLoadFuncs", "RexxUtil", "SysLoadFuncs"
call SysLoadFuncs

/*

	Wywoˆanie:

        MakeShadow file shadowdir [shadowid]

        Gdzie:

                file            - nazwa obiektu kt¢rego cieä b©dzie zakˆadany
                           = /B - Batch mode; nazwy plik¢w pobierane ze stdin
                           = /S - script mode; wszystkie informacje pobierane z pliku
                shadowdir       - nazwa katalogu, w kt¢rym zostan¥ zaˆo¾one
                                        cienie
                shadowid        - nazwa cienia (w przypadku wczytywania
                                        stdin b©dzie uzupeˆniona o numer
                                        kolejny obiektu)

*/

version = "0.1"

say "Make Shadow Object v. "||version||" by Jan Stozek"
say

parse ARG filename shadowdir _shadowid .

select
  when filename = "" then do
    say "Bˆ©dne parametry! - brak nazwy pliku"
    exit
  end /* when */

  when translate(filename) = "/S" then
    runmode = "S" /* Script */

  when translate(filename) = "/B" then
    runmode = "B" /* Batch */

  otherwise
    runmode = "N" /* Normal */
end /* select */

do until filename <> '.' | runmode <> "S" 

  if runmode = "S" then do
    filename = ""; _shadowid=""
    do while lines()
      parse linein command param subparam .
      select
        when command = "" then
          nop

        when left(command,1) = "#" then
          nop

        when translate(command) = "CD" then do
          shadowdir = param
        end

        when translate(command) = "ROOTNAME" then
          _shadowid = param

        when translate(command) = "DEL" then
          if shadowid() <> "" then
            call deleteobjects param subparam

        when translate(command) = "QUIT" then
          exit

        when translate(command) = "DATA" then
          leave

        otherwise
          say "Script error!!! Exiting"
          say "Command:    "||command
          say "Parametres: "||param||", "||subparam
          exit
      end /* Select */
    end /* do */
  end /* if */ ; else do
    if runmode = "B" then
      filename = ""
    if shadowdir = "" then do
      say "Bˆ©dne parametry! - brak nazwy katalogu na cieä"
      exit
    end /* if */
  end /* else */

  if pos('.',shadowdir) = 1 then
    shadowdir = directory()||delstr(shadowdir,1,1)

  if pos('\', filename) = 0 then
    if left(filename, 1) <> '<' then
      filename = directory()||'\'||filename

  if runmode = "N" then do
    count = createshadow(filename, shadowdir, shadowid())
  end /* if */ ; else do
    count = 1;
    do while lines()
      filename=linein()
      if filename = '.' then 
        leave
      else 
        if filename <> '' then
          count=count+createshadow(filename, shadowdir, shadowid()||count)
    end /* do */
    count = count - 1
  end /* else */
  say "Total of "||count||" object created"

end /* do */

exit count /* Exit code represents the number of created objects */



/* -------------------------------------------------------------------- */
/*                               Subroutines                            */
/* -------------------------------------------------------------------- */


/* Create shadow objects */

createshadow: /* Create shadow object */
  say "Creating shadow "||ARG(1)||" in "||ARG(2)||" with ID="||ARG(3)
  result= SysCreateObject("WPShadow", "Shadow of "||ARG(1)||" object", ARG(2), "SHADOWID="||ARG(1)||";OBJECTID=<"||ARG(3)||">", 'Replace')
return result /* 1 if success, 0 if failure */


/* Delete shadow objects */

deleteobjects: /* Delete shadows by name */
  parse ARG deleteme limit .
  select
    when left(deleteme,1) = "<" then
      result = SysDestroyObject(deleteme)

/* Delete object with the name given and objects with # 1 or more */
    when translate(deleteme) = "ALL" then do
      call deleteobjects "<"||shadowid()||">"
      call deleteobjects "1+"
    end /* when */

/* If object number is followed by "+" then delete it and successors */
    when right(deleteme,1) = "+" then
      call deleteobjects strip(deleteme,trailing,"+") "+"

/* If object number is given, then concat it to the rootname and delete */
/* If the second number is given, delete all objects with #s in between */
/* If any other second param is given (like "+") then delete all successing objects */

    when datatype(deleteme, whole number) then do
      countdeleted = 0
      if datatype(limit, whole number) then
        do counter = deleteme to limit
          countdeleted = countdeleted + deleteobjects("<"||shadowid()||counter||">")
        end /* do */
      else do
        counter = deleteme; next = limit
        do while deleteobjects("<"||shadowid()||counter||">") = 1
          if next <> "" then do
            counter = counter + 1
            countdeleted = countdeleted + 1
          end /* if */
        end /* do */
      end /* else */
      say "Total of "||countdeleted||" objects deleted!"
    end /* when */

    otherwise
      say "Script error on delete:"
      say "Called with parametres: "||deleteme
  end /* select */
return result

/* Shadow object ID */

shadowid:
  if _shadowid = "" then
    if runmode = "N" then
      _shadowid = filename
    else 
      if _shadowid = "" & shadowdir <> "" then
        _shadowid = substr(shadowdir,lastpos('\',shadowdir)+1)
return _shadowid
