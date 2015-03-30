retry = 0
timeout = 7
trial = 0
ssid_list_dirty = false

function scanForKnownAP()
    wifi.setmode(wifi.STATION)
    print("Scanning networks")
    wifi.sta.getap(checkKnownSsidList)
end

function checkKnownSsidList(t)
  local connecting = false
  print("Found Networks: ")
  for k,v in pairs(t) do
    local i=1
    print(k.." : "..v)
    for i=1,table.getn(ssid_list),1 do
        if ssid_list[i][1]==k then
            if ssid_list[i][3]==true then
                if connecting==false then
                    print("Trying to connect to: "..ssid_list[i][1])
                    connecting = true
                    retry = 0
                    trial = i
                    ssid_list[i][3] = false
                    wifi.sta.config(ssid_list[i][1],ssid_list[i][2])
                    wifi.sta.connect()
                end
            end
        end
    end
  end
  if connecting then
      tmr.alarm(1, 1000, 1, 
        function() 
            if wifi.sta.getip()== nil then
                retry = retry+1
                print(retry)
                if retry < timeout then
                    print("IP unavaiable, Waiting...")
                else
                    print("Aborting")
                    saveSsidList()
                    tmr.stop(1)
                    node.restart()
                end
            else 
                tmr.stop(1)
                
                gpio.write(red,gpio.LOW)
                gpio.write(green,gpio.HIGH)

                print("Valid ID: "..trial)
                ssid_list[trial][3]=true
                print("Config done, IP is "..wifi.sta.getip())
                if ssid_list_dirty then
                    saveSsidList()
                end
        
                dofile("Si7020.lua")
            end 
        end
      )
   else
     print("Cannot Join Network, entering soft AP mode...")
     wifi.setmode(wifi.SOFTAP)
     wifi.ap.config({ssid="analog.io Sensor - "..node.chipid()})
     
     gpio.write(red,gpio.HIGH)
     gpio.write(green,gpio.LOW)
     --startServer()
     print("Starting Server")
     
     dofile("server.lua");
   end
end

function saveSsidList()
    local good_list = {}
    local i = 0
    print("Saving SSIDs to file")
    for i=1,table.getn(ssid_list),1 do
        if ssid_list[i][3]==true then
            table.insert(good_list,{ssid_list[i][1],ssid_list[i][2]})
        end
    end
    
    local list_len = table.getn(good_list)
    
    file.remove("ssid_list.lua");
    file.open("ssid_list.lua","w+");
    w = file.writeline
    if list_len>0 then
        w("ssid_list={");
        for i=1,list_len,1 do
            print("Writng "..good_list[i][1].." credentials to file")
            if i<list_len then
                w("{\""..good_list[i][1].."\",\""..good_list[i][2].."\", true},");
            else
                w("{\""..good_list[i][1].."\",\""..good_list[i][2].."\", true}");
            end
        end
        w("}");
    else
        w("ssid_list={}");
    end
    file.close()
    dofile("ssid_list.lua")
end
