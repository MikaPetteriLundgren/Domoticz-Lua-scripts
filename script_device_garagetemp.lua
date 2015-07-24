--[[Scripts receives temperature value from the temp & hum sensor located in the garage
	If received temperature value is lower than preset value (default 3degC), notification and email is sent.
	Interval of sending email notifications is set 24h by default (86400s)
	Setting debug variable true, script prints values that are coming in with device changed table
	Own variable GarageEmailSentSystemTime (type: Int) is used to store time in system seconds when last notification and email was sent
	Own variable GarageTempLimit (type: Int) is used to store temperature limit (min. value)
	Content of the script is executed only if device event came from sensor mentioned in devicename variable]]

--------------------------------
------ Variables to edit ------
--------------------------------
emailinterval = 86400 --Interval of sending email notifications
devicename = "Autotalli" --Name of the device
lastEmailSent = "GarageEmailSentSystemTime" --Name of the own last time email was sent variable
emailAddress = "ADD_EMAIL_ADDRESS_HERE" --Email address of recipient
debug = false
--------------------------------
-- End of variables to edit --
--------------------------------

templimit = uservariables["GarageTempLimit"] --Default temperature limit 3degC
commandArray = {}

if (devicechanged[devicename]) then
	print(devicename.." temperature script running...")
	
	if (debug) then
		print("Following values are coming in with device changed table: ")
		for i, v in pairs(devicechanged) do print(i, v) end
	end
	 
	time = os.time()
	
	if ((devicechanged[devicename.."_Temperature"] < templimit) and (time > uservariables[lastEmailSent] + emailinterval)) then
		bodytext = string.format(devicename.."temperature is too low. Temperature at the moment is %.1fdegC", devicechanged[devicename.."_Temperature"]) --Temperature precision is changed to 1 decimal number
		print(bodytext)
		commandArray["SendEmail"]="Domoticz - "..devicename.."temperature is too low#"..bodytext.."#"..emailAddress
		commandArray['SendNotification']="Domoticz - "..devicename.."temperature is too low#"..bodytext.."#0"
		commandArray["Variable:"..lastEmailSent] = tostring(time) --Last time email was sent is updated to GarageEmailSentSystemTime variable
	elseif ((devicechanged[devicename.."_Temperature"] < templimit) and (time <= uservariables[lastEmailSent] + emailinterval)) then
		print(devicename.."temperature is too low, but it's too early to send new notification/email...")
	end
end
	
return commandArray