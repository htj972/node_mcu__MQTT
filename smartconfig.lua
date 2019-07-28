print("SmartConfig START");
gpio.mode(4, gpio.OUTPUT)
gpio.write(4, 1)
-- Set WIFI mode is STATION
wifi.setmode(wifi.STATION)

-- 0 is esptouch, 1 is airkiss
wifi.startsmart(0,function(ssid, password)  
        -- Print log
        print(string.format("Success. SSID:%s ; PASSWORD:%s", ssid, password))
        -- Write wifi ssid and pass to txt
        file.open("wifi.txt", "w+")
        file.write(ssid)
        file.close()

        file.open("pass.txt", "w+")
        file.write(password)
        file.close() 
        
        file.open("sata.txt", "w+")
        file.write("1")
        file.close()       
    end
)

tmr.alarm(0, 1000, 1, function()

if wifi.sta.getip()==nil
then print("testing...")
if gpio.read(4)==1   then gpio.write(4,  gpio.LOW)
else gpio.write(4,gpio.HIGH)end
else
tmr.stop(0)
print("Pass the test")
dofile("normalboot.lua")     
end
end
)        
