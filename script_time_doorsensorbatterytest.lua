--[[Intention of this script is to inform user that battery of some door sensor could be empty and if RFXcom’s transceiver has crashed
	Scripts runs every hour and checks has Domoticz received data from the door sensor(s) within current time
	+ pre-defined time period. If not, notification email is sent.
	Door sensor time period is set to 1209600s (2 weeks) by default.
	RFXCOM transceiver time period is set to 604800 (1 week) by default
	Interval of sending email notifications is set 24h by default (86400s)
	Own variable DoorSensorEmailSentSystemTime (type: Int) is used to store time in system seconds when last notification email was sent
	Own variable DoorSensorTimePeriod (type: Int) is used to store pre-defined time period for door sensor in seconds
	Own variable RFXCOMTimePeriod (type: Int) is used to store pre-defined time period for RFXCOM's RFXtrx433E USB transceiver in seconds
	Own variable DoorSensorLastRunTime (type: Int) is used to store time when script ran last time (in system seconds)]]

--------------------------------
------ Variables to edit ------
--------------------------------
emailInterval = 86400 --Interval of sending email notifications
runInterval = 3600 --runInterval variable determines how often this script will run. Default 3600s (1h)
amountOfDoorSensors = 5 --This variable is used in for loops
securityDevice = "Varashälytin" --Name of the security device
frontDoor = "Etuovi" --Name of the device
backDoor = "Takaovi" --Name of the device
sideDoor = "Sivuovi" --Name of the device
garageDoor = "Autotallin ovi" --Name of the device
warehouseDoor = "Varaston ovi" --Name of the device
emailAddress = "ADD_EMAIL_ADDRESS_HERE" --Email address of recipient
subject = "Domoticz - Door switch may have a low battery level" --Subject of the email/SMS/notification
body = " switch may have a low battery level. Check battery!\n" --Body text of the email/SMS/notification. Name of the door(s) which battery level may be too low will be added at the beginning of body text by the script.
RFXCOMtext = "RFXcom transceiver has crashed" --Body text of RFXcom crash
debug = false
--------------------------------
-- End of variables to edit --
--------------------------------

--Variables needed in the first place are initialized
lastRunTime = uservariables["DoorSensorLastRunTime"] --Time in system seconds when script ran last time
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
	print(" Door sensor battery test script running...")
	
	--Rest of the variables are initialized
	timeArray = {} --Last update times of door sensors are stored to this table
	sortedTimeArray = {} --Sorted version of timeArray table(sorted from min value to max value)
	deviceArray = {frontDoor, backDoor, sideDoor, garageDoor, warehouseDoor} --Device variables are stored to this table
	timePeriod = uservariables["DoorSensorTimePeriod"] --Pre-defined time period for door sensor
	timePeriodRFXCOM = uservariables["RFXCOMTimePeriod"] --Pre-defined time period for RFXCOM's RFXtrx433E USB transceiver
	lastEmailSent = uservariables["DoorSensorEmailSentSystemTime"] --Time in system seconds when last email was sent
	securityLastUpdate = timeToSeconds(otherdevices_lastupdate[securityDevice]) --Time in system seconds when security alarm device has been seen last time
	
	--Received last update time per device is converted to seconds and stored to timeArray table
	for i=1,amountOfDoorSensors,1 do
		timeArray[i] = timeToSeconds(otherdevices_lastupdate[deviceArray[i]])
		sortedTimeArray[i] = timeToSeconds(otherdevices_lastupdate[deviceArray[i]])
	end
	
	table.sort(sortedTimeArray) --Sort sortedTimeArray table from min value to max value
	
	commandArray["Variable:DoorSensorLastRunTime"] = tostring(time) --Last run time of the script is updated to DoorSensorLastRunTime variable
	
	if (debug) then
		print("Current time in system seconds is "..time)
		print("Following time stamps are coming in with otherdevices_lastupdate table (sorted from min value to max value): ")
		for i=1,amountOfDoorSensors,1 do print(sortedTimeArray[i]) end
		print("Time stamp from security device: "..securityLastUpdate)
	end
	
	if ((time - sortedTimeArray[1] > timePeriod) and (time > lastEmailSent + emailInterval)) then
		bodytext = ""
		for i=1,amountOfDoorSensors,1 do
			if (time - timeArray[i] > timePeriod) then
				bodytext = bodytext..deviceArray[i]..body --Final body text is concatenated from name of the door(s) which battery level may be too low and content of body variable
			end
		end
		print(bodytext)
		commandArray["SendEmail"]=subject.."#"..bodytext.."#"..emailAddress
		commandArray["Variable:DoorSensorEmailSentSystemTime"] = tostring(time) --Last time email was sent is updated to DoorSensorEmailSentSystemTime variable
	elseif ((time - sortedTimeArray[1] > timePeriod) and (time <= lastEmailSent + emailInterval)) then
		print("Door switch may have a low battery level, but it's too early to send new notification/email...")
	end
	
	if ((time - sortedTimeArray[amountOfDoorSensors] > timePeriodRFXCOM) and (time - securityLastUpdate > timePeriodRFXCOM) and (time > lastEmailSent + emailInterval)) then
		commandArray["SendEmail"]="Domoticz - "..RFXCOMtext.."#"..RFXCOMtext.."#"..emailAddress
		commandArray["Variable:DoorSensorEmailSentSystemTime"] = tostring(time) --Last time email was sent is updated to DoorSensorEmailSentSystemTime variable
		print("RFXcom transceiver has crashed")
	elseif	((time - sortedTimeArray[amountOfDoorSensors] > timePeriodRFXCOM) and (time - securityLastUpdate > timePeriodRFXCOM) and (time <= lastEmailSent + emailInterval)) then
		print("RFXCOM transceiver has crashed, but it's too early to send new notification/email...")	
	end
	
end
	
return commandArray