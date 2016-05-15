--[[Intention of this script is to send SMS, notification and email if fire alarm (“Palohälytin”) goes on.
	If fire alarm device is activated by the security alarm, then fire alarm script doesn’t run.
	The script also loops fire alarm siren if security alarm has been activated as long as defined in "fireAlarmSirenOnTime" variable.
	Own variable fireAlarmActivationType (type: Int) is used to determine if fire alarm device is activated by the security alarm script or not. If yes, then value is 1 else 0 (real fire alarm)
	Own variable securityAlarmActivationTime (type: Int) is used to store time in system seconds when security alarm is activated]]

--------------------------------
------ Variables to edit ------
--------------------------------
devicename = "Palohälytin" --Name of the device
virtualSwitchForFireAlarm = "Palohälyttimen apukytkin" --Name of the virtual switch used to "loop" the fire alarm every fourth second (ie. the switch has On Delay of 4 seconds)
alarmActivationType = "fireAlarmActivationType" --Variable which is used to determine has fire alarm been activated by security alarm (1) or by fire alarm (0)
alarmActivationTime = "securityAlarmActivationTime" --Variable which is used to store time in system seconds when security alarm is activated
emailAddress1 = "ADD_EMAIL_ADDRESS_HERE" --Email address of 1st recipient
emailAddress2 = "ADD_EMAIL_ADDRESS_HERE" --Email address of 2nd recipient if needed
subject = "Domoticz - Fire alarm" --Subject of the email/SMS/notification
body = "Fire alarm triggered!" --Body text of the email/SMS/notification
fireAlarmSirenOnTime = 150 --How long in seconds fire alarm siren should stay on in case of security alarm
debug = false
--------------------------------
-- End of variables to edit --
--------------------------------

commandArray = {}

--Variables are initialized
activationType = uservariables[alarmActivationType] --Has fire alarm been activated by security alarm (1) or by fire alarm (0)
alarmTime = uservariables[alarmActivationTime] --Time in system seconds when alarm system was activated is stored to alarmTime variable
time = os.time() --System time in seconds is stored to time variable

if (devicechanged[devicename] and activationType == 0 and devicechanged[devicename] == "Panic") then
	print("Fire alarm script running...")
	
	if (debug) then
		print("Following values are coming in with device changed table: ")
		for i, v in pairs(devicechanged) do print(i, v) end
		
		print(activationType)
	end
	 
	commandArray["SendSMS"]=subject
	commandArray[1]={["SendEmail"]=subject.."#"..body.."#"..emailAddress1}
	commandArray[2]={["SendEmail"]=subject.."#"..body.."#"..emailAddress2}
	commandArray["SendNotification"]=subject.."#"..body.."#0"

elseif (devicechanged[virtualSwitchForFireAlarm] and devicechanged[virtualSwitchForFireAlarm] == "On" and globalvariables["Security"] ~= "Disarmed" and (time < alarmTime + fireAlarmSirenOnTime)) then
	print("Turning fire alarm siren on again...")
	commandArray[devicename] = "On" --Turn fire alarm siren on again
	commandArray[virtualSwitchForFireAlarm] = "On AFTER 4" --Turn virtual switch for fire alarm siren on after 4 seconds

end
	
return commandArray