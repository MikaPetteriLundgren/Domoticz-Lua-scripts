--[[Scripts receives battery voltage of the sewer sensor. The script also uses water level value of the sewer sensor.
	If received battery voltage value is lower than preset value (SewerSensorBatteryLimit), notification is sent.
	If water level value is lower than preset value (SewerWaterLimit), notification is sent.
	Interval of sending notifications is set 24h by default (86400s)
	Setting debug variable true, script prints values that are coming in with device changed table
	Own variable SewerNotificationSentSystemTime (type: Int) is used to store time in system seconds when last sewer level notification was sent
	Own variable BatteryNotificationSentSystemTime (type: Int) is used to store time in system seconds when last battery voltage notification was sent
	Own variable SewerWaterLimit (type: Int) is used to store minimum water limit of the sewer
	Own variable SewerSensorBatteryLimit (type: Float) is used to store minimum battery voltage of the sewer sensor
	The script is executed only if device event came from sensor mentioned in devicename variable]]

--------------------------------
------ Variables to edit ------
--------------------------------
notificationInterval = 86400 --Interval of sending notifications
devicename = "Teknisen tilan viemärin akku" --Name of the device
waterLevelSensorName = "Teknisen tilan viemäri" --Name of the water level sensor
lastSewerNotificationSent = "SewerNotificationSentSystemTime" --Name of the user variable storing time when last sewer value notification was sent
lastBatteryNotificationSent = "BatteryNotificationSentSystemTime" --Name of the user variable storing time when last battery voltage notification was sent
debug = false
--------------------------------
-- End of variables to edit --
--------------------------------

commandArray = {}

if (devicechanged[devicename]) then
	print(devicename.." sewer script running...")
	
	waterLimit = uservariables["SewerWaterLimit"] --Default temperature limit is 3degC
	batteryLimit = uservariables["SewerSensorBatteryLimit"] --Default temperature limit is 3degC
	batteryVoltage = tonumber(devicechanged[devicename]) -- Battery voltage in volts
	waterValue = tonumber(otherdevices[waterLevelSensorName]) -- Value of water level sensor in percentage
	
	if (debug) then
		print("Following values are coming in with device changed table: ")
		for i, v in pairs(devicechanged) do print(i, v) end
		
		print("Battery voltage is "..batteryVoltage.."V")
		print("Value of water level sensor is "..waterValue.."%")
	
	end
	 
	time = os.time()
	
	if ((batteryVoltage < batteryLimit) and (time > uservariables[lastBatteryNotificationSent] + notificationInterval)) then
		bodytext1 = string.format(devicename.." liian tyhjä. Akun jännite tällä hetkellä "..batteryVoltage.."V")
		print(bodytext1)
		commandArray['SendNotification']="Domoticz - "..devicename.." liian tyhjä#"..bodytext1.."#0"
		commandArray["Variable:"..lastBatteryNotificationSent] = tostring(time) --Last time notification was sent is updated to lastNotificationSent variable
	elseif ((batteryVoltage < batteryLimit) and (time <= uservariables[lastBatteryNotificationSent] + notificationInterval)) then
		print(devicename.." on liian tyhjä, mutta on liian aikaista lähettää uusi muistutusviesti...")
	end
	
	if ((waterValue < waterLimit) and (time > uservariables[lastSewerNotificationSent] + notificationInterval)) then
		bodytext2 = string.format(waterLevelSensorName.." liian tyhjä. Vettä jäljellä viemärissä "..waterValue.."%%")
		print(bodytext2)
		commandArray['SendNotification']="Domoticz - "..waterLevelSensorName.." liian tyhjä#"..bodytext2.."#0"
		commandArray["Variable:"..lastSewerNotificationSent] = tostring(time) --Last time notification was sent is updated to lastNotificationSent variable
	elseif ((waterValue < waterLimit) and (time <= uservariables[lastSewerNotificationSent] + notificationInterval)) then
		print(waterLevelSensorName.." on liian tyhjä, mutta on liian aikaista lähettää uusi muistutusviesti...")
	end
	
end
	
return commandArray