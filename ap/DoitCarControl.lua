--DoitCar Ctronl Demo
--ap mode
--Created @ 2015/05/14 by Doit Studio
--Modified: null
--http://www.doit.am/
--http://www.smartarduino.com/
--http://szdoit.taobao.com/
--bbs: bbs.doit.am

--GPIO Define
function initGPIO()
--1,2EN 	D1 GPIO5
--3,4EN 	D2 GPIO4
--1A  ~2A   D3 GPIO0
--3A  ~4A   D4 GPIO2

gpio.mode(0,gpio.OUTPUT);--LED Light on
gpio.write(0,gpio.LOW);

gpio.mode(1,gpio.OUTPUT);gpio.write(1,gpio.LOW);
gpio.mode(2,gpio.OUTPUT);gpio.write(2,gpio.LOW);

gpio.mode(3,gpio.OUTPUT);gpio.write(3,gpio.HIGH);
gpio.mode(4,gpio.OUTPUT);gpio.write(4,gpio.HIGH);

pwm.setup(1,1000,1023);--PWM 1KHz, Duty 1023
pwm.start(1);pwm.setduty(1,0);
pwm.setup(2,1000,1023);
pwm.start(2);pwm.setduty(2,0);
end

function setupAPMode()
print("Ready to start soft ap")
	
cfg={}
cfg.ssid="DoitWiFi";
cfg.pwd="12345678"
wifi.ap.config(cfg)

cfg={}
cfg.ip="192.168.1.1";
cfg.netmask="255.255.255.0";
cfg.gateway="192.168.1.1";
wifi.ap.setip(cfg);
wifi.setmode(wifi.SOFTAP)

str=nil;
ssidTemp=nil;
collectgarbage();

print("Soft AP started")
end

--Set up AP
setupAPMode();

print("Start DoitRobo Control");
initGPIO();

spdTargetA=1023;--target Speed
spdCurrentA=0;--current speed
spdTargetB=1023;--target Speed
spdCurrentB=0;--current speed
stopFlag=true;

--speed control procedure
tmr.alarm(1, 200, 1, function()
	if stopFlag==false then
		spdCurrentA=spdTargetA;
		spdCurrentB=spdTargetB;
		pwm.setduty(1,spdCurrentA);
		pwm.setduty(2,spdCurrentB);
	else
		pwm.setduty(1,0);
		pwm.setduty(2,0);
	end
end)

--Setup tcp server at port 9003
s=net.createServer(net.TCP,60);
s:listen(9003,function(c) 
    c:on("receive",function(c,d) 
      print("TCPSrv:"..d)
      if string.sub(d,1,1)=="0" then --stop
		pwm.setduty(1,0)
		pwm.setduty(2,0)
		stopFlag = true;
        c:send("ok\r\n");
	  elseif string.sub(d,1,1)=="1" then --forward
		gpio.write(3,gpio.HIGH)
		gpio.write(4,gpio.HIGH)
		stopFlag = false;
		c:send("ok\r\n");
	  elseif string.sub(d,1,1)=="2" then --backward
		gpio.write(3,gpio.LOW)
		gpio.write(4,gpio.LOW)
		stopFlag = false;
		c:send("ok\r\n");
	  elseif string.sub(d,1,1)=="3" then --left
		gpio.write(3,gpio.LOW)
		gpio.write(4,gpio.HIGH)
		stopFlag = false;
		c:send("ok\r\n");
	  elseif string.sub(d,1,1)=="4" then --right
		gpio.write(3,gpio.HIGH);
		gpio.write(4,gpio.LOW);
		stopFlag = false;
		c:send("ok\r\n");
	  elseif string.sub(d,1,1)=="6" then --A spdUp
		spdTargetA = spdTargetA+50;if(spdTargetA>1023) then spdTargetA=1023;end
		c:send("ok\r\n");
	  elseif string.sub(d,1,1)=="7" then --A spdDown
		spdTargetA = spdTargetA-50;if(spdTargetA<0) then spdTargetA=0;end
		c:send("ok\r\n");
	  elseif string.sub(d,1,1)=="8" then --B spdUp
		spdTargetB = spdTargetB+50;if(spdTargetB>1023) then spdTargetB=1023;end
		c:send("ok\r\n");
	  elseif string.sub(d,1,1)=="9" then --B spdDown
		spdTargetB = spdTargetB-50;if(spdTargetB<0) then spdTargetB=0;end
		c:send("ok\r\n");		
      else  print("Invalid Command:"..d);c:send("Invalid CMD\r\n");end;
	  collectgarbage();
    end) --end c:on receive

    c:on("disconnection",function(c) 
		print("TCPSrv:Client disconnet");
		collectgarbage();
    end) 
    print("TCPSrv:Client connected")
end)