--[[Intention of this script is to send notification, SMS and email if fire alarm (“Palohälytin”) goes on.
	If fire alarm device is activated by the security alarm, then fire alarm script doesn’t run.
	Own variable fireAlarmActivationType (type: Int) is used to determine if fire alarm device is activated by the security alarm script or not. If yes, then value is 1 else 0 (real fire alarm)]]

--------------------------------
------ Variables to edit ------
--------------------------------
devicename = "Palohälytin" --Name of the device
alarmActivationType = "fireAlarmActivationType" --Variable which is used to determine has fire alarm been activated by security alarm (1) or by fire alarm (0)
emailAddress1 = "ADD_EMAIL_ADDRESS_HERE" --Email address of 1st recipient
emailAddress2 = "ADD_EMAIL_ADDRESS_HERE" --Email address of 2nd recipient if needed
subject = "Domoticz - Fire alarm" --Subject of the email/SMS/notification
body = "Fire alarm triggered!" --Body text of the email/SMS/notification
debug = false
--------------------------------
-- End of variables to edit --
--------------------------------

commandArray = {}

--Variables are initialized
activationType = uservariables[alarmActivationType] --Fire alarm been activated by security alarm (1) or by fire alarm (0)

if (devicechanged[devicename] and activationType == 0 and devicechanged[devicename] == "Panic") then
	print("Firealarm script running...")
	
	if (debug) then
		print("Following values are coming in with device changed table: ")
		for i, v in pairs(devicechanged) do print(i, v) end
		
		print(activationType)
	end

	commandArray["SendSMS"]=subject
	commandArray[1]={["SendEmail"]=subject.."#"..body.."#"..emailAddress1}
	commandArray[2]={["SendEmail"]=subject.."#"..body.."#"..emailAddress2}
	commandArray["SendNotification"]=subject.."#"..body.."#0"
	
end
	
return commandArray