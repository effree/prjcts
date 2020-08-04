# prjcts

READ ALL INSTRUCTION BELOW

STARTUP:
I recommend adding a shotcut of this script to your startup folder
- Windows Key + R to open the Run Dialog, type "shell:Startup" and place a SHORTCUT to this script here, NOT the original script files

MIC ID: To find your Mic ID it is best to change the mic input level to a random number first, to make it easier to find in the FindMic.ahk script/list
- Go to the Windows 10 search button and type "Sound Settings" and press enter
- On the right side of the window that has now opened click "Sound Control Panel"
- On this new window click on the "Recording" tab
- Click on your mic and click the "Properties" button
- On this new window click on the "Levels" tab and change the level to a unique value and click "Apply" or "OK"
- Now run FindMic.ahk and look for your device using the value you used for input volume
- Take that "mixer" number and put it in place of the number below in the variables section next to "mic_id"
- You can return to the sound settings and put your mic input level back to normal
