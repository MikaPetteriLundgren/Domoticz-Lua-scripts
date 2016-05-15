--[[Intention of this script is to work as a companion script for the ”script_device_securityalarm.lua” script. 
	The script triggers if security device is set to Normal state. Script turns alarm siren and fire alarm off only if there has been a security alarm.
	Script runs every time state of the security device is changed.
	Script also sends notification when security device is armed and disarmed.
	Own variable fireAlarmActivationType (type: Int) is used to determine if fire alarm device is activated by the security alarm script or not. If yes, then value is 1 else 0 (real fire alarm)]]

--------------------------------
------ Variables to edit ------
--------------------------------
alarmActivationType = "fireAlarmActivationType" --Variable which is used to determine has fire alarm been activated by security alarm (1) or by fire alarm (0)
virtualSwitchForFireAlarm = "Palohälyttimen apukytkin" --Name of the virtual switch used to "loop" the fire alarm siren
alarmSiren = "Sireeni" --Name of the alarm siren device
subjectTextArm = "Domoticz - Security alarm has been switched on" --Subject text of the email/SMS/notification in case of arming the system
subjectTextDisarm = "Domoticz - Security alarm has been switched off" --Subject text of the email/SMS/notification in case of disarming the system
bodyTextArm = "Security alarm has been switched on." --Body text of the email/SMS/notification in case of arming the system
bodyTextDisarm = "Security alarm has been switched off." --Body text of the email/SMS/notification in case of disarming the system
ipAddress = "192.168.1.93" --IP address of the Domoticz server
port = "8080" --Port of the Domoticz server
IDX = "34" --IDX value of the alarm siren
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
	
	if (activationType == 1) then
		commandArray[alarmSiren] = "Disarm" --Turn alarm siren off
		commandArray["Variable:"..alarmActivationType] = tostring(0) ----Fire alarm device activation type is set to 0
		commandArray[virtualSwitchForFireAlarm] = "Off" --Turn virtual switch for fire alarm siren off
		commandArray["OpenURL"]="http://"..ipAddress..":"..port.."/json.htm?type=command&param=resetsecuritystatus&idx="..IDX.."&switchcmd=Normal" -- Set fire alarm device back to Normal mode from Panic mode
		print("Siren and fire alarm turned off")
	end
	
	print("Security device disarmed...")
	commandArray['SendNotification']=subjectTextDisarm.."#"..bodyTextDisarm.."#0"
	
elseif (globalvariables["Security"] ~= "Disarmed") then -- If security device is armed, send notification
	print("Security alarm companion script running...")
	
	if (debug) then
		print("Following values are coming in with device changed table: ")
		for i, v in pairs(devicechanged) do print(i, v) end
	end
	 
	print("Security device armed!!!")
	commandArray['SendNotification']=subjectTextArm.."#"..bodyTextArm.."#0"


end
	
return commandArray