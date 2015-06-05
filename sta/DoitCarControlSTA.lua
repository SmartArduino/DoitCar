--DoitCar Ctronl Demo
--sta mode
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

--Control Program
print("Start DoitRobo Control");
initGPIO();

spdTargetA=1023;--target Speed
spdCurrentA=0;--current speed
spdTargetB=1023;--target Speed
spdCurrentB=0;--current speed
stopFlag=true;

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

local flagClientTcpConnected=false;
print("Start TCP Client");
tmr.alarm(3, 5000, 1, function()
	if flagClientTcpConnected==false then
	print("Try connect Server");
	local conn=net.createConnection(net.TCP, false) 
	conn:connect(6005,"182.92.178.210");
	conn:on("connection",function(c) 
		print("TCPClient:conneted to server");
		flagClientTcpConnected = true;
		end) 
	conn:on("disconnection",function(c) 
		flagClientTcpConnected = false;
		conn=nil;
		collectgarbage();
    end) 
	conn:on("receive", function(conn, m) 
		print("TCPClient:"..m);
		if string.sub(m,1,1)=="b" then
			conn:send("cmd=subscribe&topic=".."car".."\r\n");
		elseif string.sub(m,1,1)=="0" then --stop
			pwm.setduty(1,0)
			pwm.setduty(2,0)
			stopFlag = true;
			conn:send("ok\r\n");
		elseif string.sub(m,1,1)=="1" then --forward
			gpio.write(3,gpio.HIGH)
			gpio.write(4,gpio.HIGH)
			stopFlag = false;
			conn:send("ok\r\n");
		elseif string.sub(m,1,1)=="2" then --backward
			gpio.write(3,gpio.LOW)
			gpio.write(4,gpio.LOW)
			stopFlag = false;
			conn:send("ok\r\n");
		elseif string.sub(m,1,1)=="3" then --left
			gpio.write(3,gpio.LOW)
			gpio.write(4,gpio.HIGH)
			stopFlag = false;
			conn:send("ok\r\n");
		elseif string.sub(m,1,1)=="4" then --right
			gpio.write(3,gpio.HIGH);
			gpio.write(4,gpio.LOW);
			stopFlag = false;
			conn:send("ok\r\n");
		elseif string.sub(m,1,1)=="6" then --A spdUp
			spdTargetA = spdTargetA+50;if(spdTargetA>1023) then spdTargetA=1023;end
			conn:send("ok\r\n");
		elseif string.sub(m,1,1)=="7" then --A spdDown
			spdTargetA = spdTargetA-50;if(spdTargetA<0) then spdTargetA=0;end
			conn:send("ok\r\n");	
		elseif string.sub(m,1,1)=="8" then --B spdUp
			spdTargetB = spdTargetB+50;if(spdTargetB>1023) then spdTargetB=1023;end
			conn:send(spdTargetA.." "..spdTargetB.."\r\n");
		elseif string.sub(m,1,1)=="9" then --B spdDown
			spdTargetB = spdTargetB-50;if(spdTargetB<0) then spdTargetB=0;end
			conn:send(spdTargetA.." "..spdTargetB.."\r\n");
		else  print("Invalid Command:"..m);end;
			collectgarbage();
		end)
	end 
end)

