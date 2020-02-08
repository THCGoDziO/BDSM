# BDSM
Black Desert Semi-Mobile Autohotkey Bot &amp; Scriptset

Collection of pixel detecting/mouse moving scripts written in AutoHotKey used for automation
in the mobile mmo, Black Desert Mobile.

Since its still very early, a lot of quality of life and settings i had planned are not there yet,
but ive done a fair bit of testing and it works most of the time.

Requirements and Instructions:

1. AutoHotKey (www.autohotkey.com)
2. System resolution 1920x1080 (exactly) with system scaling off (100%)
3. Emulator, im using MEmu (www.memuplay.com) but should work with other emulators, 

 3.1 If you have a different one, open BDSM.ahk with a text editor (notepad or preferably notepad++)<br>
 3.2 Press Ctrl+F and search for the line "emulator" and you should find this line<br>
 3.3 emulator:="MEmu" edit it to reflect your emulator window name f.ex: emulator:="Nox" close and save<br>
 3.4 if you run the script and your emulator window does not get moved to the top right corner, ahk might be having<br>
     trouble locating your emulator. You can try right clicking BDSM's tray icon (next to the clock) and opening<br>
     Window Spy. With it open, make your emulator the active window again and take note of the first option above<br>
     ahk_class and go back to step 3.3<br>
 
4. Emulator running in window mode at 1280x720 resolution
5. Run BDSM.ahk
6. Use the GUI on the left to control the bot

 6.1 Buttons Vendor Now, Feed BS Now, Feed Pets Now and Learn Skillbooks Now, are single fire scripts<br>
 6.2 Buttons Fuse Lightstones and Fuse Crystals are also single fire but the grade setting applies to Auto Mode too.<br>
 6.3 Button Go Farm is a single fire that will be removed at some stage as it rarely needs to be forced by the user<br>
     and is a part of other script chains<br>
 6.4 Override dropdown menu is a setting used in select situations when auto path doesnt take the fastest way<br>
     CHOICES:<br>
     6.4.1. NoOverride: the default option, no change to the standard route - if in doubt, always use this<br>
     6.4.2. IronMine: override for Iron Mine Supply Route - takes waypoint first instead of going around<br>
     6.4.3. probably more to come<br>
 6.5 Farming Spot Selection Buttons let you choose which spot out of the three saved locations the bot will return to<br>
 6.6 Buff Casting Button sets up a timer, and casts the Black Spirit buff until clicked again<br>
     6.6.1. The script for this will detect open menus and try to close them every time the buff comes up so preferably<br>
            keep the setting off when you're playing yourself so it doesnt interrupt whatever youre doing<br>
 6.7 Chest Looting Button has two modes, after the first click it will look for chests at all distances, and the second<br>
     click will only look for chests by your feet (for harder areas). Third click will turn the setting off<br>
     6.7.1. This script is not too smart so it will cancel your casts, pickup when surrounded and such as soon as <br>
            a chest is detected. Watch it for a while before deciding to use it for the night.<br>
 6.8 Auto Mode Button is the toggle for AFK Mode, it sets timers for most of the important functions.<br>
     6.8.1. Timers can be personalized in BDSM.ahk, refer to part 3.1 on how to open the file<br>
            Search for the line "; TIMERS (IN SECONDS)" (without quotes). The following 6 variables represent the delay<br>
            for each separate task<br>
     6.8.2. Hot Time Button can be pressed before pressing the Auto Button in order to shorten the delays (or restore <br>
            after the second click). Afaik, Auto Mode has to be turned off while enabling Hot Time for it to take effect<br>
	 6.8.3. Remember to set the preffered lightstone/crystal fusing grade, farming spot and override if needed as Auto<br>
	        Mode uses these values too.<br>
     6.8.4. In the future im planning on easy in-gui customization and an ini file with some settings so it doesnt default<br>
	        every time it is run.<br>
 6.9 Auto Fishing Button is a fully functional fishing bot, it requires you to be by the water when activated.<br>
     6.9.1. For now, start fishing before pressing the button as the script starts with looking for a bite<br>
 6.10 Do Daily Chores Button is a collection of scripts designed to run once a day, aiming to collect all the daily rewards<br>
      and automate some daily busy work.<br>
      6.10.1. Includes: Greeting friends, praising ranks, gathering, guild quests, camp chores collecting pearl shop, mail <br>
              and task rewards<br>
      6.10.2. Planned: Node Manager, smart worker gathering<br>
 6.11 DeadReact when on, looks for the "you are dead" screen and reacts appropriatly<br>
 6.12 KickReact when on, (no way to turn off from the GUI) looks for the login screen in case you get kicked from the server<br>
      6.12.1. I did not have trouble with this function as it works only when emulator is focused but if you want it off,<br>
	      you need to comment out (;put a semicolon at the start) the line "SetTimer, kickreact, 30000" or change the 30000 <br>          to off.<br>
			  
7. Disclaimer: I am providing the scripts with no guarantee of 100% reliability. Because the bot operates on color detection
   it is a bit better than just blindly clicking the screen and a lot safer than precision bots that connect to game addresses,
   but it is still quite early in development, and expect some unexpected behavior at times. As i kept developing and testing the
   bot, it got to a point where i consider it consistent enough for an early release, but if you decide to use it, you do so at 
   your own risk. I will in no way shape or form be responsible for any loss (as unlikely as it is) to any items, currencies and
   such.
            
