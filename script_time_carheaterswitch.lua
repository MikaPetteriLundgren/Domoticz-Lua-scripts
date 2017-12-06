--[[Intention of this script is to turn car heater switch “Ulkokytkin” On before car needs to be used. 
	On time is based on outer temperature and is calculated based on the recommendations found from the Trafi website. 
	It is assumed that car heater is needed only during October – April and if outside temperature is <0DegC. 
	This script also turns Off car heater switch whether it’s activated manually or by the script.
	Setting debug variable true, script prints values that are coming in with device changed table
	Own variable CarHeaterSwitchOffTime (type: Int) is used to store time in system seconds when switch need to be set off
	Own variable CarHeaterSwitchActivationType (type: Int) is used to determine If car heater switch is activated by the script or not. If yes, then value is 1 else 0 (activated manually)
	Own variable CarHeaterSwitchRecurringStartTime (type: Time) is used to store time in 24h format (HH:MM) when car needs to be used i.e. time when leaving from the home. This is a recurring event and takes place everyday.
	Own variable CarHeaterSwitchSingleStartTime (type: Time) is used to store time in 24h format (HH:MM) when car needs to be used i.e. time when leaving from the home. This is a single event and takes place only once within next 24h.
	Own variable CarHeaterSwitchLastRunTime (type: Int) is used to store time when script ran last time (in system seconds)
	Script will run every third minute by default]]

--------------------------------
------ Variables to edit ------
--------------------------------
deviceName = "Ulkokytkin" --Name of the device
switchOffTime = "CarHeaterSwitchOffTime" --Variable which determines when (in system seconds) car heater switch needs to be turned off
switchActivationType = "CarHeaterSwitchActivationType" --Variable which is used to determine has switch been set on manually (0) or automatically (1)
lastRunTimeVariable = "CarHeaterSwitchLastRunTime" --Time in system seconds when script ran last time
wundergroundName = "Säätila - Yleinen" -- Name of Wunderground "device"
switchRecurringStartTime = "CarHeaterSwitchRecurringStartTime" --Stores time in 24h format (HH:MM) when car needs to be used i.e. time when leaving from the home. This is recurring event and takes place everyday.
switchSingleStartTime = "CarHeaterSwitchSingleStartTime" --store time in 24h format (HH:MM) when car needs to be used i.e. time when leaving from the home. This is a single event and takes place only once within next 24h.
tempLimit = 1 --Max temperature when car heater is needed. Default 1 degC.
runInterval = 150 --runInterval variable determines how often this script will run. Default 150s which means the script will run every third minute
switchOnWindow = 5 --switchOnWindow variable determines time "window" in minutes in which switch is turned on. Default value is 5min.
debug = false
--------------------------------
-- End of variables to edit --
--------------------------------

--Variables needed in the first place are initialized
lastRunTime = uservariables[lastRunTimeVariable] --Time in system seconds when script ran last time
time = os.time() --System time in seconds is stored to time variable
commandArray = {}

if (time > lastRunTime + runInterval) then
	print("Car heater switch script running...")
	
	--Function tempFromWunderGround reads Wunderground data, converts it to weather variables and returns temperature
	function tempFromWunderground(station)
		sWeatherTemp, sWeatherHumidity, sWeatherUV, sWeatherPressure, sWeatherUV2 = otherdevices_svalues[station]:match("([^;]+);([^;]+);([^;]+);([^;]+);([^;]+)")
		sWeatherTemp = tonumber(sWeatherTemp);
		sWeatherHumidity = tonumber(sWeatherHumidity);
		sWeatherUV = tonumber(sWeatherUV);
		sWeatherPressure = tonumber(sWeatherPressure);
		sWeatherUV2 = tonumber(sWeatherUV2);
		return sWeatherTemp
	end
	
	--Function currentTimeInMinutes returns current time in minutes
	function currentTimeInMinutes()
		local hour = tonumber(os.date("%H")) --Current hour (0 - 23)
		local minute = tonumber(os.date("%M")) --Current minute (0 - 59)
		return (hour * 60 + minute)
	end
	
	--Function convertTimeToMinutes converts time from HH:MM format to minutes. Converted time in minutes is returned.
	function convertTimeToMinutes(time)
		local hour = tonumber(string.sub(time, 1, 2))
		local minutes = tonumber(string.sub(time, 4, 5))
		return (hour * 60 + minutes)
	end
	
	--Function carHeatingTime returns car heating time in minutes based on outside temperature
	function carHeatingTime()
		local heatingTime
		if (outsideTemperature > 1) then
  			heatingTime = 0 -- Car heating time 0h if outside temperature above 1DegC
		elseif (outsideTemperature <= 1 and outsideTemperature > -5) then
			heatingTime = 30 -- Car heating time 0.5h if outside temperature between 0...-5DegC
		elseif (outsideTemperature <= -5 and outsideTemperature > -10) then
			heatingTime = 60 -- Car heating time 1.0h if outside temperature between -5...-10DegC
		elseif (outsideTemperature <= -10) then
			heatingTime = 120 -- Car heating time 2.0h if outside temperature below -10DegC
		end
		return heatingTime
	end
	
	--Function timeToSeconds converts time from format YYYY-MM-DD HH:MM:SS (Domoticz format) to seconds
	function timeToSeconds(s)
		year = string.sub(s, 1, 4)
		month = string.sub(s, 6, 7)
		day = string.sub(s, 9, 10)
		hour = string.sub(s, 12, 13)
		minutes = string.sub(s, 15, 16)
		seconds = string.sub(s, 18, 19)
		timeInSeconds = os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
		return timeInSeconds
	end
	
	--More variables are initialized
	currentMonth = tonumber(os.date("%m")) --Number of current month (01-12)
	activationType = uservariables[switchActivationType] --Switch been set on manually (0) or automatically (1)
	offTime = uservariables[switchOffTime] --Time in system seconds when car heater switch needs to be turned off
	
	commandArray["Variable:"..lastRunTimeVariable] = tostring(time) --Last run time of the script is updated to CarHeaterSwitchLastRunTime variable
	
	if (debug) then
		print("State of CarHeaterSwitchActivationType variable: "..activationType)
		print("Number of current month: "..currentMonth)
	end
	
	if (otherdevices[deviceName] == "On" or currentMonth < 5 or currentMonth > 9) then --Months when the script is run can be set here. By default the script runs from October to April
	
	outsideTemperature = tempFromWunderground(wundergroundName) --Outside temperature is stored to this variable
	
		if (otherdevices[deviceName] == "On" and time > offTime) then --If switch is On and switch off time has been elapsed then switch is turned off
			commandArray[deviceName] = "Off" --Turn switch Off
			print(deviceName.." switched off")
		elseif (otherdevices[deviceName] == "Off" and outsideTemperature < tempLimit) then
		
			--Rest of the variables are initialized
			currentTime = currentTimeInMinutes() --Current time in minutes is stored to this variable
			carHeatingSwitchOnTime = carHeatingTime() --Car heating time in minutes based on outside temperature is stored to this variable
			recurringStartTime = convertTimeToMinutes(uservariables[switchRecurringStartTime]) --Recurring start time in minutes (time when leaving home) is stored to this variable
			singleStartTime = convertTimeToMinutes(uservariables[switchSingleStartTime]) --Single start time in minutes (time when leaving home) is stored to this variable
			singleStartTimeUpdated = timeToSeconds(uservariables_lastupdate["CarHeaterSwitchSingleStartTime"]) --Time when single start time user variable was last time updated is stored to this variable in seconds
			
			if (debug) then
				print("Outside temperature: "..outsideTemperature)
				print("Car heating time: "..carHeatingSwitchOnTime)
				print("Current time in HH:MM: "..(math.floor(currentTime / 60))..":"..(currentTime % 60))
				print("Current time in minutes: "..currentTime)
				print("Recurring start time in HH:MM (time when leaving home): "..uservariables[switchRecurringStartTime])
				print("Recurring start time in minutes: "..recurringStartTime)
				print("Single start time in HH:MM (time when leaving home): "..uservariables[switchSingleStartTime])
				print("Single start time in minutes: "..singleStartTime)
				print("Single start time user variable was last time updated in YYYY-MM-DD HH:MM:SS format: "..uservariables_lastupdate["CarHeaterSwitchSingleStartTime"])
				print("Single start time user variable was last time updated in seconds: "..singleStartTimeUpdated)
			end
			
			--The switch is turned on if current time is within recurring and/or single start time "window". Note that single start time is valid max. 24h (= 86400 seconds)
			if (((currentTime > recurringStartTime - carHeatingSwitchOnTime) and (currentTime < recurringStartTime - carHeatingSwitchOnTime + switchOnWindow)) or ((currentTime > singleStartTime - carHeatingSwitchOnTime) and (currentTime < singleStartTime - carHeatingSwitchOnTime + switchOnWindow) and (time < singleStartTimeUpdated + 86400))) then
				commandArray["Variable:"..switchActivationType] = tostring(1) ----Switch activation type is set to 1 which means switch has been set on by the script
				commandArray["Variable:"..switchOffTime] = tostring(time + carHeatingSwitchOnTime * 60) --Time when switch need to be set off is updated to switchOffTime variable
				commandArray[deviceName] = "On" --Turn switch On. This needs to be last command in this if statement!!!
				print(deviceName.." switched on")
			end
		end
		
	end
end
	
return commandArray