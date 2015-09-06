--[[Intention of this script is to send devicechanges of a pre-defined device to localhost port 5001 if 
	there is any value to publish via MQTT protocol. A node.js script is running on same Raspberry Pi and publishes message via MQTT
	This script is mainly based on a script which was found from Domoticz MQTT wiki entry

 
var url = require("url");
var http = require("http");
var pubclient = new mqtt.MQTTClient(1883, "127.0.0.1", "domoticz");
 
http.createServer(function (req, res) {
	res.writeHead(200, {"Content-Type": "text/plain"});
	res.end("Response from Node.js \n");
	pubclient.publish("/events/domoticz"+url.parse(req.url).pathname, url.parse(req.url).query);	
}).listen(5001, "127.0.0.1");
 
NB. Domoticz will add _ and property to the name of certain sensors (e.g. _temperature, _humidity). This is passed as lowest level of message in mqtt
--]]

--------------------------------
------ Variables to edit ------
--------------------------------
devicename = "Sireeni" --Name of the device
debug = false
--------------------------------
-- End of variables to edit --
--------------------------------

commandArray = {}
 
if (devicechanged[devicename]) then
	print(devicename.." MQTT script running...") 

	--d = otherdevices
	device = ""
	for i, v in pairs(devicechanged) do
	  if (#device == 0 or #i < #device) then device = i end
	  text = v..""
	  if #text > 0 then
		text = string.gsub(i, "_", "/")
		text = "127.0.0.1:5001/"..text.."?"..v
		text = string.gsub(text, "%s+", "%%20")
		commandArray["OpenURL"]=text
		if (debug) then print(text) end
	  end
	end

end
 
return commandArray