--[[Intention of this script is to arm security system if all mobile devices are out of home (= no one is at home).
The script also disarms the security system, if armed, when at least one of the mobile device is detected.
Device detection is based on Presence detection script which can be found from the Domoticz wiki (https://www.domoticz.com/wiki/Presence_detection).]]

--------------------------------
------ Variables to edit ------
--------------------------------
device1 = "device1" --Name of the mobile device
device2 = "device2" --Name of the mobile device
device3 = "device3" --Name of the mobile device
securitySystem = "Security system" --Name of the security system
debug = false
--------------------------------
-- End of variables to edit --
--------------------------------

commandArray = {}

if (devicechanged[device1] or devicechanged[device2] or devicechanged[device3]) then
	print("Presence detection script running...")
	
	if (debug) then
		print("State of security system:")
		print(globalvariables["Security"])
	end
	
	-- Value of devicechanged table is stored to deviceValue variable
	print("Following values are coming in with device changed table: ")
	deviceValue = ""
	for name, value in pairs(devicechanged) do 
		print(name, value)
		deviceValue = value
	end
	
	if (globalvariables["Security"] == "Disarmed" and otherdevices[device1] == "Off" and otherdevices[device2] == "Off" and otherdevices[device3] == "Off") then --Security system to be armed if it's disarmed and no one is at home
		print("No one is at home, security system to be armed")
		commandArray["Varashälytin"] = "Arm Away" -- Security system armed
		
	elseif (globalvariables["Security"] ~= "Disarmed" and deviceValue == "On") then --Security system to be disarmed if it's armed and someone has come back to home
		print("Someone is at home, security system to be disarmed")
		commandArray["Varashälytin"] = "Disarm" -- Security system disarmed
	end
end
	
return commandArray