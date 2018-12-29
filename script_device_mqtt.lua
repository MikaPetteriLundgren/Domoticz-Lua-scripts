--[[
Intention of this script is to publish defined message using MQTT broker running on a localhost.
The script will trigger only when the status of the defined device is changed.
--]]

--------------------------------
------ Variables to edit ------
--------------------------------
devicename = "Hinnerjoki - Sireeni" --Name of the device
deviceIDX = 22
debug = false
--------------------------------
-- End of variables to edit --
--------------------------------

commandArray = {}
 
if (devicechanged[devicename]) then
	print(devicename.." MQTT script running...")
	
	if (devicechanged[devicename] == "On") then
		print(devicename.." turned on!")
		os.execute('mosquitto_pub -h 127.0.0.1 -t domoticz/out -m '..deviceIDX..":1")
	elseif (devicechanged[devicename] == "Off") then
		print(devicename.." turned off!")
		os.execute('mosquitto_pub -h 127.0.0.1 -t domoticz/out -m '..deviceIDX..":0")
	end
end
 
return commandArray