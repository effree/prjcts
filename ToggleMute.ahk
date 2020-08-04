;----------------------------------------------------------------------------------------------------------------------------------------------------------------;
;-------------------------------------------------------------------READ ALL INSTRUCTION BELOW-------------------------------------------------------------------;
;----------------------------------------------------------------------------------------------------------------------------------------------------------------;
;----------------------------------------------------------------------------------------------------------------------------------------------------------------;
;--  STARTUP: I recommend adding a shotcut of this script to your startup folder                                                                               --;
;--           - Windows Key + R to open the Run Dialog, type "shell:Startup" and place a SHORTCUT to this script here, NOT the original script files           --;
;----------------------------------------------------------------------------------------------------------------------------------------------------------------;
;----------------------------------------------------------------------------------------------------------------------------------------------------------------;
;--   MIC ID: To find your Mic ID it is best to change the mic input level to a random number first, to make it easier to find in the FindMic.ahk script/list  --;
;--           - Go to the Windows 10 search button and type "Sound Settings" and press enter                                                                   --;
;--           - On the right side of the window that has now opened click "Sound Control Panel"                                                                --;
;--           - On this new window click on the "Recording" tab                                                                                                --;
;--           - Click on your mic and click the "Properties" button                                                                                            --;
;--           - On this new window click on the "Levels" tab and change the level to a unique value and click "Apply" or "OK"                                  --;
;--           - Now run FindMic.ahk and look for your device using the value you used for input volume                                                         --;
;--           - Take that "mixer" number and put it in place of the number below in the variables section next to "mic_id"                                     --;
;--           - You can return to the sound settings and put your mic input level back to normal                                                               --;
;----------------------------------------------------------------------------------------------------------------------------------------------------------------;


;---------------------------------------------------------------------------VARIABLES----------------------------------------------------------------------------;
;HOTKEY
selectedkey = Home ;choose which key will be used as the mute button (available buttons here: https://www.autohotkey.com/docs/KeyList.htm)

;MIC/MIXER ID
mic_id = 9 ;identification number of microphone

;TOOLTIP
use_tooltip = 1 ;change to 0 to turn off tooltips
use_timer = 0 ;change to 1 to make the tooltip disappear after timer has expired
timer_ms = 2500 ;tooltip time on screen in milliseconds - only works if "use_timer" is set to 1

;ICONS
tray_icon_on = C:\Program Files (x86)\MicMute\muteicon.png ;location of muted icon in task bar
tray_icon_off = C:\Program Files (x86)\MicMute\unmuteicon.png ;location of unmuted icon in task bar

;SOUNDS
use_tone = 1 ;change to 0 to turn off tone that plays when using script
mutesound = C:\Program Files (x86)\MicMute\MuteButton.mp3 ;location of mute sound/tone
;-------------------------------------------------------------------------END-VARIABLES--------------------------------------------------------------------------;

;---FUNCTIONS-TO-LOAD-ON-STARTUP---;
ToolTipFont(Options := "", Name := "", hwnd := "") {
	static hfont := 0
	if (hwnd = "")
		hfont := Options="Default" ? 0 : _TTG("Font", Options, Name), _TTHook()
	else
		DllCall("SendMessage", "ptr", hwnd, "uint", 0x30, "ptr", hfont, "ptr", 0)
}

ToolTipColor(Background := "", Text := "", hwnd := "") {
	static bc := "", tc := ""
	if (hwnd = "") {
		if (Background != "")
			bc := Background="Default" ? "" : _TTG("Color", Background)
		if (Text != "")
			tc := Text="Default" ? "" : _TTG("Color", Text)
			_TTHook()
	}
	else {
		VarSetCapacity(empty, 2, 0)
		DllCall("UxTheme.dll\SetWindowTheme", "ptr", hwnd, "ptr", 0, "ptr", (bc != "" && tc != "") ? &empty : 0)
		if (bc != "")
			DllCall("SendMessage", "ptr", hwnd, "uint", 1043, "ptr", bc, "ptr", 0)
		if (tc != "")
			DllCall("SendMessage", "ptr", hwnd, "uint", 1044, "ptr", tc, "ptr", 0)
	}
}

_TTHook() {
	static hook := 0
	if !hook
		hook := DllCall("SetWindowsHookExW", "int", 4, "ptr", RegisterCallback("_TTWndProc"), "ptr", 0, "uint", DllCall("GetCurrentThreadId"), "ptr")
}

_TTWndProc(nCode, _wp, _lp) {
	Critical 999
	uMsg    := NumGet(_lp+2*A_PtrSize, "uint")
	hwnd    := NumGet(_lp+3*A_PtrSize)
	if (nCode >= 0 && (uMsg = 1081 || uMsg = 1036)) {
		_hack_ = ahk_id %hwnd%
		WinGetClass wclass, %_hack_%
		if (wclass = "tooltips_class32") {
			ToolTipColor(,, hwnd)
			ToolTipFont(,, hwnd)
		}
	}
	return DllCall("CallNextHookEx", "ptr", 0, "int", nCode, "ptr", _wp, "ptr", _lp, "ptr")
}

_TTG(Cmd, Arg1, Arg2 := "") {
	static htext := 0, hgui := 0
	if !htext {
		Gui _TTG: Add, Text, +hwndhtext
		Gui _TTG: +hwndhgui +0x40000000
	}
	Gui _TTG: %Cmd%, %Arg1%, %Arg2%
	if (Cmd = "Font") {
		GuiControl _TTG: Font, %htext%
		SendMessage 0x31, 0, 0,, ahk_id %htext%
		return ErrorLevel
	}
	if (Cmd = "Color") {
		hdc := DllCall("GetDC", "ptr", htext, "ptr")
		SendMessage 0x138, hdc, htext,, ahk_id %hgui%
		clr := DllCall("GetBkColor", "ptr", hdc, "uint")
		DllCall("ReleaseDC", "ptr", htext, "ptr", hdc)
		return clr
	}
}

if(selectedkey = "")
	selectedkey = Home

if(mic_id = "")
	mic_id = 10

if(timer_ms = "")
	timer_ms = 2500

ToolTipFont("s11", "Segoe UI Symbol")

SoundGet, master_mute, , mute, %mic_id%

if(master_mute = "On")
{
	Menu, TRAY, Icon, %tray_icon_on%
	ToolTipColor("1B1B1B", "FF4040")
	master_mute_2 = 
}else{
	Menu, TRAY, Icon, %tray_icon_off%
	ToolTipColor("1B1B1B", "8EF64F")
	master_mute_2 = 
}
if(use_tooltip = 1)
	ToolTip, %s% %master_mute_2% %s%, 150000, -100000

if(use_timer = 1)
	SetTimer, RemoveToolTip, %timer_ms%


;---HOTKEY-PRESSED-COMMAND---;
Hotkey, %selectedkey%, Keydown
Return

Keydown:
	if(use_tone = 1)
		SoundPlay %mutesound%

	SoundSet, +1, MASTER, mute, %mic_id%
	SoundGet, master_mute, , mute, %mic_id%

	if(master_mute = "On")
	{
		Menu, TRAY, Icon, %tray_icon_on%
		ToolTipColor("1B1B1B", "FF4040")
		master_mute_2 = 
	}else{
		Menu, TRAY, Icon, %tray_icon_off%
		ToolTipColor("1B1B1B", "8EF64F")
		master_mute_2 = 
	}

	if(use_tooltip = 1)
		ToolTip, %s% %master_mute_2% %s%, 150000, -100000

	if(use_timer = 1)
		SetTimer, RemoveToolTip, %timer_ms%
return


;---REMOVE-TOOLTIP-WITH-TIMEOUT---;
RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip
return


;---CLICK-TOOLTIP-TO-HIDE---;
~LButton::
	MouseGetPos,,, winID
	if (winID = WinExist("ahk_class tooltips_class32"))
		ToolTip
return