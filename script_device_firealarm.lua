--[[Intention of this script is to send notification and email if fire alarm (“Palohälytin”) goes on.
	If fire alarm device is activated by the security alarm, then fire alarm script doesn’t run.
	Own variable fireAlarmActivationType (type: Int) is used to determine if fire alarm device is activated by the security alarm script or not. If yes, then value is 1 else 0 (real fire alarm)]]

--------------------------------
------ Variables to edit ------
--------------------------------
devicename = "Palohälytin" --Name of the device
alarmActivationType = "fireAlarmActivationType" --Variable which is used to determine has fire alarm been activated by security alarm (1) or by fire alarm (0)
emailAddress1 = "EMAIL_ADDRESS1" --Add correct email address
emailAddress2 = "EMAIL_ADDRESS2" --Add 2nd email address if needed
debug = false
--------------------------------
-- End of variables to edit --
--------------------------------

commandArray = {}

--Variables are initialized
activationType = uservariables[alarmActivationType] --Fire alarm been activated by security alarm (1) or by fire alarm (0)

if (devicechanged[devicename] and activationType == 0 and devicechanged[devicename] == "Panic") then
	print("Firealarm script running...")
	
	if (debug) then
		print("Following values are coming in with device changed table: ")
		for i, v in pairs(devicechanged) do print(i, v) end
		
		print(activationType)
	end
	 
	commandArray[1]={["SendEmail"]="Domoticz - Fire alarm#Fire alarm triggered!#"..emailAddress1}
	commandArray[2]={["SendEmail"]="Domoticz - Fire alarm#Fire alarm triggered!#"..emailAddress2}
	commandArray['SendNotification']="Domoticz - Fire alarm#Fire alarm triggered!#0"
	
end
	
return commandArray