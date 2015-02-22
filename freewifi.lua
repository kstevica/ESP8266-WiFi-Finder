--[[
#################################################
# LUA script for ESP8266 using nodemcu firmware #
# Script author: Stevica Kuharski, @kstevica    #
# Date: 2015-02-22                              #
#                                               #
# When in doubt, SYS64738                       #
#################################################

Config part

_DELAY_LIST - delay between two AP lists
_DELAY_BLINK - blink delay if no free AP found
_TIMER_BLINK - id of blink alarm
_TIMER_LIST - id of list alarm
_PIN_LED - LED pin, nodemcu pin 4, ESP8266 pin GPIO2

]]
_DELAY_LIST = 30000
_DELAY_BLINK = 250
_TIMER_BLINK = 0
_TIMER_LIST = 1
_PIN_LED = 4

--[[
Put ESP8266 in STA (client mode)
]]
wifi.setmode(wifi.STATION)

--[[
Prepare pin 4 (GPIO2) for output and turn it off
]]
gpio.mode(_PIN_LED, gpio.OUTPUT)
gpio.write(_PIN_LED, gpio.LOW)

ledState = false

--[[
LED blinking every 500ms
]]
function blinker()
  if (ledState==false) then
    ledState = true
    gpio.write(_PIN_LED, gpio.HIGH)        
  else
    ledState = false
    gpio.write(_PIN_LED, gpio.LOW)
  end
end
tmr.alarm( _TIMER_BLINK, _DELAY_BLINK, 1, blinker )

--[[
Parse AP data and turn on LED if free WiFi found
]]
function listap(t)
  local foundFree = false
  for k,v in pairs(t) do
    isFree = string.sub(v,0,1)
    if (isFree=="0") then
      foundFree = true
    end
  end
  if (foundFree) then    
    tmr.stop(_TIMER_BLINK)
    gpio.write(_PIN_LED, gpio.HIGH)
  else
    tmr.alarm( _TIMER_BLINK, _DELAY_BLINK, 1, blinker )
  end
end

--[[
Method that executes every 30 seconds
]]
function repeatList()
  gpio.write(_PIN_LED, gpio.LOW)        
  ledState = false
  tmr.alarm( _TIMER_BLINK, _DELAY_BLINK, 1, blinker )
  wifi.sta.getap(listap)
end
tmr.alarm(_TIMER_LIST, _DELAY_LIST, 1, repeatList)

--[[
First list so we don't have to wait 30 seconds to execute the timer
]]
wifi.sta.getap(listap)
