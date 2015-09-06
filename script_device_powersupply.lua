--[[If mains power supply is turned off or on, email and notification to be sent. 
	Email and notification will be send in every change that occurs in mains power supplies
	Content of the script is executed only if device event came from sensor mentioned in devicename variable]]

--------------------------------
------ Variables to edit ------
--------------------------------
emailinterval = 86400 --Interval of sending email notifications
devicename = "Sähköt" --Name of the device
tempSensorName = "Sisälämpötila" --Name of the temperature sensor
emailAddress = "ADD_EMAIL_ADDRESS_HERE" --Email address of recipient
debug = false
--------------------------------
-- End of variables to edit --
--------------------------------

insideTemperature = otherdevices_temperature[tempSensorName] --Temperature is stored to the variable
commandArray = {}

if (devicechanged[devicename]) then
	print(devicename.." power supply script running...")
	
	if (debug) then
		print("Following values are coming in with device changed table: ")
		for i, v in pairs(devicechanged) do print(i, v) end
		
		print("Inside temperature: "..insideTemperature)
		print("Status of mains power supply: "..devicechanged[devicename])
	end
	 
	if (devicechanged[devicename] == "Off") then
		bodytext = string.format("Power outage detected. Temperature inside of the cottage is now %.1fdegC", insideTemperature)
		print(bodytext)
		commandArray["SendEmail"]="Domoticz - Power outage detected#"..bodytext.."#"..emailAddress
		commandArray['SendNotification']="Domoticz - Power outage detected#"..bodytext.."#0"
	elseif (devicechanged[devicename] == "On") then
		bodytext = string.format("Power outage has ended. Temperature inside of the cottage is now %.1fdegC", insideTemperature)
		print(bodytext)
		commandArray["SendEmail"]="Domoticz - Power outage has ended#"..bodytext.."#"..emailAddress
		commandArray['SendNotification']="Domoticz - Power outage has ended#"..bodytext.."#0"
	end
end
	
return commandArray