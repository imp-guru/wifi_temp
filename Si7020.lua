scl = 6
sda = 7
 
i2c.setup(0, sda, scl, i2c.SLOW)
 
function read_reg(dev_addr, reg_addr,stretch)
  i2c.start(0)
  i2c.address(0, dev_addr ,i2c.TRANSMITTER)
  i2c.write(0,reg_addr)
  --i2c.stop(0)
  i2c.start(0)
  i2c.address(0, dev_addr,i2c.RECEIVER)
  if stretch then
    tmr.delay(50000)
  end
  local r=i2c.read(0,2)
  i2c.stop(0)
  return r
end
 
function getTemp()
    local rh = read_reg(0x40,0xE5,true)
    local t = read_reg(0x40,0xE0,false)
    rh = string.byte(rh,1)*256+string.byte(rh,2)
    t = string.byte(t,1)*256+string.byte(t,2)
    t=(17572*t)/65536-4685
    t=tostring(t*18+32000)
    rh=tostring(rh*12500/65536-600)
    t=t:sub(1,t:len()-3).."."..t:sub(t:len()-2,t:len())
    rh=rh:sub(1,rh:len()-2).."."..rh:sub(rh:len()-1,rh:len())
    print(t.." : "..rh)
    --t = 175.72*t/65536-46.85
    --t = t*9/5+32;
    --rh = 125*rh/65536-6
 
    local conn=net.createConnection(net.TCP, 0) 
    conn:connect(80,'54.86.132.254') 
    conn:send("GET /input/YGbGJKx2yEc9NabyVALK?private_key=RbebrJxlGVT0zZ9ko2GA&temp="..t.."&humidity="..rh.." HTTP/1.1\r\n")
    conn:send("Host: data.sparkfun.com\r\n") 
    conn:send("Accept: */*\r\n") 
    conn:send("\r\n")
 
    conn:on("sent",function(conn)
        print("Closing connection")
        conn:close()
    end)
end
tmr.alarm(1, 5000, 1, function() getTemp() end )
