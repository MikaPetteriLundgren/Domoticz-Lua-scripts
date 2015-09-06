--[[Intention of this script is to inform user if no data is received from cottage for a given time period. 
	The user will be informed via email and notification. Script will run every hour.
	Time period is set to 86400s (24h) by default
	Interval of sending email and notifications is set to 24h by default (86400s)
	Own variable connectionLastRunTime (type: Int) is used to store time in system seconds when last notification email was sent
	Own variable connectionEmailSentSystemTime (type: Int) is used to store temperature limit (min. value)
	Own variable connectionTimePeriod (type: Int) is used to store time when script ran last time (in system seconds). Default value is 86400 (24h)]]

--------------------------------
------ Variables to edit ------
--------------------------------
emailInterval = 86400 --Interval of sending email notifications
runInterval = 3600 --runInterval determines how often this script will run. Default 3600s (1h)
amountOfSensors = 3 --This variable is used in for loops
frontDoor = "Etuovi" --Name of the device
sideDoor = "Sivuovi" --Name of the device
thermometer = "Sisälämpötila" --Name of the device
emailAddress = "ADD_EMAIL_ADDRESS_HERE" --Email address of recipient
debug = false
--------------------------------
-- End of variables to edit --
--------------------------------

--Variables needed in the first place are initialized
lastRunTime = uservariables["connectionLastRunTime"] --Time in system seconds when script ran last time
time = os.time() --System time in seconds is stored to time variable
commandArray = {}

--Function timeToSeconds converts time from format YYYY-MM-DD HH:MM:SS (Domoticz format) to seconds
function timeToSeconds (s)
	year = string.sub(s, 1, 4)
	month = string.sub(s, 6, 7)
	day = string.sub(s, 9, 10)
	hour = string.sub(s, 12, 13)
	minutes = string.sub(s, 15, 16)
	seconds = string.sub(s, 18, 19)
	timeInSeconds = os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
	return timeInSeconds
end

if (time > lastRunTime + runInterval) then
	print("Connection script running...")
	
	--Rest of the variables are initialized
	timeArray = {} --Last update times of door sensors are stored to this table
	sortedTimeArray = {} --Sorted version of timeArray table(sorted from max to min value)
	deviceArray = {frontDoor, sideDoor, thermometer} --Device variables are stored to this table
	timePeriod = uservariables["connectionTimePeriod"] --Pre-defined time period
	lastEmailSent = uservariables["connectionEmailSentSystemTime"] --Time in system seconds when last email was sent
	
	--Received last update time per device is converted to seconds and stored to timeArray table
	for i=1,amountOfSensors,1 do
		timeArray[i] = timeToSeconds(otherdevices_lastupdate[deviceArray[i]])
		sortedTimeArray[i] = timeToSeconds(otherdevices_lastupdate[deviceArray[i]])
	end
	
	table.sort(sortedTimeArray, function(a,b) return a>b end) --Sort sortedTimeArray table from max value to min value
	
	commandArray["Variable:HconnectionLastRunTime"] = tostring(time) --Last run time of the script is updated to connectionLastRunTime variable
	
	if (debug) then
		print("Following time stamps are coming in with otherdevices_lastupdate table (sorted from max to min value): ")
		for i=1,amountOfSensors,1 do print(sortedTimeArray[i]) end
	end
	
	if ((time - sortedTimeArray[1] > timePeriod) and (time > lastEmailSent + emailInterval)) then
		bodytext = "Last time data was received "..(os.date("%X %x", sortedTimeArray[1])).."\nIs network connection ok??"
		print(bodytext)
		commandArray["SendEmail"]="Domoticz - Network connection of cottage#"..bodytext.."#"..emailAddress
		commandArray['SendNotification']="Domoticz - Network connection of cottage#"..bodytext.."#0"
		commandArray["Variable:connectionEmailSentSystemTime"] = tostring(time) --Last time email was sent is updated to connectionEmailSentSystemTime variable
	elseif ((time - sortedTimeArray[1] > timePeriod) and (time <= lastEmailSent + emailInterval)) then
		print("Data has not been received from cottage, but it's too early to send new notification/email......")
	end
end
	
return commandArray