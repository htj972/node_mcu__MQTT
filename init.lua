-- 6 is ESP8266 GPIO 12 
gpio.mode(1, gpio.INPUT)

if gpio.read(1) == 0 then

    -- If GPIO 12 is LOW, Go into configuration mode.
    dofile("smartconfig.lua")   
else

    -- Normal boot
    dofile("normalboot.lua")     
end

