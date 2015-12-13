--[[Scripts checks is level of oil tank too low. If the level of the oil tank is lower than a pre-defined 
	limit (OilTankPercentageLimit), email and notification to be sent.
	Interval of sending email notifications is set 48h by default (172800s)
	Setting debug variable true, the script prints values that are coming in with device changed table.
	User variable OilTankEmailSentSystemTime (type: Int) is used to store time in system seconds when last email and notification were sent
	User variable OilTankPercentageLimit (type: Int) is used to store minimum level of the oil tank in percentage.
	User variable OilTankVolume (type: Int) is used to store volume of the oil tank.
	Content of the script is executed only if device event came from sensor mentioned in devicename variable]]

--------------------------------
------ Variables to edit ------
--------------------------------
emailinterval = 172800 --Interval of sending notifications (2 days)
devicename = "Oil tank" --Name of the device
volumeOfOilTank = "OilTankVolume" --Volume of the oil tank
lastEmailSent = "OilTankEmailSentSystemTime" --Last time email and notification were sent
percentageLimitUserVariable = "OilTankPercentageLimit" --Minimum level of the oil tank
emailAddress = "ADD_EMAIL_ADDRESS_HERE" --Email address of recipient
debug = false
--------------------------------
-- End of variables to edit --
--------------------------------

percentageLimit = uservariables[percentageLimitUserVariable] --Minimum level of the oil tank is stored to percentageLimit variable
commandArray = {}

if (devicechanged[devicename]) then
	print(devicename.." script running...")
	
	if (debug) then
		print("Following values are coming in with device changed table: ")
		for i, v in pairs(devicechanged) do print(i, v) end
	end
	 
	time = os.time() --System time in seconds is stored to time variable
	
	if ((devicechanged[devicename.."_Utility"] < percentageLimit) and (time > uservariables[lastEmailSent] + emailinterval)) then
		bodytext = string.format("Level of oil tank is low. Current amount of oil is %.0f litres.", (devicechanged[devicename.."_Utility"] / 100) * uservariables[volumeOfOilTank])
		print(bodytext)
		commandArray["SendEmail"]="Domoticz - warning#"..bodytext.."#"..emailAddress
		commandArray['SendNotification']="Domoticz - warning#"..bodytext.."#0"
		commandArray["Variable:"..lastEmailSent] = tostring(time) --Last time email was sent is updated to OilTankEmailSentSystemTime user variable
	elseif ((devicechanged[devicename.."_Utility"] < percentageLimit) and (time <= uservariables[lastEmailSent] + emailinterval)) then
		print("Level of oil tank is low, but it's too early to send new email and notification...")
	end
end
	
return commandArray