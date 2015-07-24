--[[Scripts runs every minute and checks if garage door has been open over pre-defined time limit when outside temperature 
	is lower than pre-defined limit. If true, notification and email is sent.
	Max garage door open time is set to 300s (5min) by default
	Outside temperature limit is set to 5degC by default
	Email and notification to be sent only once
	Own variable GaragedoorNotifierLastUpdateTime (type: Int) stores last update time of the door (system seconds). This is used to take care that email and notification are sent only once.
	Own variable GarageDoorOpenTime (type: Int) is used to store max open time of garage door (in seconds)
	Own variable GarageDoorOutsideTempLimit (type: Int) is used to store outside temperature limit (DegC)]]

--------------------------------
------ Variables to edit ------
--------------------------------
door = "Autotallin ovi" -- Name of the door
wundergroundName = "Säätila - Yleinen" -- Name of Wunderground "device"
emailAddress = "ADD_EMAIL_ADDRESS_HERE" --Email address of recipient
subject = "Domoticz - Garage door has left open" --Subject of the email/SMS/notification
body = "Garage door has left open. Outside temperature at the moment is " --Body text of the email/SMS/notification. Current temperature and degC will be added at the end of body text by the script.
debug = false
--------------------------------
-- End of variables to edit --
--------------------------------

--Variables needed in the first place are initialized
doorStatus = otherdevices[door]
commandArray = {}

--Debug feature to print out interesting information about the script
if (debug) then
	print("State of garage door: "..doorStatus)
end

if (doorStatus == "Open") then
	print("Garage door notifier script running...")
	
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
	
	--Rest of the variables are initialized
	time = os.time() --System time in seconds is stored to time variable
	lastUpdateTime = uservariables["GaragedoorNotifierLastUpdateTime"] --Last actual update time of the door (system seconds)
	tempLimit = uservariables["GarageDoorOutsideTempLimit"] --Default temperature limit 5DegC
	timeLimit = uservariables["GarageDoorOpenTime"] --Max open time for the door
	doorLastUpdate = timeToSeconds(otherdevices_lastupdate[door]) --Last update time from the door in seconds
	outsideTemperature = tempFromWunderground(wundergroundName) --Outside temperature is stored to this variable
	
	--Debug feature to print out interesting information about the script
	if (debug) then
		print("Outside temperature limit is: "..tempLimit)
		print("Max door open time limit: "..timeLimit)
		print("System time: "..time)
		print("Last update from the door: "..doorLastUpdate)
		print("Outside temperature: "..outsideTemperature)
	end
	
	if ((time - doorLastUpdate > timeLimit) and (outsideTemperature < tempLimit) and (doorLastUpdate > lastUpdateTime)) then
		bodytext = body..outsideTemperature.."degC" --Final body text is concatenated from body, current temperature and degC texts
		print(bodytext)
		commandArray["SendEmail"]=subject.."#"..bodytext.."#"..emailAddress
		commandArray['SendNotification']=subject.."#"..bodytext.."#0"
		commandArray["Variable:GaragedoorNotifierLastUpdateTime"] = tostring(doorLastUpdate) --Last actual update time is updated to GaragedoorNotifierLastUpdateTime variable
	elseif ((time - doorLastUpdate > timeLimit) and (outsideTemperature < tempLimit)) then
		print("Garage door has left open, but email/notification is already sent...")
	end
end
	
return commandArray