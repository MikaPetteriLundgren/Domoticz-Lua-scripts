--[[Intention of this script is to work as a companion script for the ”script_time_carheaterswitch.lua” script. 
	The script triggers if “Ulkokytkin” switch is set on manually and calculates time when switch need to be set off. 
	The calculated time is set to user variable CarHeaterSwitchOffTime. Default On time when switch is set On manually is 1.5h.
	If “Ulkokytkin” switch is set to Off then script updates value of user variable “CarHeaterSwitchActivationType” to 0
	Setting debug variable true, script prints values that are coming in with device changed table
	Own variable CarHeaterSwitchOffTime (type: Int) is used to store time in system seconds when switch need to be set off
	Own variable CarHeaterSwitchActivationType (type: Int) is used to determine If car heater switch is activated by the script then value is 1 else 0
	Content of the script is executed only if device event came from device mentioned in devicename variable]]

--------------------------------
------ Variables to edit ------
--------------------------------
devicename = "Ulkokytkin" --Name of the device
switchOffTime = "CarHeaterSwitchOffTime" --Name of the variable which determines when car heater switch needs to be set off
switchActivationType = "CarHeaterSwitchActivationType" --Name of the variable which is used to determine has switch been set on manually (0) or automatically (1)
onTime = 5400 --Default on time for of the switch is 5400s (1.5h)
debug = false
--------------------------------
-- End of variables to edit --
--------------------------------

commandArray = {}

if (devicechanged[devicename]) then
	print("Car heater switch companion script running...")
	
	--Rest of the variables are initialized
	time = os.time()
	activationType = uservariables[switchActivationType]
	
	if (debug) then
		print("Following values are coming in with device changed table:")
		for i, v in pairs(devicechanged) do print(i, v) end
		
		print("State of CarHeaterSwitchActivationType variable:")
		print(activationType)
	end
	
	if (devicechanged[devicename] == "On" and activationType == 0) then
		commandArray["Variable:"..switchOffTime] = tostring(time + onTime) --Time when switch need to be set off is updated to switchOffTime variable
	elseif (devicechanged[devicename] == "Off") then
		commandArray["Variable:"..switchActivationType] = tostring(0) --Switch activation type is set to 0 which means switch has been set on manually
	end
	
end
	
return commandArray