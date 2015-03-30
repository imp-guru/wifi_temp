red = 5
green = 0

gpio.mode(red,gpio.OUTPUT)
gpio.mode(green,gpio.OUTPUT)
 
gpio.write(red,gpio.LOW)
gpio.write(green,gpio.LOW)

--Load file with list of routers
dofile("ssid_list.lua");
dofile("connectionManager.lua")
scanForKnownAP()
