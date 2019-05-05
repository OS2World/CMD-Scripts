/* REXX */
/* Title : Meteor                                           */
/* Desc  : A simple action game                             */
/* Author: Jeff Byrd, jeff.byrd@mcmail.vanderbilt.edu       */
/* Date  : 12/22/95                                         */
/*                                                          */
/* Notes : If you run this program from a mapped network    */
/*         drive, the high score list and demos will be     */
/*         shared among all the players.                    */
/*         Make sure to note all the hints on how to play.  */
/*         To clear the high score/demo list, delete all    */
/*         *.MSV files.                                     */

parse arg g.commLine
g.commLine = translate(g.commLine)
g.commLine = translate(g.commLine, "-", "/")

signal on halt            /* trap all Ctrl-Break, Ctrl-C */

call init                 /* initialize globals */

/* Main Loop */
do until decision = "Q"
  call doTitleSequence
  decision = getDecision()
  if decision = "P" then
    call playGame
  else if decision = "D" then
    call playDemo
end

call cleanUp

exit

init: procedure expose g.
/* This procedure loads all libraries, starts sound, draws game items */

  /* load rexxutil functions */
  call RxFuncAdd "SysLoadFuncs",  "RexxUtil", "SysLoadFuncs"
  call SysLoadFuncs

  /* select a directory for temporary files - if run from a network drive, put temp on local drive */
  currDrive = filespec("drive", directory())
  map = SysDriveMap("c:", "remote")
  if pos(currDrive, map) \= 0 then do        /* if being run from a network drive, make tmpDir on a local drive */
    g.tmpDir = value("TMP",, "OS2ENVIRONMENT")
    if g.tmpDir = "" then
      g.tmpDir = "c:\"
    else do
      if right(g.tmpDir, 1) = ";" then
        g.tmpDir = substr(g.tmpDir, 1, length(tmpDir)-1)
      if right(g.tmpDir, 1) \= "\" then
        g.tmpDir = g.tmpDir||"\"
    end
  end
  else
    g.tmpDir = ".\"

  /* start the sound if the PC is equipped */
  g.soundEnabled = 0
  if pos("-S", g.commLine) = 0 then do
    mmDir = strip(value("MMBASE",, "OS2ENVIRONMENT"))
    if right(mmDir, 1) = ";" then
      mmDir = left(mmDir, length(mmDir)-1)
    if right(mmDir, 1) \= "\" then
      mmDir = mmDir||"\"
    if mmDir \= "" & stream(mmDir"dll\mciapi.dll", "c", "query exists") \= "" then do
      /* initialize sound player */
      call RxFuncAdd "mciRxInit", "MCIAPI", "mciRxInit"
      call mciRxInit
      rc = mciRxSendString('open waveaudio wait', 'RetStr', '0', '0')
      if rc = 0 then do       /* rc = 0 means successful */
        g.soundEnabled = 1
        mmWav = mmDir"sounds\"
        g.sound.laser = mmWav"eeeooop.wav"
        g.sound.hit = mmWav"pop.wav"
        g.sound.crash = mmWav"doink.wav"
        g.sound.point = mmWav"boing.wav"
        g.sound.warp = mmWav"wooeep.wav"
        g.sound.bomb = mmWav"bwaaang.wav"
        g.sound.charge = mmWav"beeoong.wav"
        g.sound.shield = mmWav"bweeep.wav"
        g.sound.firepower = mmWav"laser.wav"
      end
      else
        call showMMPMError rc
    end
  end

  /* turn cursor off */
  call SysCurState OFF

  /* draw stuff */
  g.shipLook = '1b'x||'[36m'||d2c(223)||d2c(219)||d2c(223)||'1b'x||'[37m'
  g.shipCrash = '1b'x||'[36m'||d2c(205)||d2c(203)||d2c(205)||'1b'x||'[37m'
  g.wall = '1b'x||'[32m'||d2c(221)||'1b'x||'[37m'
  g.laser = '1b'x||'[43m'||d2c(186)||'1b'x||'[40m'
  g.laser.width = 1
  g.laser.offset = 1
  g.bigLaser = '1b'x||'[43m'||'1b'x||'[37m'||d2c(179)||d2c(179)||d2c(179)||'1b'x||'[10m'||'1b'x||'[40m'
  g.bigLaser.width = 3
  g.bigLaser.offset = 0
  g.bonus = "CWBSFP"    /* this represents the bonus objects */
  g.meteor = "+"

  return

showMMPMError: procedure
/* Show an error message from MMPM/2 */
  parse arg rc
  call mciRxGetErrorString rc, 'ErrStVar'
  call SysCls
  say "It looks like your PC has MMPM/2 installed, but the Wav player didn't"
  say "initialize.  Here's the message from MMPM. . ."
  say "Error: "rc" -  "ErrStVar
  say "Press [ENTER]"
  pull
  return

doTitleSequence: procedure expose g.
/* draw some random meteors for fun */
  call clearScreen
  do 50
    call SysCurPos RANDOM(24), RANDOM(16, 78)
    call charout, g.meteor
  end

  /* make instruction screen */
  call cleanQueue
  queue "             "||"1b"x||"[32m*** Meteor *** "||"1b"x||"[37m"
  queue "                                   "
  queue "1b"x||"[32mHow to play:"||"1b"x||"[37m"
  queue "   Move your ship ("g.shiplook") to avoid meteors ("g.meteor")."
  queue "   Shoot meteors (10 pts each) to earn points."
  queue "   The longer the laser charges, the farther it shoots."
  queue "   Don't hold down the control keys.  Just tap them."
  queue "                                      "
  queue "1b"x||"[32mControls:"||"1b"x||"[37m"
  queue "   < - move ship left       "
  queue "   > - move ship right    "
  queue "   [enter] - use a bomb (if you have one)"
  queue "   [spacebar] - fire laser"
  queue "                                  "
  queue "1b"x||"[32mBonus Objects:"||"1b"x||"[37m"
  queue "   "||"1b"x||"[41mC"||"1b"x||"[40m - Charge    fully charges laser"
  queue "   "||"1b"x||"[42mW"||"1b"x||"[40m - Warp      goes back to easier level   "
  queue "   "||"1b"x||"[43mB"||"1b"x||"[40m - Bomb      clears screen               "
  queue "   "||"1b"x||"[44mS"||"1b"x||"[40m - Shield    adds to shield power        "
  queue "   "||"1b"x||"[45mF"||"1b"x||"[40m - Firepower extra wide laser for 5 shots"
  queue "   "||"1b"x||"[46mP"||"1b"x||"[40m - Points    gives you 50 points         "
  call displayMsg 0 20 4

  call displayHighScores
  return

displayHighScores: procedure expose g.
/*  display high scores - each score is derived from a *.msv file in
    the current directory.  *.msv files contain complete games that
    are played back as demos.
*.MSV format is:
  name
  score
  random seed
  all the keystrokes for the entire game
*/

  call SysFileTree "*.msv", "file", "FO"
  if file.0 = 0 then
    return  /* no high scores */

  if file.0 > 10 then
    file.0 = 10

  queue "1b"x||"[32mTop 10 Scores"||"1b"x||"[37m"
  queue ""

  /* warning: here comes some lazy code. . . */
  scoreFile = g.tmpDir"tmpsort.in"
  sortFile = g.tmpDir"tmpsort.out"

  /* read all the names and scores out of the *.msv files */
  do i = 1 to file.0
    name = linein(file.i)
    score = linein(file.i)
    call lineout scoreFile, format(score, 6)" "name
    call stream file.i, "c", "close"
  end
  call stream scoreFile, "c", "close"

  /* use the sort OS/2 command to do my sort (I really hate sorting) */
  "@sort /R <"scoreFile" >"sortFile
  do while lines(sortFile) > 0
    rec = linein(sortFile)
    parse var rec score name
    queue name
    queue format(score, 15)
  end
  call stream sortFile, "c", "close"

  call displayMsg 0 0 0

  /* clean up */
  call SysFileDelete scoreFile
  call SysFileDelete sortFile

  return

getDecision: procedure
/* return a character where "P" = play, "D" = show demo, "Q" = Quit */
  msg = "(P)lay, (D)emo, (Q)uit, (P)lay, (D)emo, (Q)uit"
  queue "     "||"1b"x||"[41mPress a key:"||"1b"x||"[40m"
  call displayMsg 22 32 4
  key = ""
  call time "R"
  rot = 1
  call charout , "1b"x||"[41m"
  do while key \= "P" & key \= "D" & key \= "Q" & time("E") < 30
    call SysCurPos 23, 36
    call charout , substr(msg, rot, length(msg)/2)
    rot = rot + 1
    if rot > length(msg)/2 + 1 then
      rot = 1
    call SysSleep 1
    if chars() > 0 then
      key = translate(SysGetKey("NOECHO"))
  end
  if key = "" then
    key = "D"
  call charout , "1b"x||"[40m"
  return key

playDemo: procedure expose g.
/* read a .msv file and replay the game the file represents */
  call initDemoGame

  if s.demoFile = "" then   /* verify there is at least one demo available */
    return

  do while s.shield >= 0 & chars() = 0  /* end when ship is destroyed, or a key is pressed */

    call pauseIt

    key = charin(s.demoFile, , 1)       /* a '-' means no key pressed */
    if key \= "-" then
      call processInput key

    call drawItems

    call testShipHit

    call drawShip

    if queued() > 0 then
      call displayGameMessages

    s.level = s.level + 1

    /* let the user know to press a key to stop the demo */
    if s.level/20 = trunc(s.level/20) then
      queue "1b"x||"[41mPress any key"||"1b"x||"[40m"

    s.charge = s.charge + 1

  end

  call stream s.demoFile, "c", "close"

  return

initDemoGame: procedure expose g. s.
/* setup to play a demo game */
  call initGame

  call cleanQueue

  /* select a demo to play at random */
  s.demoFile = ""
  call SysFileTree "*.msv", "file", "FO"
  if file.0 = 0 then
    return
  if file.0 > 10 then
    file.0 = 10
  demoNum = random(1, file.0)
  s.demoFile = g.tmpDir"thisgame.dat"
  "@copy "file.demoNum" "g.tmpDir"thisgame.dat >nul"
  name = linein(s.demoFile)
  score = linein(s.demoFile)
  seed = linein(s.demoFile)
  dateTime = stream(s.demoFile, "c", "query datetime")
  theDate = word(dateTime, 1)
  theTime = word(dateTime, 2)

  /*  It's important to seed the random generator with the same value as when
      this game was played the first time */
  seedIt = random(1, 1, seed)

  queue "Pilot:"
  queue name
  queue ""
  queue "Score:"score
  queue ""
  queue "Played on:"
  queue theDate
  queue theTime
  queue ""
  return

playGame: procedure expose g.
/* play a game of meteor */
  call initGame

  do while s.shield >= 0   /* game is over when ship is hit with 0 shields */

    call pauseIt

    if chars() > 0 then do
      key = SysGetKey("NOECHO")
      call processInput key
      s.keystrokes = s.keystrokes||key    /* save keystrokes for demo */
    end
    else
      s.keystrokes = s.keystrokes||"-"

    call drawItems

    call testShipHit

    call drawShip

    if queued() > 0 then
      call displayGameMessages

    call incrementTurnData

  end

  /* close demo file */
  call charout s.demoFile, s.keystrokes
  call stream s.demoFile, "c", "close"

  call gameOver

  return

initGame: procedure expose g. s.
/* setup to start a game */

  /* s. is stem for ship variables */
  s.col = 46              /* the ship's current display column */
  s.level = 0             /* the incremental difficulty level */
  s.hits = 0              /* number of meteors hit */
  s.points = 0            /* number of 'P' bonuses collected */
  s.charge = 0            /* charge value of ship's laser */
  s.shield = 3            /* ship's shield level */
  s.firepower = 0         /* ship's firepower level (wide laser) */
  s.bomb = 0              /* ship's number of bombs collected */
  s.warp = 0              /* number of warps collected, used for score tabulation */
  s.onceALevel = 0        /* a counter for things that happen once a level */
  s.keystrokes = ""       /* a buffer variable to store keystrokes to use as demo */
  s.demoFile = g.tmpDir"thisgame.dat"
  call SysFileDelete s.demoFile

  /* seed random number generator */
  s.seed = random(1, 10000)       /* keep the seed to save with demo file */
  seedIt = random(1, 1, s.seed)

  /* queue up starting messages */
  queue "Hints:          "
  queue "Tap the keys."
  queue ""
  queue "Give the laser"
  queue "time to charge."
  queue ""
  queue "Don't run into"
  queue "meteors."
  queue ""
  queue "Collect bonus"
  queue "objects."
  queue ""
  queue "Look ahead for"
  queue "openings."
  queue ""
  queue "Good Luck!"
  queue ""
  queue "Level:1"
  queue "Score:0"
  queue "Firepower:0"
  queue "Shield:"||s.shield
  queue "                "

  call clearScreen

  /* flush keystrokes */
  do while chars() > 0
    key = SysGetKey("NOECHO")
  end

  /* seed elapsed time so the main loop pauses correctly */
  call time "R"

  return

clearScreen: procedure expose g.
/* clear the screen and draw the wall */
  call SysCls
  do i = 0 to 24
      call SysCurPos i, 15
      call charout, g.wall
  end
  return

processInput: procedure expose g. s.
/* do appropriate action based on input */
  parse arg key
  if key = "," & s.col > 16 then
    s.col = s.col - 1
  else if key = "." & s.col < 77 then
    s.col = s.col + 1
  else if key = " " then
    call doLaser
  else if key = d2c(13) then
    call doBomb

  return

checkScore: procedure expose g. s.
/* see if this score is in the top 10 */
  thisScore = trunc(s.hits*10+s.points*50+(s.level+s.warp*50)/10)
  call SysFileTree "*.msv", "file", "FO"
  num = 0

  /* if there are less than 10, and you did better than 0, you made it! */
  if file.0 < 10 then do
     if thisScore > 0 then do
       num = file.0 + 1
       do while stream("demo"num".msv", "c", "query exists") \= ""
         num = num + 1
       end
       call saveScore "demo"num".msv" thisScore
       return
     end
    call pressAnyKey
    return
  end

  /* get the current minimum score in the top 10 */
  minScore = 10000
  do i = 1 to file.0
    name = linein(file.i)
    score = linein(file.i)
    call stream file.i, "c", "close"
    if score < minScore then do
      minScore = score
      demoFileName = file.i
    end
  end

  /* if the minimum is lower than this, this replaces the old minimum */
  if thisScore > minScore then do
    call saveScore demoFileName thisScore
    return
  end

  call pressAnyKey

  return

pressAnyKey: procedure
  do while chars() > 0
    key = SysGetKey("NOECHO")
  end
  queue "1b"x||"[41m  Press any key  "||"1b"x||"[40m"
  call displayMsg 22 37

  key = SysGetKey("NOECHO")

  return

saveScore: procedure expose g. s.
/* get info and create a .msv file for this game */
/* num = the 'slot' to put the game, score = the score of the game */
  parse arg fileName score
  name = getName()
  if name = "" then   /* maybe they don't want to claim it */
    return
  if length(name) > 15 then
    name = left(name, 15)
  call SysFileDelete fileName
  call lineout fileName, name
  call lineout fileName, score
  call lineout fileName, s.seed
  call stream fileName, "c", "close"
  "@copy "fileName" + "s.demoFile" >NUL"    /* merge the header with the keystrokes */

  return

getName: procedure expose g. s.
/* query user for his/her name */
  do while chars() > 0
    key = SysGetKey("NOECHO")
  end
  call SysCurPos 22, 0
  call charout , copies(" ", 239)
  call SysCurPos 22, 0
  call charout , '1b'x||'[32m'||copies("=", 80)||'1b'x||'[37m'
  call SysCurPos 23, 0
  call charout , "You made the top ten!  Please enter your name below (up to 15 letters)"
  call SysCurState ON
  call SysCurPos 24, 0
  call charout , "1b"x||"[41m"||"                "||"1b"x||"[40m"
  call SysCurPos 24, 0
  call charout , ">"
  parse pull name
  call SysCurState OFF
  return name

doLaser: procedure expose g. s.
/* show laser shot and test for meteor hits */
  call sound g.sound.laser
  if s.firepower > 0 then do
    s.firepower = s.firepower - 1
    queue "Firepower:"||s.firepower
    image = g.bigLaser
    width = g.bigLaser.width
    offset = g.bigLaser.offset
  end
  else do
    image = g.laser
    width = g.laser.width
    offset = g.laser.offset
  end

  s.charge = s.charge / 3   /* so...  24 * 3 turns fully charges the laser.  Hmmm. */
  if s.charge > 24 then
    s.charge = 24           /* the full height of the screen */

  /* draw laser vertically down screen */
  gotit = 0
  do i = 1 to s.charge
    test = SysTextScreenRead(i, s.col + offset, width)
    if pos(g.meteor, test) > 0 then do
      call sound g.sound.hit
      if test = "++ " | test = " ++" | test = "+ +" then
        gotit = gotit + 2
      else if test = "+++" then
        gotit = gotit + 3
      else
        gotit = gotit + 1
    end
    call SysCurPos i, s.col + offset
    call charout , image
  end

  /* erase laser */
  do i = 1 to s.charge
    call SysCurPos i, s.col + offset
    call charout , copies(" ", width)
  end

  /* check for hits */
  if gotit > 0 then do
    s.hits = s.hits + gotit
    queue "Score:"||s.hits*10+s.points*50
  end

  s.charge = 0
  return

doBomb: procedure expose g. s.
/* use a bomb (clear the screen) */
  if s.bomb = 0 then  /* do you have any bombs? */
    return

  call sound g.sound.bomb
  s.bomb = s.bomb - 1
  do i = 1 to 22
     call SysCurPos i, 17
     call charout , copies(" ", 63)
  end
  queue "Bomb:"s.bomb
  return

drawItems: procedure expose g. s.
/* draw meteors and bonus objects */
  /* show meteors */
  times = RANDOM(trunc(s.level/150)+2)  /* more meteors as s.level increases */
  do times
    call SysCurPos 24, RANDOM(16, 78)
    call charout , g.meteor
  end

  /* show bonus item */
  if random(10) = 0 then do
    sel = random(5) + 1
    call  SysCurPos 24, RANDOM(16, 78)
    call charout , '1b'x||'[4'sel'm'||substr(g.bonus, sel, 1)||'1b'x||'[40m'
  end

  /* show wall */
  call SysCurPos 24, 15
  say g.wall

  return

drawShip: procedure expose g. s.
/* draw the ship at the correct column */
  call SysCurPos 0, s.col
  call charout , g.shiplook
  return

displayGameMessages: procedure
/* show the status messages that show up on the left of the wall */
  call SysCurPos 24, 0
  parse pull msg
  call charout , '1b'x||'[37m'||msg
  return

incrementTurnData: procedure expose s.
/* take care of turn based house keeping */
  s.level = s.level + 1
  s.charge = s.charge + 1
  /*  I added s.onceALevel to replace code that looked like this:
      if s.level/150 = trunc(s.level/150) then  blah blah
      That's just too darn much division for an arcade game  */
  s.onceALevel = s.onceALevel + 1
  if s.onceALevel = 150 then do
    queue "Level:"trunc(s.level/150+1)    /* let the user know what level he/she is on */
    s.onceALevel = 0                      /* reset the counter */
    call charout s.demoFile, s.keystrokes /* flush the keystroke "buffer" */
    s.keystrokes = ""
  end
  return

testShipHit: procedure expose g. s.
/* see if the ship ran into anything */
  test = SysTextScreenRead(0, s.col, 3)
  if test = "   " then     /* didn't hit anything */
    return
  if pos(g.meteor, test) > 0 then do  /* OW!  you hit a meteor! */
    call sound g.sound.crash
    do 20
      call SysCurPos 0, s.col
      say g.shipCrash
      call SysCurPos 0, s.col
      say g.shipLook
    end
    s.shield = s.shield - 1
    if s.shield >= 0 then
      queue "Shield:"||s.shield
  end

  /* check for bonus objects */
  if pos("P", test) > 0 then do
    call sound g.sound.point
    s.points = s.points + 1
    queue "Score:"||s.points*50+s.hits*10
  end
  if pos("W", test) > 0 then do
    call sound g.sound.warp
    s.warp = s.warp + 1
    s.level = s.level - 50
    if s.level < 0 then
      s.level = 0
    queue "Warped!"
    queue "Level: "trunc(s.level/150)+1
  end
  if pos("B", test) > 0 then do
    call sound g.sound.bomb
    s.bomb = s.bomb + 1
    queue "Bomb:"s.bomb
  end
  if pos("C", test) > 0 then do
    call Sound g.sound.charge
    s.charge = 9999
    queue "Laser Charged!"
  end
  if pos("S", test) > 0 then do
    s.shield = s.shield + 1
    call Sound g.sound.shield
    queue "Shield:"s.shield
  end
  if pos("F", test) > 0 then do
    call Sound g.sound.firepower
    s.firepower = s.firepower + 5
    queue "Firepower:"||s.firepower
  end
  return

gameOver: procedure expose s.
/* show final score and other information */
  call cleanQueue
  call charout ,"1b"x||"[45m"
  queue ""
  queue "          Game Over"
  queue ""
  queue "  Level  :"||format(trunc(s.level/150)+1, 4)
  queue ""
  queue "  Meteors:"||format(s.hits, 4)||" x 10 = "||format(s.hits*10, 6)
  queue "  P Bonus:"||format(s.points, 4)||" x 50 = "||format(s.points*10, 6)
  queue "  Turns  :"||format((s.level+s.warp*50), 4)||" "||d2c(246)||" 10 = "||format(trunc((s.level+s.warp*50)/10), 6)
  queue ""
  queue "  Score  :            "||format(trunc(s.hits*10+s.points*50+(s.level+s.warp*50)/10), 6)
  queue ""
  queue "1b"x||"[40m"
  call displayMsg 5 32 0 30

  call SysSleep 2

  call checkScore

  return

sound: procedure expose g.
/* play a wav file */
  if \g.soundEnabled then
    return
  rc = mciRxSendString('load waveaudio 'arg(1), 'RetStr', '0', '0')
  rc = mciRxSendString('play waveaudio', 'RetStr', '0', '0')

  return

displayMsg: procedure
/* read through the queue and display the text lines in it */
  parse arg row column padAmount fillWidth
  if padAmount = "" then
    padAmount = 0
  if fillWidth = "" then
    fillWidth = 0
  do while queued() > 0
    call SysCurPos row, column
    parse pull msgLine
    if fillWidth > 0 then
      say copies(" ", padAmount)||msgLine||copies(" ", fillWidth-1-length(msgLine))||copies(" ", padAmount)
    else
      say copies(" ", padAmount)||msgLine||copies(" ", padAmount)
    row = row + 1
  end
  return

cleanQueue: procedure
/* purge the queue */
  do while queued() > 0
    pull
  end
  return

pauseIt:
/* this makes all PC's run the game at the same speed.  It pauses for .1 seconds */
  cnt = 0
  do while time("E") < .15   /* loop until .15 seconds have gone by */
    cnt = cnt + 1
  end
  do trunc((cnt*cnt)/85)
     nop
  end
  call time "R"
  return

halt:
cleanUp:
/* take care of housekeeping */
  call charout , "1b"x||"[40m"
  call SysCls
  say ""
  say "Thanks for playing!"
  if g.soundEnabled = 1 then do
    rc = mciRxSendString('close waveaudio wait', 'RetStr', '0', '0')
    call MciRxExit
  end
  exit
