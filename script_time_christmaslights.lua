--[[Intention of this script is to turn Christmas lights on and off based on sunrise and sunset. Script will run every third minute and only from November to February.
	Setting debug variable true, script prints debug information to Domoticz's log
	Own variable christmasLightsOnTime (type: Time) is used to store time in 24h format (HH:MM) when Christmas lights need to turned on.
	Own variable christmasLightsOffTime (type: Time) is used to store time in 24h format (HH:MM) when Christmas lights need to turned off.
	Own variable christmasLightsLastRunTime (type: Int) is used to store time when script ran last time (in system seconds)]]

--------------------------------
------ Variables to edit ------
--------------------------------
frontGardenSwitch = "Etupihan valokytkin" --Name of the front garden switch
backGardenSwitch = "Takapihan valokytkin" --Name of the back garden switch
outdoorSwitch = "Ulkokytkin" --Name of the outdoor switch
switchOnTime = "christmasLightsOnTime" --Variable HH:MM format which determines when christmas lights need to be turned On
switchOffTime = "christmasLightsOffTime" --Variable HH:MM format which determines when christmas lights need to be turned Off
lastRunTimeVariable = "christmasLightsLastRunTime" --Time in system seconds when script ran last time
runInterval = 150 --runInterval variable determines how often this script will run. Default 150s which means the script will run every third minute
defaultOnTime = "07:00" --Time when Christmas lights are turned On by default before sunrise
defaultOffTime = "00:00" --Time when Christmas lights are turned Off by default after sunset
switchOnWindow = 5 --switchOnWindow variable determines time "window" in minutes in which switch is turned on. Default value is 5min.
debug = false
--------------------------------
-- End of variables to edit --
--------------------------------

--Variables needed in the first place are initialized
lastRunTime = uservariables[lastRunTimeVariable] --Time in system seconds when script ran last time
time = os.time() --System time in seconds is stored to time variable
currentMonth = tonumber(os.date("%m")) --Number of current month (01-12)
commandArray = {}

if (time > lastRunTime + runInterval and (currentMonth < 3 or currentMonth > 10 or (otherdevices[frontGardenSwitch] == "On" and otherdevices[backGardenSwitch] == "On"))) then
	print("Christmas lights switch script running...")
	
	--Function currentTimeInMinutes returns current time in minutes
	function currentTimeInMinutes()
		local hour = tonumber(os.date("%H")) --Current hour (0 - 23)
		local minute = tonumber(os.date("%M")) --Current minute (0 - 59)
		return (hour * 60 + minute)
	end
	
	--Function convertTimeToMinutes converts time from HH:MM format to minutes. Converted time in minutes is returned.
	function convertTimeToMinutes(timeSeconds)
		local hour = tonumber(string.sub(timeSeconds, 1, 2))
		local minutes = tonumber(string.sub(timeSeconds, 4, 5))
		return (hour * 60 + minutes)
	end
	
	--Function convertMinutesToTime converts time from minutes to HH:MM format. Converted time in HH:MM format is returned.
	function convertMinutesToTime(timeMinutes)
		local hour = math.floor(timeMinutes / 60)
		local minutes = math.floor(timeMinutes % 60)

		if (hour < 10) then
			hour = "0"..hour
		end

		if (minutes < 10) then
			minutes = "0"..minutes
		end
		
		return (hour..":"..minutes)
	end
	
	--More variables are initialized
	sunRise = timeofday['SunriseInMinutes'] --Time of sunrise in minutes
	sunSet = timeofday['SunsetInMinutes'] --Time of sunrise in minutes
	currentTime = currentTimeInMinutes() --Current time in minutes is stored to this variable
	switchOnTimeInMinutes = convertTimeToMinutes(uservariables[switchOnTime]) --Christmas lights On time in minutes
	switchOffTimeInMinutes = convertTimeToMinutes(uservariables[switchOffTime]) --Christmas lights Off time in minutes			
	
	commandArray["Variable:"..lastRunTimeVariable] = tostring(time) --Last run time of the script is updated to CarHeaterSwitchLastRunTime variable
	
	if (debug) then
		print("Current time: "..os.date("%H")..":"..os.date("%M"))
		print("Time when Christmas light need to be turned on: "..uservariables[switchOnTime])
		print("Time when Christmas light need to be turned off: "..uservariables[switchOffTime])
		print("Time of sunrise: "..convertMinutesToTime(sunRise))
		print("Time of sunset: "..convertMinutesToTime(sunSet))
		print("State of "..frontGardenSwitch.." is: "..otherdevices[frontGardenSwitch])
		print("State of "..backGardenSwitch.." is: "..otherdevices[backGardenSwitch])
		print("State of "..outdoorSwitch.." is: "..otherdevices[outdoorSwitch])
	end
	
	if (otherdevices[frontGardenSwitch] == "Off" or otherdevices[backGardenSwitch] == "Off") then --Switches are Off
	
		if ((currentTime > switchOnTimeInMinutes) and (currentTime < switchOnTimeInMinutes + switchOnWindow)) then --The switches are turned on if current time is within switch On time and start time "window". New Christmas light On time is set.
			commandArray[frontGardenSwitch] = "On" --Turn front garden switch On
			commandArray[backGardenSwitch] = "On" --Turn back garden switch On
			commandArray[outdoorSwitch] = "On" --Turn outdoor switch On
			
			if (currentTime <= 720) then --If switches are turned On before noon (720mins = 12:00), sunrise is set as an off time. Otherwise off time is based on defaultOffTime variable
				commandArray["Variable:"..switchOffTime] = convertMinutesToTime(sunRise) --Time when switches need to be turned Off is updated to switchOffTime variable
			else
				commandArray["Variable:"..switchOffTime] = defaultOffTime --Time when switches need to be turned Off is updated to switchOffTime variable
			end
			
			print(frontGardenSwitch.." and "..backGardenSwitch.." and "..outdoorSwitch.." have been switched On")
		end
		
	else --Switches are On
		
		if ((currentTime > switchOffTimeInMinutes) and (currentTime < switchOffTimeInMinutes + switchOnWindow)) then --The switches are turned off if current time is within switch Off time and start time "window". New Christmas light On time is set.
			commandArray[frontGardenSwitch] = "Off" --Turn front garden switch Off
			commandArray[backGardenSwitch] = "Off" --Turn back garden switch Off
			commandArray[outdoorSwitch] = "Off" --Turn outdoor switch Off
			
			if (timeofday['Daytime'] == false) then --If switches are turned Off after sunset, defaultOnTime variable is set as an On time. Otherwise On time is based on sunset.
				commandArray["Variable:"..switchOnTime] = defaultOnTime --Time when switches need to be turned On is updated to switchOnTime variable
			else
				commandArray["Variable:"..switchOnTime] = convertMinutesToTime(sunSet) --Time when switches need to be turned On is updated to switchOnTime variable
			end
			
			print(frontGardenSwitch.." and "..backGardenSwitch.." and "..outdoorSwitch.." have been switched Off")
			
		end
	end
end
	
return commandArray