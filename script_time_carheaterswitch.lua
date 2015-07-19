--[[Intention of this script is to turn car heater switch “Ulkokytkin” On before car needs to be used. 
	On time is based on outer temperature and is calculated based on the recommendations found from the Trafi website. 
	It is assumed that car heater is needed only during October – April and if outside temperature is <0DegC. 
	This script also turns Off car heater switch whether it’s activated manually or by the script.
	Setting debug variable true, script prints values that are coming in with device changed table
	Own variable CarHeaterSwitchOffTime (type: Int) is used to store time in system seconds when switch need to be set off
	Own variable CarHeaterSwitchActivationType (type: Int) is used to determine If car heater switch is activated by the script or not. If yes, then value is 1 else 0 (activated manually)
	Own variable CarHeaterSwitchStartTime (type: Time) is used to store time in 24h format (HH:MM) when car needs to be used i.e. time when leaving from the home
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
switchStartTime = "CarHeaterSwitchStartTime" --Stores time in 24h format (HH:MM) when car needs to be used i.e. time when leaving from the home
tempLimit = 1 --Max temperature when car heater is needed. Default 1 degC.
runInterval = 150 --runInterval variable determines how often this script will run. Default 150s which means the script will run every third minute
switchOnWindow = 10 --switchOnWindow variable determines time "window" in minutes in which switch is turned on. Default value is 10min.
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
		local minute = tonumber(os.date("%M")) --Number of current month (0 - 59)
		return (hour * 60 + minute)
	end
	
	--Function convertTimeToMinutes returns current time in minutes
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
	
	--Rest of the variables are initialized
	currentMonth = tonumber(os.date("%m")) --Number of current month (01-12)
	activationType = uservariables[switchActivationType] --Switch been set on manually (0) or automatically (1)
	offTime = uservariables[switchOffTime] --Time in system seconds when car heater switch needs to be turned off
	
	commandArray["Variable:"..lastRunTimeVariable] = tostring(time) --Last run time of the script is updated to CarHeaterSwitchLastRunTime variable
	
	if (debug) then
		print("State of CarHeaterSwitchActivationType variable: "..activationType)
		print("Number of current month: "..currentMonth)
	end
	
	if (otherdevices[deviceName] == "On" or currentMonth < 5 or currentMonth > 10) then
	
	outsideTemperature = tempFromWunderground(wundergroundName) --Outside temperature is stored to this variable
	
		if (otherdevices[deviceName] == "On" and time > offTime) then --If switch is On and switch off time has been elapsed then switch is turned off
			commandArray[deviceName] = "Off" --Turn switch Off
			print(deviceName.." switched off")
		elseif (otherdevices[deviceName] == "Off" and outsideTemperature < tempLimit) then
		
			currentTime = currentTimeInMinutes() --Current time in minutes is stored to this variable
			carHeatingSwitchOnTime = carHeatingTime() --Car heating time in minutes based on outside temperature is stored to this variable
			startTime = convertTimeToMinutes(uservariables[switchStartTime]) --Start time in minutes (time when leaving home) is stored to this variable
			
			if (debug) then
				print("Outside temperature: "..outsideTemperature)
				print("Car heating time: "..carHeatingSwitchOnTime)
				print("Current time in HH:MM: "..(math.floor(currentTime / 60))..":"..(currentTime % 60))
				print("Current time in minutes: "..currentTime)
				print("Start time in HH:MM (time when leaving home): "..uservariables[switchStartTime])
				print("Start time in minutes: "..startTime)
			end
			
			if ((currentTime > startTime - carHeatingSwitchOnTime) and (currentTime < startTime - carHeatingSwitchOnTime + switchOnWindow)) then
				commandArray["Variable:"..switchActivationType] = tostring(1) ----Switch activation type is set to 1 which means switch has been set on by the script
				commandArray["Variable:"..switchOffTime] = tostring(time + carHeatingSwitchOnTime * 60) --Time when switch need to be set off is updated to switchOffTime variable
				commandArray[deviceName] = "On" --Turn switch On. This needs to be last command in this if statement!!!
				print(deviceName.." switched on")
			end
		end
		
	end
end
	
return commandArray