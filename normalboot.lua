print("normalboot START");
-- Read Device ID
gpio.mode(4, gpio.OUTPUT)
gpio.mode(6, gpio.OUTPUT)
gpio.write(4, 1)
id = "remote"
getid="gl/get"
setid="gl/set"
effectiveid="liangyang/home/effective"


station_cfg={}
fd = file.open("wifi.txt", "r")
if fd then
    station_cfg.ssid = fd:read()
    print(station_cfg.ssid)
end
fd:close()

fd = file.open("pass.txt", "r")
if fd then
    station_cfg.pwd = fd:read()
    print(station_cfg.pwd)
end
fd:close()

fd = file.open("sata.txt", "r")
if fd then
    sata = fd:read()
    gpio.write(6, sata)
    print("sata:"..sata)
end
fd:close()

-- Connect WIFI

wifi.sta.sethostname(id)
wifi.setmode(wifi.STATION)
wifi.sta.config(station_cfg)
wifi.sta.autoconnect(1)

tmr.alarm(1, 1000, 1, function()
    if wifi.sta.getip()==nil then 
        print("IP unavaiable, Waiting...")
    else
        tmr.stop(1)
        print("IP is "..wifi.sta.getip().. "") 
        init_mqtt() 
    end
end
) 

-- MQTT configure
m = mqtt.Client(""..id.."", 8, "kokirika", "531059223") 
m:lwt(effectiveid, "{\"id\": \""..id.."\",\"sata\": \"offline\"}", 2, 0)


function init_mqtt()
    m:connect("139.224.8.48",1883,0, 
        function(client)
            print("connect success")   
            m:subscribe(setid,1)
            gpio.write(4, 0)               
        end,
        function(client, reason)
            print("connect failed: "..reason)
            init_mqtt()
        end)
end

  
m:on("offline", function(client)  
    -- debug led
    gpio.write(4, 1) 
    -- Rest
    if wifi.sta.getip()==nil 
    then
    wifi.sta.config(station_cfg) 
	tmr.start(1)
	else
    init_mqtt()     end    
end)

m:on("message", function(client, topic, data) 
    if data ~= nil then
        -- exceptional handling
        print(data)
        local c
        local success, c = pcall(jsoncode, data)
        if success then        
            t = cjson.decode(data)   
            
              if t["id"] == ""..id.."" then        
                sata=t["sata"]
                file.open("sata.txt", "w+")
                file.write(sata)
                gpio.write(5, sata)
                file.close() 
              end   
        else
            print("json error")
        end              
    end
end)


tmr.alarm(2, 5000, 1, function()
m:publish(getid,"{\"id\": \""..id.."\",\"sata\": "..sata.."}",2,0)
end
) 

function jsoncode(data)
    return cjson.decode(data)
end
