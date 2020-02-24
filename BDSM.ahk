
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode 2

;pad := GetKeyState("JoyName")
;MsgBox, %pad%

vPath = %A_ScriptDir%\BDSMLog.txt
vSettings = %A_ScriptDir%\BDSMSettings.ini

FileAppend, `n-------------------`n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Script started, %vPath%, UTF-8

CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
CoordMode, ToolTip, Screen

mousedelay := 200
SetMouseDelay, %mousedelay%

#include lib\Vis2.ahk
;FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Vis2 Loaded, %vPath%, UTF-8
#include lib\FindText.ahk
;FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || FindText Loaded, %vPath%, UTF-8

; FINDTEXT PLUGIN VARS

chest:="|<>*151$24.vU0rW00Na009400A400Azzzzzzzz46MA46MA46MA47MA43sA41UA400A400A400AzzzzU" ; string representations of a chest
chest2:="|<>*123$25.zzzzys0zwE06QE016800H4009a004zzzzzzzzwkF0aM8UHA4E9a3s4n0s2NU01Ak00aM00HA009zzzzk"
closechest:="|<>*148$32.yw03ryA00AT6001XV0008sk0034A000l3000AEk0037zzzzzzzzzzkkAQ34A370l30lkAEkAQ34A3b0l30zUAEk7k34A000l3000AEk0034A000lX000ATw7sTy"
fishingBtn:="|<>*176$45.zzk003zzzzs00Tzzzzw03zzzsDw0Tzzz03w3zzzs01zzzzz001zzzzs000zzzz0003zzzs000zzzz0007zzzs001zzzz000Dzzzw003zzzzU00Tzzzw007zzzzk01zzvzy00DzyDzU01zzUzs007zk1s20sDw400kzUS3s0SDy00zkTVzw0TzzwDzsDzzzU3zzzzzs07zzvzy00TzyDzUT1zz0zs3y7zk1w0zsDwA"
fishingQTE:="|<>0xD7FFF9@0.60$45.0Tzz0Q007zz00s01zy003U0Tz000A07zXzU0k0zlzzU30Dyzzy081zjzzs1UTvy0TU43yT01y0kzbk03k67sw00T0Ey7U01s37ls00D0MwD000w371s007UMkD000w361s007UMkD000w761s00DUskDU01s760w00T1kk7k03kS20T00yDkM3y0TVy10DwTwzUA0zzz7w0U3zzXz0607zszk8M07sDy110007zUQ"
shopBtn:="|<>*134$23.zwTzzUTzz0zzzzzzzzzzk1zzU3zz07zy0DzxyTzvwzzrtzzDtztztzbzwyTzwtzzxrzztDzzuzzzlzzznzzza003A006M00Ak00kk01hU06RU0RtU1nU"

; VARIABLES

emulator := "MEmu" ; your emulator
spot := 2 ; farm spot
way := 500 ; farm spot button Y position
ttx := 1705 ; tooltip pos for fishing
tty := 680
Random, rand1, 0, 40
Random, rand2, 0, 40
queue := []
screenshot := 0


; TIMERS (IN SECONDS)

autovendordelay := 3600 ;
autospiritdelay := 4400 ;
autopetdelay := 11340 ;
autolightstonedelay := 7000 ;
autocrystaldelay := 9999999999999 ;
autoskillbookdelay := 5250 ;

autogatherduration := 70 ; time spent harvesting plants
automineduration := 70 ; time spent mining
autologduration := 110 ; time spent logging
reachfarmdelay := 130 ; time to walk to your farming spot

; TIMERS (IN MS)

lootchestdelay := 6400
windowchangedelay := 200 
retrydelay := 500

; FLAGS (ON LOAD) 

guivis := 1 ; Gui visibility
autoon := 0 ; Afk mode
buffon := 0 ; Buffing
autolooton := 0 ; Auto Chest Looting
buypots := 0 ;
autofish := 0 ;
kickreacton := 1 ; Detecting Login Screen
deadreacton := 1 ; Detecting death
hottime := 0 ; reduce timers
testtime := 0 ; debug mode
botbusy := 0 ; test flag
overridewayflag := 1 ; 1 if youre going to iron mine supply route, otherwise 0


SetTimer, kickreact, 30000 ;
SetTimer, checkifdead, 20000 ;

; FOCUS EMULATOR WINDOW

;gosub activateemulatorwindow
WinActivate, %emulator%
WinWait,, %emulator%
WinMove,, %emulator%, 590, 3

; INITIALIZE GUI

Progress, m1 x0 y0 b fs18 zh0 w300, Vendor Paused
Progress, 2:On m1 x0 y55 b fs18 zh0 w300, SpiritFeed Paused
Progress, 3:On m1 x0 y110 b fs18 zh0 w300, PetFeed Paused
Progress, 4:On m1 x0 y165 b fs18 zh0 w300, FuseLightstone Paused
Progress, 5:On m1 x0 y220 b fs18 zh0 w300, UseSkillbooks Paused

Gui, +AlwaysOnTop
Gui, -border
Gui, Show, x310 y0 w260 h300

Gui, Add, Button, Section w120, Vendor Now
Gui, Add, Button, ys xs+120 w120, Feed Black Spirit Now
Gui, Add, Button, xs w120, Feed Pets Now
Gui, Add, Button, ys+29 xs+120 w120, Learn Skillbooks Now
Gui, Add, Button, ys+57 xs w120, Fuse Lightstones Now
Gui, Add, DropDownList, vLsGrade ys+58 xs+120, Normal|Magic|Rare||Unique|Epic
Gui, Add, Button, ys+86 xs w120, Fuse Crystals Now
Gui, Add, DropDownList, vGemGrade ys+87 xs+120, Normal|Magic||Rare|Unique|Epic
Gui, Add, Button, ys+114 xs w46, Go Farm
Gui, Add, DropDownList, vWayOverride ys+115 xs+46 w79, NoOverride||Iron Mine|
Gui, Add, Button, ys+114 xs+125 w115, Do Daily Chores


Gui, Add, Text, xs-2 Section, Farming Spot:
Gui, Add, Button, ys+2 xs+65, 1
Gui, Add, Button, ys+2 xs+85, 2
Gui, Add, Button, ys+2 xs+105, 3
Gui, Add, Text, vFarmDisp ys+13 xs, Current: %spot%
Gui, Add, Button, vBuffBtn ys+2 xs+125 w120, Buff Casting Inactive
Gui, Add, Button, vAutoBtn ys+29 xs w120, Activate Auto
;Gui, Add, Button, vKickBtn ys+29 xs+120 w80, KickReact ON
;Gui, Add, Text, vKickDisp ys+33 xs+201 w60, Initializing
Gui, Add, Button, vAutoFishBtn ys+29 xs+125 w120, Auto Fishing Disabled
Gui, Add, Button, vAutoLootBtn ys+57 xs w120, Not Looking for Chests
Gui, Add, Text, vChestDisp ys+61 xs+125 w120
Gui, Add, Button, vHotTimeBtn ys+86 xs, Hot Time Disabled
Gui, Add, Button, vDeadReactBtn ys+86 xs+100 w105, DeadReact ON
Gui, Add, Button, vTestTimeBtn ys+86 xs+205, Debug
Gui, Add, Edit, hwndExeBox vExeBox ys+115 xs w120 WantReturn
;Gui, Add, Edit, hwndExeBox ys+115 xs w120
SetEditCueBanner(ExeBox, "Execute Subroutine")
Gui, Add, Button, Default ys+115 xs+120 w25, OK
Gui, Add, Button, vbsModeBtn ys+115 xs+145 w105, BS Mode Disabled

Gui, Show, , EM_SETCUEBANNER

FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Script Load Complete, %vPath%, UTF-8
return

SetEditCueBanner(HWND, Cue) {  ; requires AHL_L
  
   Static EM_SETCUEBANNER := (0x1500 + 1)
   Return DllCall("User32.dll\SendMessageW", "Ptr", HWND, "Uint", EM_SETCUEBANNER, "Ptr", True, "WStr", Cue, "Str", wText)
   ;return wText
   ;by just me posted on ahk forums
}


; GUI BUTTON SCRIPTS

ButtonOK:
Gui, Submit, Nohide
;inpt := %ExeBox%
;if IsLabel(%inpt%) 
;{
;FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || User: Executed "%ExeBox%" subroutine, %vPath%, UTF-8
gosub %ExeBox%
;} else {
GuiControl,, ExeBox,
;}
return

ButtonVendorNow:

FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || User: Vendor Now, %vPath%, UTF-8
queue.Insert("vendor")
if (botbusy=0) {
gosub % queue[1]
}
return

ButtonFeedBlackSpiritNow:

FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || User: Feed Black Spirit Now, %vPath%, UTF-8
queue.Insert("feedspirit")
if (botbusy=0) {
gosub % queue[1]
}
return

ButtonFeedPetsNow:

FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || User: Feed Pets Now, %vPath%, UTF-8
queue.Insert("feedpets")
if (botbusy=0) {
gosub % queue[1]
}
return

ButtonLearnSkillbooksNow:

FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || User: Use Skillbooks Now, %vPath%, UTF-8
queue.Insert("useskillbook")
if (botbusy=0) {
gosub % queue[1]
}
return

ButtonFuseLightstonesNow:

FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || User: Fuse Lightstones Now, %vPath%, UTF-8
queue.Insert("fuselightstone")
if (botbusy=0) {
gosub % queue[1]
}
return

ButtonFuseCrystalsNow:

FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || User: Fuse Crystals Now, %vPath%, UTF-8
queue.Insert("fusecrystal")
if (botbusy=0) {
gosub % queue[1]
}
return

ButtonDoDailyChores:

FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || User: Do Daily Chores, %vPath%, UTF-8
gosub pausefightscripts
queue.Insert("gogather")
queue.Insert("greetall")
;Sleep 100
;gosub praiseranks
;Sleep 100
;gosub getpearlshoprewards
;Sleep 100
;gosub openinvchests
;Sleep 100
;gosub feedspirit
;Sleep 100
;gosub useskillbook
;Sleep 100
;gosub miscchores
;Sleep 100
;gosub collecttasks
;Sleep 100
;gosub getmail
if (botbusy=0) {
gosub % queue[1]
}
return

ButtonGoFarm:

FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || User: Go Farm, %vPath%, UTF-8
queue.Insert("gofarm")
if (botbusy=0) {
gosub % queue[1]
}
return

ButtonOverride:

;Gui,Submit,Nohide
;if IsLabel(%ExeBox%) 
;{
;GuiControl,, ExeBox, Valid subroutine
;gosub %ExeBox%
;} else {
;GuiControl,, ExeBox, Not a valid subroutine
;}
return

Button1:
way = 400
spot = 1
GuiControl,, FarmDisp, Current: %spot%
return

Button2:
way = 500
spot = 2
GuiControl,, FarmDisp, Current: %spot%
return

Button3:
way = 600
spot = 3
GuiControl,, FarmDisp, Current: %spot%
return

ButtonBuffCastingInactive:

Random, mod, 15, 2500
if (buffon = 0) {
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || User: Buffing enabled, %vPath%, UTF-8
gosub usebuff
GuiControl ,, BuffBtn, Buff Casting Active
buffon = 1
SetTimer, atqusebuff, % 123000 + mod
} else {
GuiControl ,, BuffBtn, Buff Casting Inactive
buffon = 0
SetTimer, atqusebuff, off
}
return


ButtonActivateAuto:

if (autoon = 0) {
GuiControl ,, AutoBtn, Auto Mode Active
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || User: Auto Mode Activated, %vPath%, UTF-8
gosub startautospirit
gosub startautovendor
gosub startautopet
if !LsGrade {
Gui, Submit, Nohide
}
gosub startautolightstone
gosub startautoskillbook
autoon = 1
} else {
GuiControl ,, AutoBtn, Activate Auto
gosub pauseauto
autoon = 0
}
return


ButtonAutoFishingDisabled:

if (autofish=0) {
autofish=1
GuiControl ,, AutoFishBtn, Auto Fishing ON
gosub fish
} else {
autofish=0
GuiControl ,, AutoFishBtn, Auto Fishing Disabled
;SetTimer, fish, off
}
return


;ButtonKickReactON:

;if (kickreacton = 1) {
;  SetTimer, kickreact, off
;  GuiControl ,, KickBtn, KickReact OFF
;  kickreacton := 0
;} else {
;  SetTimer, kickreact, 30000
;  GuiControl ,, KickBtn, KickReact ON
;  kickreacton := 1
;}
;return


ButtonNotLookingforChests:

Random, mod, 15, 500
if (autolooton = 0) {
GuiControl ,, AutoLootBtn, Chest Looting Active
autolooton = 1
gosub activateemulatorwindow
gosub lookforchest
SetTimer, atqlookforchest, % lootchestdelay+mod
} else if (autolooton = 1) {
GuiControl ,, AutoLootBtn, Looting Close Chests
autolooton = 2
} else {
GuiControl ,, AutoLootBtn, Not Looking for Chests
autolooton = 0
SetTimer, atqlookforchest, off
}
return


ButtonHotTimeDisabled:

if (hottime=0) {
autovendordelay := Floor(autovendordelay/1.8) ;
autospiritdelay := Floor(autospiritdelay/1.5) ;
autolightstonedelay := Floor(autolightstonedelay/1.5) ;
autocrystaldelay := Floor(autocrystaldelay/1.5) ;
autoskillbookdelay := Floor(autoskillbookdelay/1.5) ;
GuiControl ,, HotTimeBtn, Hot Time ON
hottime = 1
} else {
autovendordelay = Floor(autovendordelay*1.8) ;
autospiritdelay = Floor(autospiritdelay*1.5) ;
autolightstonedelay = Floor(autolightstonedelay*1.5) ;
autocrystaldelay = Floor(autocrystaldelay*1.5) ;
autoskillbookdelay = Floor(autoskillbookdelay*1.5) ;
GuiControl ,, HotTimeBtn, Hot Time Disabled
hottime = 0
}
return


ButtonDeadReactON:

if (deadreacton=0) {
deadreacton=1
GuiControl ,, DeadReactBtn, DeadReact ON
SetTimer, checkifdead, 20000
} else {
deadreacton=0
GuiControl ,, DeadReactBtn, DeadReact Disabled
SetTimer, checkifdead, off
}
return


ButtonDebug:

if (testtime=0) {
autovendordelay := Floor(autovendordelay/10) ;
autospiritdelay := Floor(autospiritdelay/10) ;
autolightstonedelay := Floor(autolightstonedelay/10) ;
autocrystaldelay := Floor(autocrystaldelay/10) ;
autoskillbookdelay := Floor(autoskillbookdelay/10) ;
GuiControl ,, TestTimeBtn, ON
testtime = 1
} else {
autovendordelay = Floor(autovendordelay*10) ;
autospiritdelay = Floor(autospiritdelay*10) ;
autolightstonedelay = Floor(autolightstonedelay*10) ;
autocrystaldelay = Floor(autocrystaldelay*10) ;
autoskillbookdelay = Floor(autoskillbookdelay*10) ;
GuiControl ,, TestTimeBtn, OFF
testtime = 0
}
return

ButtonBSModeDisabled:

GuiControl ,, bsModeBtn, BS Mode ON
Gui, Hide
Progress, 2:Hide
Progress, 3:Hide
Progress, 4:Hide
Progress, 5:Hide
guivis := 0
gosub startautobsmode


; KEYBOARD KEYS


F1::gosub autobsmode

F2::

;text := OCR([820, 308, 60, 21]) ; read pet food count
;text := OCR([1010, 530, 100, 40]) ; read 
;text := OCR([1010, 450, 100, 40]) ; read 
text2 := OCR([968, 405, 250, 40]) ; read killer
text := OCR([1068, 280, 250, 40]) ; read killer
StringReplace , text2, text2, %A_Space%,,All
msgbox % SubStr(text2, 1, InStr(text2, "]")) 
MsgBox, %text% ; killer: %text2%
return

F3::

;PixelGetColor, Color3, 1135, 552 ; dead screen pixel
;PixelGetColor, Color3, 1578, 255 ; quest px
PixelGetColor, Color3, 1150, 285 ; town btn px
;PixelGetColor, Color3, 1700, 700 ; greetall pixel
;PixelGetColor, Color3, 1166, 546
clipboard=%Color3%
MsgBox, %Color3%
return

F4::
if (ok:=FindText(1560, 450, 300, 300, 0.18, 0.18, shopBtn, FindAll:=0)) {
  CoordMode, Mouse
  X:=ok.1.1, Y:=ok.1.2, W:=ok.1.3, H:=ok.1.4, Comment:=ok.1.5, X+=W//2, Y+=H//2
  Click, %X%, %Y%
}
return

F5::

PixelGetColor,Col,700,378
PixelGetColor,Col2,767,378
PixelGetColor,Col3,834,378
if (Col=0xCFCF84 || Col2=0xD3D386 || Col3=0xD3D386) {
return
}
;ToolTip, Pet Status Colors %Col% %Col2% %Col3%
Sleep 300

F6::
BlockInput, MouseMove
MouseMove, 1555, 65 ; go to camp
Sleep 56
Click
Sleep 400
Click, 1320, 560 ; confirm
BlockInput, MouseMoveOff
return


^SC056::
Send, FileAppend, ``n`%A_YYYY`%.`%A_MM`%.`%A_DD`% `%A_Hour`%:`%A_Min`%:`%A_Sec`% || , `%vPath`%, UTF-8
return


; GAMEPAD MAPPING

;JoyX::Send, a
Joy1::Send, k
Joy2::Send, o
Joy3::Send, i
Joy4::Send, u

; OTHER SCRIPTS

BasicClick(x, y)     ;// input coords relative to a full window (including borders and caption)
{
   CoordMode, Mouse, Screen
   MouseGetPos, oldx, oldy
   WinGetTitle, oldapp, A
   WinActivate,, %emulator%   
   BlockInput, MouseMove
   ;CoordMode, Mouse, Relative
   Click %x%, %y%
   ;CoordMode, Mouse, Screen
   if (oldapp!="") {
   WinActivate, %oldapp%,, AutoHotkey
   }
   MouseMove, %oldx%, %oldy%, 0
   BlockInput, MouseMoveOff
}

activateemulatorwindow:

if WinActive(!%emulator%) {
WinActivate, % emulator
Sleep %windowchangedelay%
}
WinMove,, %emulator%, 590, 3
return

makescreenshot:

%screenshot%++
CaptureScreen(1)
Convert("screen.bmp", "shot" . %screenshot% . ".png")
FileDelete, screen.bmp
return


randomize:

Random, rand1, 0, 35
Random, rand2, 0, 35
Random, rand3, 0, 3
if (rand3=0) {
rand1 *= -1
} else if (rand3=1) {
rand2 *= -1
} else if (rand3=2){
rand1 *= -1
rand2 *= -1
}
;ToolTip, %rand1% . %rand2%, %ttx%, %tty%
return


; BOT CONTROL SCRIPTS


pauseauto:

FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || User: Auto Mode Paused, %vPath%, UTF-8
;SetTimer, clickquest, off
SetTimer, atqpet, off
SetTimer, atqvendor, off
SetTimer, atqspirit, off
SetTimer, atqlightstone, off
SetTimer, atqskillbook, off
settimer,avpopup,off
settimer,aspopup,off
settimer,appopup,off
settimer,alpopup,off
settimer,akpopup,off
Progress, m1 x0 y0 b fs18 zh0 w300, Vendor Paused
Progress, 2:On m1 x0 y55 b fs18 zh0 w300, SpiritFeed Paused
Progress, 3:On m1 x0 y110 b fs18 zh0 w300, PetFeed Paused
Progress, 4:On m1 x0 y165 b fs18 zh0 w300, FuseLightstone Paused
Progress, 5:On m1 x0 y220 b fs18 zh0 w300, UseSkillbooks Paused
return


overrideway:

Gui, Submit, Nohide
if (WayOverride="NoOverride") {
overridewayflag=0
} else if (WayOverride="Iron Mine") {
overridewayflag=1
}
if (overridewayflag=1) { ; override through iron mine work site
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || override through Iron Mine Work Site, %vPath%, UTF-8
MouseMove, 660, 250 ; pick map mode
Sleep 50
Click
Sleep 359
MouseMove, 620, 205 ; open world map
Sleep 50
Click
Sleep 1239
MouseMove, 1650, 430 ; pick mediah
Sleep 50
Click
Sleep 895
MouseMove, 1510, 590 ; go to iron mine work site
Sleep 50
Click
Sleep 1100
MouseMove, 1230, 660 ; confirm
Sleep 30
Click
gosub detectloadingscreen
}
MouseMove, 910, 210 ; open waypoint menu
Sleep 30
Click
Sleep 400
MouseMove, 1500, %way% ; go to farming spot
Sleep 30
Click
return


pausefightscripts:

FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Pausing fight scripts, %vPath%, UTF-8
if (autolooton=1 || autolooton=2) {
settimer, atqlookforchest, off
GuiControl ,, AutoLootBtn, Chest Looting Paused
autolooton := 3
}
if (buffon=1) {
settimer, atqusebuff, off
GuiControl ,, BuffBtn, Buff Casting Paused
buffon := 2
}
SetTimer, restartfightscripts, % reachfarmdelay * -1000
Sleep 1000
return


restartfightscripts:

FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Reached farming zone. Restarting fight scripts, %vPath%, UTF-8
;MsgBox, Reached Farming Zone (?)
queue.Insert("orientview")
if (autolooton=3) {
settimer, atqlookforchest, %lootchestdelay%
GuiControl ,, AutoLootBtn, Looting Close Chests ;Chest Looting Active
autolooton := 2
}
if (buffon=2) {
Random, mod, 15, 2500
queue.Insert("usebuff")
SetTimer, atqusebuff, % 123000 + mod
GuiControl ,, BuffBtn, Buff Casting Active
buffon := 1
}
Sleep 1000
return


unlockscreen:

PixelGetColor,Color,780,430
if Color=000000
{
  FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Locked Screen Detected. Unlocking, %vPath%, UTF-8
  MouseMove, 1220, 430
  Sleep 40
  Send {LButton Down}
  Sleep 30
  MouseMove, 1330, 400
  Sleep 50
  MouseMove, 1130, 330
  Sleep 10
  Send {LButton Up}
  Sleep 2300
  MouseMove, 1230, 610
  Sleep 60
  Click
  Sleep 859
}
return


exitmenus:

Loop {
PixelGetColor, Color2, 1755, 79 ;1760,72 
 if (Color2!=0xEDEDED) {
  MouseMove, 1820, 67
  Sleep 30
  Click
  Sleep 900
 } else {
  Color2 := % A_Index - 1
  ;FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || exitmenus closed %Color2% menus, %vPath%, UTF-8 
  break
 }
}
Sleep 300
return


orientview:

if (botbusy=0) {
botbusy=1
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Orienting view, %vPath%, UTF-8
BlockInput, MouseMove
SetMouseDelay, 10
SendMode, Event
MouseClickDrag, Left, 1200, 535, 1200, 170, 10
Sleep 50
MouseClickDrag, Left, 1200, 260, 1200, 340, 10
BlockInput, MouseMoveOff
SetMouseDelay, %mousedelay%
SendMode, Input
Sleep 500
botbusy=0
}
queue.Remove(1)
if (queue[1]!="") {
gosub % queue[1]
}
return


;antistuck: ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;IfWinActive, % emulator
;{
;PixelGetColor, Color3, 1166, 546
;ToolTip, %Color3%
;if (Color3=0xFFFFFF) {
; Sleep 5000
; PixelGetColor, Color3, 1166, 546
; FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || AntiStuck Test 1 Passed, %vPath%, UTF-8
; ;ToolTip, %Color3%
; if (Color3=0xFFFFFF) {
;  FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Stuck on chest pickup. Attempting fix, %vPath%, UTF-8
 ; MouseMove, 1050, 690 ;
 ; Send {w down}
 ; Sleep 700
 ; Send, k
 ; Sleep 50
 ; Send, {w up}
 ; Sleep 50
;  Click
;  Sleep 600
;  Click
; }
;} else {  
; return
;}
;Sleep 500
;} else {
; ;ToolTip, Out of Focus
;}
;return


checkifdead:

if(deadreacton=1){
text := OCR([1010, 530, 100, 40]) ; read revive button
text2 := OCR([1010, 450, 100, 40]) ; read 
if (text="Revive") {
text := OCR([1068, 280, 250, 40]) ; read killer
StringReplace , text2, text2, %A_Space%,,All
;msgbox % SubStr(text2, 1, InStr(text2, "]")) 
gosub makescreenshot
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Killed by %text%. Returning to farm., %vPath%, UTF-8
MouseMove, 1366, 550 ; respawn in town
  Sleep 40
  Click
  gosub detectloadingscreen
  gosub gofarm
} else if (text2="Revive") {
text := OCR([968, 405, 250, 40]) ; read killer
;msgbox % SubStr(text2, 1, InStr(text2, "]")) 
gosub makescreenshot
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Killed by %text%. Returning to farm., %vPath%, UTF-8
MouseMove, 1366, 470 ; respawn in town
  Sleep 40
  Click
  buypots=1
  gosub pausefightscripts
  gosub detectloadingscreen
  gosub vendor
  if (autoon=1) {
  gosub startautovendor
  }
  buypots=0
}
}
Sleep 200
return


detectloadingscreen:

Loop {
PixelGetColor, Color3, 1827, 72 ; pre loading screen pixels
PixelGetColor, Color2, 827, 72
if (Color3!=0x000000 && Color2!=0x000000) {
;FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || NO Black Screen Detected. Waiting. IND: %A_Index%, %vPath%, UTF-8
;ToolTip, NO Black Screen Detected. Waiting. IND: %A_Index%
Sleep 100
} else {
;FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Black Screen Detected. Waiting. IND: %A_Index%, %vPath%, UTF-8
;ToolTip, Black Screen Detected. Waiting. IND: %A_Index%
Sleep 500
break
}
}
Loop {
PixelGetColor, Color3, 780, 640 ; pre loading screen pixel
if (Color3=0x000000) {
;FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Black Screen Detected. Waiting. IND: %A_Index%, %vPath%, UTF-8
;ToolTip, NO Loading Screen Detected. Waiting. IND: %A_Index%
Sleep 100
} else {
;FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || No Black Screen Detected. Looking for loading screen. IND: %A_Index%, %vPath%, UTF-8
;ToolTip, Black Screen Detected. Looking for loading screen. IND: %A_Index%
Sleep 1000
break
}
}
Loop {
PixelGetColor, Color3, 780, 640 ; loading screen pixel
if (Color3=0xD78B55) {
;FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Loading Screen Detected. Waiting. IND: %A_Index%, %vPath%, UTF-8
;ToolTip, Loading Screen Detected. Waiting. IND: %A_Index%
Sleep 500
} else {
;FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Loading Complete. Breaking loop. IND: %A_Index%, %vPath%, UTF-8
;ToolTip, NO Loading Screen Detected. Breaking loop. IND: %A_Index%
Sleep 1000
break
}
}

return


kickreact:
;9VKBJEAPF1Q
IfWinActive, % emulator ;"MEmu") {
{
PixelGetColor,Color,1020, 178
;ToolTip, %Color%
if Color=0xFFFFFF
{
Sleep 3400
PixelGetColor, Color, 1020, 178
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || KickReact Logout Test 1 Passed, %vPath%, UTF-8
 if (Color=0xFFFFFF) {
  gosub pausefightscripts
  FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || KickReact Logout Detected. Attempting login, %vPath%, UTF-8
  gosub activateemulatorwindow
  BlockInput, MouseMove
  MouseMove, 1080, 220 ; sign in with google
  Sleep 40
  Click
  Sleep 2000
  MouseMove, 1070, 425 ;440 ; choose account
  Sleep 50
  Click
  Sleep 2500
  Click
  Sleep 6000
  MouseMove, 1700, 95 ; choose char
  Sleep 10
  Click
  Sleep 11300
  MouseMove, 1810, 153 ; cancel popup
  Sleep 60
  Click
  Sleep 159
  Click
  Sleep 300
  MouseMove, 1320, 570 ; confirm cancel
  Sleep 60
  Click
  Sleep 1400
  if (autoon=1) {
  MouseMove, 910, 210 ; open waypoint menu
  Sleep 30
  Click
  Sleep 300
  MouseMove, 1500, %way% ; go to farm area
  Sleep 30
  Click
  }
  BlockInput, MouseMoveOff
  Sleep 1000
  }
} else {
  GuiControl,, KickDisp, OK
}
}
else
{
GuiControl,, KickDisp, Out of focus
}
return


; BOT SCRIPTS


gofarm:

gosub activateemulatorwindow
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Going back to farm, %vPath%, UTF-8
Gui, Submit, Nohide
if (overridewayflag>0) {
gosub overrideway
} else {
MouseMove, 910, 210 ; open waypoint menu
Sleep 30
Click
Sleep 300
MouseMove, 1500, %way% ; go to farming spot
Sleep 30
Click
}
gosub detectloadingscreen
return


usebuff:

Loop {
PixelGetColor, Color, 1755, 50
;ToolTip, %Color%
if (Color=0xFFFFFF) {
ToolTip, Writing Message. Buffing delayed
Sleep 1000
} else {
break
}
}
if (botbusy=0) {

BlockInput, MouseMove
;gosub activateemulatorwindow
gosub exitmenus
PixelGetColor,Color,1850,402
;ToolTip, %Color%
if Color=0xEDEDED
{
  MouseMove, 1858, 400 ; open buff panel
  Sleep 30
  Click
  Sleep 1160
}
Loop {
 PixelGetColor,Color,1595,402
 ;ToolTip, Looping: %Color%
 if Color=0xEDEDED
 {  
  MouseMove, 1665, 410 ; use buff
  Sleep 30
  BasicClick(1665, 410)
  Click
  ;ControlClick, x1665 x410, %emulator%,, Left, Pos ;x1080 x400
  Sleep 500  
 } else {
  count = % A_Index - 1
  if (count = 0) {
   FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Buff still on cooldown., %vPath%, UTF-8 
  } else if (count > 0) {
   FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Buff applied in %count% tries., %vPath%, UTF-8 
  }
  break
 }
}
BlockInput, MouseMoveOff
Sleep 500
} else {
  FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Subroutine Detected, Buff not applied
}
queue.Remove(1)
if (queue[1]!="") {
gosub % queue[1]
}
return


lookforchest:

IfWinActive, % emulator
{
if (botbusy = 0) {
PixelGetColor,Col,700,378
PixelGetColor,Col2,767,378
PixelGetColor,Col3,834,378
if (Col=0xCFCF84 || Col2=0xD3D386 || Col3=0xD3D386) {
GuiControl,, ChestDisp, Pet Ready
queue.Remove(1)
if (queue[1]!="") {
gosub % queue[1]
}
return
}
ScreenShot()
if (ok2:=FindText(917, 140, 630, 430, 0.25, 0.25, closechest, FindAll:=0))
{
  BlockInput, MouseMove
  CoordMode, Mouse
  X:=ok2.1.1, Y:=ok2.1.2, W:=ok2.1.3, H:=ok2.1.4, Comment:=ok2.1.5, X+=W//2, Y+=H//2
  Click, %X%, %Y%
  GuiControl,, ChestDisp, Close Chest %X% %Y%
  BlockInput, MouseMoveOff
  FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Close Chest Found at x: %X%  y: %Y%, %vPath%, UTF-8
  Sleep 3000
} 
else if (autolooton=1 && ok:=FindText(917, 140, 630, 430, 0.18, 0.18, chest, FindAll:=0))
{  
  BlockInput, MouseMove
  CoordMode, Mouse
  X:=ok.1.1, Y:=ok.1.2, W:=ok.1.3, H:=ok.1.4, Comment:=ok.1.5, X+=W//2, Y+=H//2
  Click, %X%, %Y%
  GuiControl,, ChestDisp, Chest %X% %Y%
  BlockInput, MouseMoveOff
  FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Chest 1 Found at x: %X%  y: %Y%, %vPath%, UTF-8
  Sleep 3000
} 
else if (autolooton=1 && ok2:=FindText(917, 140, 630, 430, 0.25, 0.25, chest2, FindAll:=0)) ; 1540
{
  BlockInput, MouseMove
  CoordMode, Mouse
  X:=ok2.1.1, Y:=ok2.1.2, W:=ok2.1.3, H:=ok2.1.4, Comment:=ok2.1.5, X+=W//2, Y+=H//2
  Click, %X%, %Y%
  GuiControl,, ChestDisp, Chest 2 %X% %Y%
  BlockInput, MouseMoveOff
  FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Chest 2 Found at x: %X%  y: %Y%, %vPath%, UTF-8
  Sleep 3000
} 
else 
{
  PixelGetColor,Color2,1760,72
  if (Color2=0xEDEDED) {
  GuiControl,, ChestDisp, No Chest Found
  BlockInput, MouseMove
  Random, mod2, 1, 170
  MouseMove, 1615, % 190+mod2 ;1110, 430
  Sleep 40
  Send {LButton Down}
  Sleep 30
  SetMouseDelay, 10
  SendMode, Event
  MouseMove, 1200, % 190+mod2, 15 ;430, 20
  SetMouseDelay, %mousedelay%
  SendMode, Input   
  Send {LButton Up}
  BlockInput, MouseMoveOff
  } else {
  GuiControl,, ChestDisp, In Menu
  }
}
} else {
  GuiControl,, ChestDisp, Subroutine Detected
}
} else {
 GuiControl,, ChestDisp, Out of focus
}
queue.Remove(1)
if (queue[1]!="") {
gosub % queue[1]
}
;gosub antistuck
return


fish:

;Click, 1750, 640
Loop 
{
;ToolTip, Starting Loop, %ttx%, %tty%
if (autofish=0) 
{
  ToolTip, AutoFish OFF
  break
}
else if (ok:=FindText(1710, 595, 85, 75, 0.35, 0.35, FishingBtn))
{
  ToolTip, Reeling in, %ttx%, %tty%
  CoordMode, Mouse
  X:=ok.1.1, Y:=ok.1.2, W:=ok.1.3, H:=ok.1.4, Comment:=ok.1.5, X+=W//2, Y+=H//2
  gosub randomize
  xr = % X+rand1 ; randomize click location
  yr = % Y+rand2
  BlockInput, MouseMove
  Click, %xr%, %yr%
  Loop {
    if (ok:=FindText(1380, 235, 80, 180, 0.3, 0.3, FishingQTE)) {
    ToolTip, Caught a fish, %ttx%, %tty%
    gosub randomize
    Click, 1750+rand1, 640+rand2
    gosub randomize
    Sleep 3000+rand1+rand2
    Click, 1752+rand1, 641+rand2
    BlockInput, MouseMoveOff
    if (autofish=1) {
    settimer, fish, -2000
    } else {
    ToolTip, Fishing Paused, %ttx%, %tty%
    }
    MouseMove, 1830, 700
    break       
  } else {
    Random, rand, 0, 32
    tosleep=% 100+rand
    Sleep %tosleep%
    ToolTip, Sleeping %tosleep%, %ttx%, %tty%
  }
  }
} else {
  Random, rand, 10, 50
  tosleep=% 1200+rand
  ToolTip, Sleeping %tosleep% ms, %ttx%, %tty%
  Sleep %tosleep%
}
}
return


feedspirit:

if (autoon=1) {
 x_as = %autospiritdelay% ; reset progressbox variables
 t_as := 0
}
Random, mod, 15, 30 ; add randomness to the delay
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Feeding Gear to the Black Spirit, %vPath%, UTF-8
botbusy := 1
BlockInput, MouseMove
gosub activateemulatorwindow
gosub unlockscreen
gosub exitmenus
MouseMove, 1825, 70 ; open menu
Sleep 56
Click
Sleep 400 + mod
MouseMove, 1600, 150 ; open bs menu
Sleep 53
Click
Sleep 720 + mod
MouseMove, 1110, 665 ; open feed menu
Sleep 52
Click
Sleep 300 + mod
MouseMove, 1650, 680 ; load items
Sleep 56
Click
Sleep 340 + mod
MouseMove, 1250, 690 ; press feed button 
Sleep 53
Click
Sleep 340 + mod
MouseMove, 1320, 555 ; confirm feed
Sleep 56
Click
Sleep 460 + mod
MouseMove, 1820, 65 ; exit window
Sleep 52
Click
BlockInput, MouseMoveOff
Sleep 1000
botbusy := 0
queue.Remove(1)
if (queue[1]!="") {
FileAppend, % "`n" A_YYYY "." A_MM "." A_DD " " A_Hour ":" A_Min ":" A_Sec " || Black Spirit Fed. Running " queue[1], %vPath%, UTF-8
gosub % queue[1]
} else {
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Black Spirit Fed. Sleeping, %vPath%, UTF-8
}
return


feedpets:


if (autoon=1) {
 x_ap = %autopetdelay% ; reset progressbox variables
 t_ap := 0
}
Random, mod, 15, 30 ; add randomness to the delay
botbusy := 1
BlockInput, MouseMove
gosub activateemulatorwindow
gosub unlockscreen
gosub exitmenus
MouseMove, 710, 400 ; open pet menu
Sleep 56
Click
Sleep 720 + mod
text := OCR([1001, 710, 38, 20])
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Preparing to feed. Pet Food: %text%, %vPath%, UTF-8

MouseMove, 1024, 707 ; feed pet 1
Sleep 56
Click
Sleep 308 + mod
MouseMove, 1600, 380 ; select pet 2
Sleep 53
Click
Sleep 300 + mod
MouseMove, 1030, 709 ; feed pet 2
Sleep 52
Click
Sleep 308 + mod
MouseMove, 1600, 505 ; select pet 3
Sleep 53
Click
Sleep 300 + mod
MouseMove, 1038, 704  ; feed pet 3
Sleep 52
Click
Sleep 322 + mod
MouseMove, 1238, 704 ; move out of view and record pet food
text := OCR([1001, 710, 38, 20])
Send {Esc}
BlockInput, MouseMoveOff
Sleep 1000
botbusy := 0
queue.Remove(1)
if (queue[1]!="") {
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Pets fed. Pet Food: %text%. Running %queue%[1], %vPath%, UTF-8
gosub % queue[1]
} else {
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Pets fed. Pet Food: %text%. Sleeping, %vPath%, UTF-8
}
return


fuselightstone:

if (autoon=1) {
 x_al = %autolightstonedelay% ; reset progressbox variables
 t_al := 0
}
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Fusing lightstones up to %LsGrade% grade, %vPath%, UTF-8
botbusy := 1
BlockInput, MouseMove ; block mouse and activate MEmu window
gosub activateemulatorwindow
gosub unlockscreen
gosub exitmenus
Gui, Submit, Nohide
MouseMove, 1824, 72 ; open menu 
Sleep 56
Click
Sleep 558
MouseMove, 1600, 150 ; open bs menu
Sleep 53
Click
Sleep 720
MouseMove, 750, 620 ; open lightstone menu
Sleep 32
Click
Sleep 1308
PixelGetColor,ColorIdle, 905, 492 ;, 1077, 217
MouseMove, 1550, 695 ; open auto fusing
Sleep 53
Click
Sleep 360 ; switch to desired grade
if(LsGrade = "Normal") {
 MouseMove, 950, 475
} else if(LsGrade = "Magic") {
 MouseMove, 1080, 475
} else if(LsGrade = "Rare") {
 MouseMove, 1240, 475
} else if(LsGrade = "Unique") {
 MouseMove, 1380, 475
} else if(LsGrade = "Epic") {
 MouseMove, 1520, 475
}
Sleep 150
Click
Sleep 349
MouseMove, 1322, 590 ; confirm fusion
Sleep 52
Click
Sleep 700
Loop {
 PixelGetColor,Color1, 905, 492 ; check px color to see if finished
 ;ToolTip, %Color1%`n%ColorIdle%
 Sleep 30 
 if (Color1 = ColorIdle) { ; if colors match exit menu and release mouse
  MouseMove, 1834, 72
  Sleep 56
  Click
  BlockInput, MouseMoveOff
  break
 } else { ; else check again
  Sleep 500
 }
}
Sleep 1000
botbusy := 0
queue.Remove(1)
if (queue[1]!="") {
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Lightstone Fusion Successful. Running %queue%[1], %vPath%, UTF-8
gosub % queue[1]
} else {
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Lightstone Fusion Successful. Sleeping, %vPath%, UTF-8
}
return


fusecrystal:

FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Fusing crystals up to %GemGrade% grade, %vPath%, UTF-8
botbusy := 1
BlockInput, MouseMove ; block mouse and activate MEmu window
gosub activateemulatorwindow
Gui, Submit, Nohide
gosub unlockscreen
gosub exitmenus
MouseMove, 1824, 72 ; open menu 
Sleep 56
Click
Sleep 358
MouseMove, 1600, 150 ; open bs menu
Sleep 53
Click
Sleep 720
MouseMove, 1720, 540 ; open crystal menu
Sleep 32
Click
Sleep 1308
PixelGetColor,ColorIdle, 905, 469 ; get the idle window color
MouseMove, 1550, 695 ; open auto fusing
Sleep 53
Click
Sleep 360 ; switch to desired grade
if(GemGrade = "Normal") {
 MouseMove, 950, 475
} else if(GemGrade = "Magic") {
 MouseMove, 1080, 475
} else if(GemGrade = "Rare") {
 MouseMove, 1240, 475
} else if(GemGrade = "Unique") {
 MouseMove, 1380, 475
} else if(GemGrade = "Epic") {
 MouseMove, 1520, 475
}
Sleep 150
Click
Sleep 299
MouseMove, 1322, 590 ; confirm fusion
Sleep 52
Click
Sleep 700
Loop {
 PixelGetColor,Color1, 905, 469 ; check px color to see if finished
 Sleep 30
 ToolTip, %Color1%`n%ColorIdle%
 if (Color1 = ColorIdle) { ; if colors match exit menu and release mouse
  MouseMove, 1834, 72
  Sleep 56
  Click
  BlockInput, MouseMoveOff
  break
 } else { ; else check again
  Sleep 500
 }
}
Sleep 1000
botbusy := 0
queue.Remove(1)
if (queue[1]!="") {
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Crystal Fusion Successful. Running %queue%[%1%], %vPath%, UTF-8
gosub % queue[1]
} else {
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Crystal Fusion Successful. Sleeping, %vPath%, UTF-8
}
return


useskillbook:

if (autoon=1) {
 x_ak = %autoskillbookdelay% ; reset progressbox variables
 t_ak := 0
}
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Using Skillbooks, %vPath%, UTF-8
botbusy := 1
BlockInput, MouseMove
gosub activateemulatorwindow
gosub unlockscreen
gosub exitmenus
Sleep 100
MouseMove, 1624, 72 ; open skillbook menu
Sleep 56
Click
Sleep 858
MouseMove, 1725, 695 ; select skillbook usage
Sleep 53
PixelGetColor,Color2Idle, 1662, 688
Click
Sleep 260
text := OCR([1180, 400, 145, 40])
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Total Cost: %text%, %vPath%, UTF-8
MouseMove, 1260, 540 ; confirm
Sleep 52
Click
Sleep 360
Loop {
 PixelGetColor,Color2, 1662, 688
 Sleep 30
 ;ToolTip, %Color2%`n%Color2Idle%
 if (Color2 = Color2Idle) {
  FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Skillbook learning Complete, %vPath%, UTF-8 
  MouseMove, 1834, 72
  Sleep 176
  Click
  BlockInput, MouseMoveOff
  break
 } else {
  Sleep 500
 }
}
Sleep 1000
botbusy := 0
queue.Remove(1)
if (queue[1]!="") {
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Lightstone Fusion Successful. Running %queue%[1], %vPath%, UTF-8
gosub % queue[1]
} else {
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Lightstone Fusion Successful. Sleeping, %vPath%, UTF-8
}
return


greetall:

Random, mod, 15, 30 ; add randomness to the delay
botbusy := 1
BlockInput, MouseMove
gosub activateemulatorwindow
MouseMove, 1825, 70 ; open menu
Sleep 56
Click
Sleep 600 + mod
MouseMove, 1800, 330 ; open social menu
Sleep 53
Click
Sleep 620 + mod
PixelGetColor, Color3, 1700, 700 ; is button active pixel
if (Color3!=0x3C2E28) {
MouseMove, 1700, 700 ; greet all
Sleep 56
Click
Sleep 460 + mod
MouseMove, 1320, 560 ; confirm
Sleep 56
Click
Sleep 460 + mod
}
MouseMove, 1820, 65 ; exit window
Sleep 52
Click
BlockInput, MouseMoveOff
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Greeted All Friends, %vPath%, UTF-8
Sleep 800
botbusy := 0
queue.Remove(1)
queue.Insert("praiseranks")
if (botbusy=0) {
gosub % queue[1]
}
return


getmail:

;FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Getting Mail Rewards, %vPath%, UTF-8
Random, mod, 15, 30 ; add randomness to the delay
botbusy := 1
BlockInput, MouseMove
gosub activateemulatorwindow
MouseMove, 1825, 70 ; open menu
Sleep 56
Click
Sleep 400 + mod
MouseMove, 1710, 660 ; open mail menu
Sleep 53
Click
Sleep 520 + mod
MouseMove, 760, 165 ; open general mail
Sleep 52
Click
Sleep 300 + mod
MouseMove, 1650, 680 ; get mail rewards
Sleep 56
Click
Sleep 220 + mod
MouseMove, 1050, 165 ; open family mail
Sleep 53
Click
Sleep 300 + mod
PixelGetColor, Color, 1320, 560
MouseMove, 1650, 660 ; get mail rewards
Sleep 56
Click
Sleep 460 + mod
PixelGetColor, Color2, 1320, 560
if (Color!=Color2) {
Click, 1320, 550
Sleep 300
}
MouseMove, 1820, 65 ; exit window
Sleep 52
Click
BlockInput, MouseMoveOff
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Acquired Mail Rewards., %vPath%, UTF-8
Sleep 600
botbusy := 0
queue.Remove(1)
if (queue[1]!="") {
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% ||  Running %queue%[1], %vPath%, UTF-8
gosub % queue[1]
} else {
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% ||  Sleeping, %vPath%, UTF-8
}
return


praiseranks:

Random, mod, 15, 30 ; add randomness to the delay
botbusy := 1
BlockInput, MouseMove
gosub activateemulatorwindow
MouseMove, 1825, 70 ; open menu
Sleep 56
Click
Sleep 800+mod
MouseMove, 1620, 440 ; open rank menu
Sleep 53
Click
Sleep 620+mod
MouseMove, 890, 315 ; open rank submenu
Sleep 52
Click
Sleep 800+mod
MouseMove, 840, 700 ; praise
Sleep 56
Click
Sleep 1620+mod
Click
Sleep 500+mod
Click
Sleep 1620+mod
Click
Sleep 500+mod
Click
Sleep 1620+mod
MouseMove, 1820, 65 ; exit window
Sleep 52
Click
BlockInput, MouseMoveOff
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Praised Ranks, %vPath%, UTF-8
Sleep 800
botbusy := 0
queue.Remove(1)
queue.Insert("getpearlshoprewards")
if (botbusy=0) {
gosub % queue[1]
}
return


gogather:

FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Going to harvest, %vPath%, UTF-8
Random, mod, 15, 30 ; add randomness to the delay
botbusy = 1
BlockInput, MouseMove
MouseMove, 1825, 70 ; open menu
Sleep 56
Click
Sleep 500 + mod
MouseMove, 1520, 430 ; open guild menu
Sleep 53
Click
Sleep 720 + mod
MouseMove, 1310, 150 ; open guild quest menu
Sleep 56
Click
Sleep 460 + mod
MouseMove, 1720, 260 ; open life quest menu
Sleep 53
Click
Sleep 420 + mod
MouseMove, 1740, 470 ; pick gathering
Sleep 56
Click
Sleep 460 + mod
MouseMove, 1320, 600 ; confirm
Sleep 56
Click
Sleep 460 + mod
MouseMove, 1815, 73 ; exit menu
Sleep 56
Click
Sleep 660 + mod
MouseMove, 910, 210 ; open waypoint menu
Sleep 40
Click
Sleep 359
MouseMove, 1240, 290 ; go to town
Sleep 30
Click
Sleep 7200
MouseMove, 660, 250 ; pick map mode
Sleep 50
Click
Sleep 359
MouseMove, 620, 205 ; open world map
Sleep 50
Click
Sleep 1239
MouseMove, 1240, 507 ; pick serendia
Sleep 50
Click
Sleep 895
MouseMove, 1170, 625 ; go to kzarka shrine
Sleep 50
Click
Sleep 1100
MouseMove, 1230, 660 ; confirm
Sleep 30
Click
Sleep 9300
MouseMove, 1825, 715 ; get off the horse
Sleep 30
Click
Sleep 1800
MouseMove, 1050, 690 ; open auto menu
Sleep 30
MouseClickDrag, Left, 1050, 690, 1040, 500, 10
;Send {LButton Down}
;Sleep 30
;MouseMove, 1040, 600
;Sleep 30
;Send {LButton Up}
Sleep 800
MouseMove, 1050, 473 ; select auto harvest
Sleep 30
Click
SetTimer, atqgomine, % autogatherduration * -1000 ; start mining, negative to fire once
BlockInput, MouseMoveOff
Sleep 800
botbusy = 0
queue.Remove(1)
if (botbusy=0 && queue[1]!="") {
gosub % queue[1]
}
return


gomine:

if (botbusy = 0) {
botbusy=1
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Switching to mining, %vPath%, UTF-8
Random, mod, 15, 30 ; add randomness to the delay
Sleep 500
BlockInput, MouseMove
gosub exitmenus
MouseMove, 1825, 70 ; open menu
Sleep 56
Click
Sleep 500 + mod
MouseMove, 1520, 430 ; open guild menu
Sleep 53
Click
Sleep 720 + mod
MouseMove, 1310, 150 ; open guild quest menu
Sleep 56
Click
Sleep 460 + mod
MouseMove, 1720, 260 ; open life quest menu
Sleep 53
Click
Sleep 420 + mod
MouseMove, 1750, 470 ; finish harvesting quest
Sleep 56
Click
Sleep 560 + mod
MouseMove, 1750, 630 ; pick mining
Sleep 56
Click
Sleep 460 + mod
MouseMove, 1320, 600 ; confirm
Sleep 56
Click
Sleep 560 + mod
MouseMove, 1815, 73 ; exit menu
Sleep 56
Click
Sleep 760 + mod
MouseMove, 1050, 690 ; open auto menu
Sleep 30
Send {LButton Down}
Sleep 30
MouseMove, 1040, 600
Sleep 30
Send {LButton Up}
Sleep 800
MouseMove, 1050, 540 ; select auto mining
Sleep 30
Click
SetTimer, atqgolog, % automineduration * -1000 ; go log, negative to fire once
BlockInput, MouseMoveOff
} else {
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Subroutine Running, Retry in %retrydelay% ms, %vPath%, UTF-8
SetTimer, atqgomine, % retrydelay
}
botbusy=0
Sleep 800
queue.Remove(1)
if (botbusy=0 && queue[1]!="") {
gosub % queue[1]
}
return


golog:

if (botbusy = 0) {
botbusy=1
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Switching to logging, %vPath%, UTF-8
Random, mod, 15, 30 ; add randomness to the delay
BlockInput, MouseMove
MouseMove, 1825, 70 ; open menu
Sleep 56
Click
Sleep 500 + mod
MouseMove, 1520, 430 ; open guild menu
Sleep 53
Click
Sleep 720 + mod
MouseMove, 1310, 150 ; open guild quest menu
Sleep 56
Click
Sleep 460 + mod
MouseMove, 1720, 260 ; open life quest menu
Sleep 53
Click
Sleep 420 + mod
MouseMove, 1750, 630 ; pick mining
Sleep 56
Click
Sleep 1460 + mod
Click
MouseClickDrag, Left, 1750, 630, 1740, 540 ; drag list
Sleep 400 + mod
MouseMove, 1750, 500 ; pick logging
Sleep 56
Click
Sleep 560 + mod
MouseMove, 1320, 600 ; confirm
Sleep 56
Click
Sleep 460 + mod
MouseMove, 1815, 73 ; exit menu
Sleep 56
Click
Sleep 660 + mod
MouseMove, 1050, 690 ; open auto menu
Sleep 30
Send {LButton Down}
Sleep 30
MouseMove, 1040, 600
Sleep 30
Send {LButton Up}
Sleep 800
MouseMove, 1050, 605 ; select auto logging
Sleep 30
Click
SetTimer, atqcampchores, % autologduration * -1000 ; go to your camp, negative to fire once
} else {
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Subroutine Running, Retry in %retrydelay% ms, %vPath%, UTF-8
SetTimer, atqgolog, % retrydelay
}
botbusy=0
Sleep 800
queue.Remove(1)
if (botbusy=0 && queue[1]!="") {
gosub % queue[1]
}
return

; gathers ore first // mEmu focus for buff // rename seconds to calculating // 

vendor:

gosub pausefightscripts
x_av = %autovendordelay% ; reset progressbox variables
t_av=0
botbusy = 1
BlockInput, MouseMove
gosub activateemulatorwindow
gosub unlockscreen
gosub exitmenus
MouseMove, 1690, 72 ; open inventory to log weight
Sleep 50
Click
Sleep 700
text := OCR([1470, 615, 172, 25])
if (text="") {
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Could not detect carry weight, %vPath%, UTF-8
gosub exitmenus
} else {
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Moving to vendor. Inventory Weight %text%, %vPath%, UTF-8
Sleep 50
MouseMove, 1820, 76 ; close inventory
Sleep 50
Click
Sleep 650
}
MouseMove, 910, 210 ; open waypoint menu
Sleep 40
Click
Sleep 359
PixelGetColor, Color1, 1150, 285
if (Color1=0x28201C) {
 MouseMove, 1240, 290 ; go to town
 Sleep 30
 Click
 gosub detectloadingscreen
} else {
 Click, 720, 106
 Sleep 300
}
MouseMove, 720, 106 ; go to vendor
Sleep 50
Click
Sleep 5259

Loop {
;PixelGetColor, Color, 1662, 481
Screenshot()
if (ok:=FindText(1560, 450, 300, 300, 0.18, 0.18, shopBtn, FindAll:=0)) {   ; color = 0xEDEDED) 
  CoordMode, Mouse
  X:=ok.1.1, Y:=ok.1.2, W:=ok.1.3, H:=ok.1.4, Comment:=ok.1.5, X+=W//2, Y+=H//2
  Click, %X%, %Y%
;MouseMove, 1665, 500 ; open vendor menu
;Sleep 50
;Click
Sleep 739
MouseMove, 1740, 690 ; choose sell junk
Sleep 50
Click
Sleep 295
if (buypots=1) {

MouseMove, 780, 400 ; pick pots
Sleep 50
Click
Sleep 739
MouseMove, 1330, 485 ; +100
Sleep 50
Click
Sleep 295
MouseMove, 1320, 635 ; confirm
Sleep 50
Click
Sleep 439
Click
Sleep 400

}
MouseMove, 1820, 70 ; close menu
Sleep 50
Click
Sleep 500
text := OCR([600, 335, 250, 20])
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || %text%, %vPath%, UTF-8
gosub gofarm
BlockInput, MouseMoveOff
break
} else {
  if (A_Index=1) {
    FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Cannot see vendor. Attempting fix, %vPath%, UTF-8
  } else if (A_Index=100) {
    FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Cannot see vendor after 100 tries, breaking , %vPath%, UTF-8
	Sleep 500
    botbusy=0
    queue.Remove(1)
    if (queue[1]!="") {
     gosub % queue[1]
    }
	break
  }
  MouseMove, 1220, 430
  Sleep 40
  Send {LButton Down}
  Sleep 30
  SendMode, Event
  SetMouseDelay, 2
  MouseMove, 1530, 430, 20
  SetMouseDelay, %mousedelay%
  SendMode, Input
  Sleep 50 
  Send {LButton Up}
  Sleep 500  
}
}
Sleep 300
botbusy := 0
queue.Remove(1)
if (queue[1]!="") {
gosub % queue[1]
}
return


campchores:

if (botbusy=0) {
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Going to camp, %vPath%, UTF-8
Random, mod, 15, 30 ; add randomness to the delay
BlockInput, MouseMove
MouseMove, 1555, 65 ; go to camp
Sleep 56
Click
Sleep 400 + mod
MouseMove, 1320, 560 ; confirm
Sleep 53
Click
Sleep 5220 + mod
MouseMove, 1320, 720 ; open camp content menu
Sleep 56
Click
Sleep 660 + mod
MouseMove, 800, 400 ; get black stones menu
Sleep 53
Click
Sleep 620 + mod
MouseMove, 1640, 680 ; retrieve all
Sleep 56
Click
Sleep 460 + mod
MouseMove, 1810, 97 ; close menu
Sleep 56
Click
Sleep 560 + mod
MouseMove, 1320, 720 ; open camp content menu
Sleep 56
Click
Sleep 660 + mod
MouseMove, 800, 470 ; open camp funds menu
Sleep 56
Click
Sleep 660 + mod
MouseMove, 1600, 670 ; retrieve all
Sleep 56
Click
Sleep 460 + mod
MouseMove, 1810, 97 ; close menu
Sleep 56
Click
Sleep 660 + mod
MouseMove, 1320, 720 ; open camp content menu
Sleep 56
Click
Sleep 660 + mod
MouseMove, 800, 560 ; manage ranch
Sleep 56
Click
Sleep 660 + mod
MouseMove, 1600, 670 ; collect produce
Sleep 56
Click
Sleep 460 + mod
MouseMove, 1810, 97 ; close menu
Sleep 56
Click
Sleep 660 + mod
MouseMove, 1520, 710 ; open workers menu
Sleep 56
Click
Sleep 660 + mod
MouseMove, 890, 690 ; complete worker tasks
Sleep 56
Click
Sleep 460 + mod
MouseMove, 960, 70 ; close menu
Sleep 56
Click
Sleep 560 + mod
MouseMove, 960, 700 ; open gathering tab
Sleep 56
Click
Sleep 660 + mod
MouseMove, 1230, 273 ; open world gathering
Sleep 56
Click
Sleep 760 + mod
MouseMove, 1245, 140 ; open logging menu
Sleep 30
Click
Sleep 630
MouseMove, 1050, 600 ; pick treant forest
Sleep 30
Click
Sleep 600
MouseMove, 1100, 665 ; select all workers
Sleep 30
Click
Sleep 300
MouseMove, 1380, 665 ; confirm
Sleep 30
Click
Sleep 660 + mod
MouseMove, 735, 340 ; choose pale softwood
Sleep 30
Click
Sleep 430
MouseMove, 1050, 600 ; pick treant forest
Sleep 30
Click
Sleep 600
MouseMove, 1100, 665 ; select all workers
Sleep 30
Click
Sleep 400
MouseMove, 1380, 665 ; confirm
Sleep 30
Click
Sleep 400
MouseMove, 1810, 97 ; close menu
Sleep 56
Click
Sleep 660 + mod
MouseMove, 1550, 71 ; exit camp
Sleep 30
Click
Sleep 400
MouseMove, 1320, 565 ; confirm
Sleep 30
Click
BlockInput, MouseMoveOff
Sleep 5400
gosub gofarm
} else {
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Subroutine Running, Retry in %retrydelay% ms, %vPath%, UTF-8
SetTimer, campchores, % retrydelay
}
queue.Remove(1)
if (botbusy=0 && queue[1]!="") {
gosub % queue[1]
}
return


getpearlshoprewards:

Random, mod, 15, 30 ; add randomness to the delay
botbusy=1
BlockInput, MouseMove
MouseMove, 1415, 67 ; open pearl shop
Sleep 56
Click
Sleep 600 + mod
MouseMove, 1820, 180 ; close ad
Sleep 53
Click
Sleep 420 + mod
MouseMove, 1720, 520 ; open add-ons menu
Sleep 56
Click
Sleep 300
text := OCR([820, 308, 60, 21])
if (text="Purchased") {
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Accesory already %text%, %vPath%, UTF-8
} else {
Sleep 2060 + mod
text := OCR([820, 308, 60, 21])
if (text="Free") {
MouseMove, 850, 320 ; get free accessory
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Got free accessory from Pearl Shop, %vPath%, UTF-8
Sleep 53
Click
Sleep 620 + mod
MouseMove, 1320, 640 ; confirm
Sleep 56
Click
Sleep 460 + mod
}
}
MouseMove, 1730, 660 ; open lightstone menu
Sleep 56
Click
Sleep 660 + mod
MouseMove, 790, 490 ; get free lightstone
Sleep 56
Click
Sleep 660 + mod
MouseMove, 1740, 725 ; open relic menu
Sleep 56
Click
Sleep 660 + mod
MouseMove, 790, 490 ; get free relic
Sleep 56
Click
Sleep 660 + mod
MouseMove, 1730, 280 ; open talish's shop
Sleep 56
Click
Sleep 660 + mod
PixelGetColor, Color, 905, 320
if (Color=0xEAD1C0) {
MouseMove, 950, 320 ; buy slot 1 if it costs silver
Sleep 56
Click
Sleep 460 + mod
MouseMove, 1320, 640 ; confirm
Sleep 56
Click
Sleep 460 + mod
}
PixelGetColor, Color, 1475, 320
if (Color=0xEBD1C0) {
MouseMove, 1520, 320 ; buy slot 4 if it costs silver
Sleep 56
Click
Sleep 460 + mod
MouseMove, 1320, 640 ; confirm
Sleep 56
Click
Sleep 460 + mod
}
PixelGetColor, Color, 1475, 557
if (Color=0xEAD0BF) {
MouseMove, 1520, 550 ; buy slot 8 if it costs silver
Sleep 56
Click
Sleep 460 + mod
MouseMove, 1320, 640 ; confirm
Sleep 56
Click
Sleep 560 + mod
}
MouseMove, 1815, 73 ; exit menu
Sleep 56
Click
BlockInput, MouseMoveOff
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Acquired Pearl Shop Daily Rewards, %vPath%, UTF-8
Sleep 800
botbusy=0
queue.Remove(1)
queue.Insert("openinvchests")
if (botbusy=0) {
gosub % queue[1]
}
return


openinvchests:

FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Opening Chests in Inventory, %vPath%, UTF-8
Random, mod, 15, 30 ; add randomness to the delay
botbusy=1
BlockInput, MouseMove
MouseMove, 1695, 67 ; open inventory
Sleep 56
Click
Sleep 600 + mod
MouseMove, 1550, 710 ; open chests in inventory
Sleep 53
Click
Sleep 460 + mod
MouseMove, 1250, 660 ; confirm
Sleep 56
Click
Sleep 460 + mod
MouseMove, 1550, 710 ; open chests in inventory
Sleep 53
Click
Sleep 460 + mod
MouseMove, 1250, 660 ; confirm
Sleep 56
Click
Sleep 460 + mod
MouseMove, 1815, 73 ; exit inventory
Sleep 56
Click
BlockInput, MouseMoveOff
Sleep 800
botbusy=0
queue.Remove(1)
queue.Insert("feedspirit")
queue.Insert("useskillbook")
queue.Insert("miscchores")
if (botbusy=0) {
gosub % queue[1]
}
return


miscchores:

FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Miscelaneous chores, %vPath%, UTF-8
Random, mod, 15, 30 ; add randomness to the delay
botbusy=1
BlockInput, MouseMove
MouseMove, 1825, 70 ; open menu
Sleep 56
Click
Sleep 500 + mod
MouseMove, 1520, 430 ; open guild menu
Sleep 53
Click
Sleep 720 + mod
MouseMove, 720, 680 ; guild check-in
Sleep 56
Click
Sleep 460 + mod
MouseMove, 1815, 73 ; exit and reopen menu
Sleep 56
Click
Sleep 860 + mod
Click
Sleep 660 + mod
MouseMove, 1610, 150 ; open bs menu
Sleep 53
Click
Sleep 620 + mod
MouseMove, 1750, 470 ; open bs quest menu
Sleep 56
Click
Sleep 560 + mod
MouseMove, 1740, 280 ; pick first quest
Sleep 56
Click
Sleep 460 + mod
MouseMove, 1320, 600 ; confirm
Sleep 56
Click
Sleep 460 + mod
MouseMove, 1815, 73 ; exit menu
Sleep 56
Click
BlockInput, MouseMoveOff
Sleep 500
botbusy=0
queue.Remove(1)
queue.Insert("collecttasks")
if (botbusy=0) {
gosub % queue[1]
}
return


collecttasks:

Random, mod, 15, 30 ; add randomness to the delay
botbusy := 1
BlockInput, MouseMove
gosub activateemulatorwindow
MouseMove, 1825, 70 ; open menu
Sleep 56
Click
Sleep 450+mod
MouseMove, 1810, 150 ; open tasks menu
Sleep 53
Click
Sleep 520+mod
MouseMove, 1730, 140 ; collect all rewards
Sleep 56
Click
Sleep 1650+mod
MouseMove, 1730, 140 ; confirm
Sleep 56
Click
Sleep 650+mod
MouseMove, 1730, 140 ; collect all rewards
Sleep 56
Click
Sleep 450+mod
MouseMove, 1820, 68 ; exit window
Sleep 52
Click
BlockInput, MouseMoveOff
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Collected Task Rewards, %vPath%, UTF-8
Sleep 800
botbusy := 0
queue.Remove(1)
queue.Insert("getmail")
if (botbusy=0) {
gosub % queue[1]
}
return

bsmode:

Random, mod, 15, 30 ; add randomness to the delay
BlockInput, MouseMove
gosub activateemulatorwindow
MouseMove, 1825, 70 ; open menu
Sleep 56
Click
Sleep 450+mod
MouseMove, 1650, 725 ; open bs mode menu
Sleep 53
Click
Sleep 520+mod
MouseMove, 890, 330 ; auto fight
Sleep 56
Click
Sleep 450+mod
MouseMove, 1250, 640 ; confirm
Sleep 56
Click
Sleep 650+mod
BlockInput, MouseMoveOff
return


autobsmode:

WinActivate,, %emulator%
MouseMove, 790, 350 ; open game
Sleep 40
Click
Sleep 2359
;MouseMove, 1230, 220
;Sleep 40
;Click
;Sleep 2500
gosub kickreact
gosub vendor
gosub bsmode
;MouseMove, 1250, 600
;Sleep 40
;Click
;Sleep 359
;MouseMove, 1350, 530
;Sleep 40
;Click
;Sleep 1000
return


startautobsmode:

gosub bsmode
SetTimer, autobsmode,  10810000 
x_av = 10810
w_av .= x_av , y_av := SubStr("000" w_av, -3)
Progress, m1 x0 y0 b fs36 fm12 zh10 w300, % tm_av .= x_av, Restarting Black Spirit Mode in:
settimer,avpopup,986
;Sleep 1000
return

startautovendor:

SetTimer, atqvendor, % autovendordelay * 1000 
x_av = %autovendordelay%
;ToolTip, autovendordelay = %xone%
w_av := x_av , y_av := SubStr("000" w_av, -3)
Progress, m1 x0 y0 b fs36 fm12 zh10 w300, % tm_av := x_av, Vendoring in:
settimer,avpopup,986
return

atqvendor:

queue.Insert("vendor")
if (botbusy=0) {
gosub % queue[1]
}
return

atqspirit:

queue.Insert("feedspirit")
if (botbusy=0) {
gosub % queue[1]
}
return

atqpet:

queue.Insert("feedpets")
if (botbusy=0) {
gosub % queue[1]
}
return

atqlightstone:

queue.Insert("fuselightstone")
if (botbusy=0) {
gosub % queue[1]
}
return

atqskillbook:

queue.Insert("useskillbook")
if (botbusy=0) {
gosub % queue[1]
}
return

atqusebuff:

if (buffon=1) {
queue.Insert("usebuff")
if (botbusy=0) {
gosub % queue[1]
}
}
return

atqlookforchest:

if (autolooton>0) {
queue.Insert("lookforchest")
if (botbusy=0) {
gosub % queue[1]
}
}
return

atqgomine:
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Harvesting complete. Switching to mining, %vPath%, UTF-8
queue.Insert("gomine")
if (botbusy=0) {
gosub % queue[1]
}
return

atqgolog:
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Mining complete. Switching to logging, %vPath%, UTF-8
queue.Insert("golog")
if (botbusy=0) {
gosub % queue[1]
} else {
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Cant log bot busy, %vPath%, UTF-8
}
return

atqcampchores:
FileAppend, `n%A_YYYY%.%A_MM%.%A_DD% %A_Hour%:%A_Min%:%A_Sec% || Logging complete. Heading to camp, %vPath%, UTF-8
queue.Insert("campchores")
if (botbusy=0) {
gosub % queue[1]
}
return

startautospirit:

SetTimer, atqspirit, % autospiritdelay * 1000
x_as = %autospiritdelay%
w_as := x_as , y_as := SubStr("000" w_as, -3)
Progress, 2: m1 x0 y110 b fs36 fm12 zh10 w300, % tm_as := x_as, Feeding Black Spirit in:
settimer,aspopup,986
return


startautopet:

SetTimer, atqpet, % autopetdelay * 1000
x_ap = %autopetdelay%
w_ap := x_ap , y_ap := SubStr("000" w_ap, -3)
Progress, 3: m1 x0 y220 b fs36 fm12 zh10 w300, % tm_ap := x_ap, Feeding Pets in:
settimer,appopup,986
return


startautolightstone:

SetTimer, atqlightstone, % autolightstonedelay * 1000
x_al = %autolightstonedelay%
w_al := x_al , y_al := SubStr("000" w_al, -3)
Progress, 4: m1 x0 y330 b fs36 fm12 zh10 w300, % tm_al := x_al, Fusing Lightstone up to %LsGrade% in:
settimer,alpopup,986
return


startautoskillbook:

SetTimer, atqskillbook, % autoskillbookdelay * 1000
x_ak = %autoskillbookdelay%
w_ak := x_ak , y_ak := SubStr("000" w_ak, -3)
Progress, 5: m1 x0 y440 b fs36 fm12 zh10 w300, % tm_ak := x_ak, Learning from Skillbooks in:
settimer,akpopup,986
return


avpopup:
++t_av
;p_av := % 100*(w_av-t_av)/w_av-1
Progress, % 100*(w_av-t_av)/w_av-1, % floor((w_av-t_av)/60) ":" SubStr("00" mod(w_av-t_av,60),-1)
return


aspopup:
++t_as
p_as := 100*(w_as-t_as)/w_as-1
Progress, 2:%p_as%, % floor((w_as-t_as)/60) ":" SubStr("00" mod(w_as-t_as,60),-1)
return


appopup:
++t_ap
p_ap := 100*(w_ap-t_ap)/w_ap-1
Progress, 3:%p_ap%, % floor((w_ap-t_ap)/60) ":" SubStr("00" mod(w_ap-t_ap,60),-1)
return


alpopup:
++t_al
p_al := 100*(w_al-t_al)/w_al-1
Progress, 4:%p_al%, % floor((w_al-t_al)/60) ":" SubStr("00" mod(w_al-t_al,60),-1)
return


akpopup:
++t_ak
p_ak := 100*(w_ak-t_ak)/w_ak-1
Progress, 5:%p_ak%, % floor((w_ak-t_ak)/60) ":" SubStr("00" mod(w_ak-t_ak,60),-1)
return


F7:: 

;ControlSend,, {ctrl down}s{ctrl up}, % "1 - Notepad"
;Sleep 30
Reload

F9::

if (guivis = 1) {
Gui, Hide
Progress, Hide
Progress, 2:Hide
Progress, 3:Hide
Progress, 4:Hide
Progress, 5:Hide
guivis := 0
} else {
Gui, Show
if (autoon=0) {
Progress, m1 x0 y0 b fs18 zh0 w300, Vendor Paused
Progress, 2:On m1 x0 y55 b fs18 zh0 w300, SpiritFeed Paused
Progress, 3:On m1 x0 y110 b fs18 zh0 w300, PetFeed Paused
Progress, 4:On m1 x0 y165 b fs18 zh0 w300, FuseLightstone Paused
Progress, 5:On m1 x0 y220 b fs18 zh0 w300, UseSkillbooks Paused
} else {
Progress, m1 x0 y0 b fs18 zh0 w300, % tm_av .= x_av, Vendoring in:
Progress, 2:On m1 x0 y110 b fs18 zh0 w300, % tm_as .= x_as, Feeding Black Spirit in:
Progress, 3:On m1 x0 y220 b fs18 zh0 w300, % tm_ap .= x_ap, Feeding Pets in:
Progress, 4:On m1 x0 y330 b fs18 zh0 w300, % tm_al .= x_al, Fusing Lightstone up to %LsGrade% in:
Progress, 5:On m1 x0 y440 b fs18 zh0 w300, % tm_ak .= x_ak, Learning from Skillbooks in:
}
guivis := 1
} 
return

F12::
ExitApp
