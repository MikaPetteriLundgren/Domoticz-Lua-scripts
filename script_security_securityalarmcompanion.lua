--[[Intention of this script is to work as a companion script for the ”script_device_securityalarm.lua” script. 
	The script triggers if security device is set to Normal state. Script turns alarm siren and fire alarm off when triggered.
	Script runs every time state of the security device is changed.
	Script also sends notification when security device is armed and disarmed.
	Own variable fireAlarmActivationType (type: Int) is used to determine if fire alarm device is activated by the security alarm script or not. If yes, then value is 1 else 0 (real fire alarm)]]

--------------------------------
------ Variables to edit ------
--------------------------------
alarmActivationType = "fireAlarmActivationType" --Variable which is used to determine has fire alarm been activated by security alarm (1) or by fire alarm (0)
alarmSiren = "Sireeni" --Name of the alarm siren device
debug = false
--------------------------------
-- End of variables to edit --
--------------------------------

commandArray = {}

if (globalvariables["Security"] == "Disarmed") then -- If security device is disarmed, send notification, set fireAlarmActivationType variable to 0 and turn alarm siren off
	print("Security alarm companion script running...")
	
	--Variables are initialized
	activationType = uservariables[alarmActivationType] --Fire alarm been activated by security alarm (1) or by fire alarm (0)
	
	if (debug) then
		print("Following values are coming in with device changed table: ")
		for i, v in pairs(devicechanged) do print(i, v) end
		
		print(activationType)
	end
	
	commandArray["Variable:"..alarmActivationType] = tostring(0) ----Fire alarm device activation type is set to 0
	commandArray[alarmSiren] = "Disarm" --Turn alarm siren off
	 
	print("Security device disarmed...")
	commandArray['SendNotification']="Domoticz - Security alarm has been switched off#Security alarm has been switched off.#0"
	
elseif (globalvariables["Security"] ~= "Disarmed") then -- If security device is armed, send notification
	print("Security alarm companion script running...")
	
	if (debug) then
		print("Following values are coming in with device changed table: ")
		for i, v in pairs(devicechanged) do print(i, v) end
	end
	 
	print("Security device armed!!!")
	commandArray['SendNotification']="Domoticz - Security alarm has been switched on#Security alarm has been switched on.#0"


end
	
return commandArray