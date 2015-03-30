ss=net.createServer(net.TCP)
ss:listen(80,function(c)
   c:on("receive",function(c,pl)
      x,ssid_start=string.find(pl,"ssid=",0)
      x,ssid_end=string.find(pl,"&",ssid_start)
      x,pass_start=string.find(pl,"pwd=",ssid_end)
      x,pass_end=string.find(pl,"&",pass_start)
      if pass_end == nil then
        pass_end = string.len(pl)
      else
        pass_end = pass_end-1
      end
      if ssid_start == nil then      
          c:send("HTTP/1.1 200 OK\n\n") 
          c:send("<html><body>") 
          c:send("<h1>Boom Goes the dynomite</h1><BR>")
          c:send("<form action=\"\" method=\"post\">")
          c:send("<input type=\"text\" name=\"ssid\"></input>")
          c:send("<input type=\"password\" name=\"pwd\"></input>")
          c:send("<input type=\"submit\" value=\"Submit\">")
          c:send("</form>")
          c:send("</html></body>") 
          c:send("\nTMR:"..tmr.now().." MEM:"..node.heap())
          c:on("sent",
            function(c) 
                c:close() 
            end
          )
      else
        ssid = string.sub(string.gsub(pl,"+"," "), ssid_start+1, ssid_end-1)
        pass = string.sub(string.gsub(pl,"+"," "), pass_start+1, pass_end)
        ssid_list_dirty = true
        table.insert(ssid_list,{ssid,pass,true})
        ss:close()
        
        scanForKnownAP()
      end
    end)
end)
