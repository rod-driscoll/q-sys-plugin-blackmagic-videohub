
local helper = require('helpers')

-- Control aliases
Status = Controls.Status

local SimulateFeedback = true
-- Variables and flags
DebugTx=false
DebugRx=false
DebugFunction=false
DebugPrint=Properties["Debug Print"].Value	

-- Timers, tables, and constants
StatusState = { OK = 0, COMPROMISED = 1, FAULT = 2, NOTPRESENT = 3, MISSING = 4, INITIALIZING = 5 }
Heartbeat = Timer.New()
VolumeDebounce = Timer.New()
PollRate = Properties["Poll Interval"].Value
Timeout = PollRate + 10
BufferLength = 1024
ConnectionType = Properties["Connection Type"].Value
DataBuffer = ""
CommandQueue = {}
CommandProcessing = false
--Internal command timeout
CommandTimeout = 5
CommunicationTimer = Timer.New()
TimeoutCount = 0

--Hide controls that are just for pins
--Controls["ModelNumber"].IsInvisible=true
--Controls["PanelType"].IsInvisible=true

	local Request = {
		--Status		={Command="",				Data=""},
		--Login			={Command="LOGIN",	Data=""},
		--Logout		={Command="LOGOUT",	Data=""},
		OutputLock={Command="VIDEO OUTPUT LOCKS"  , 	Data=""},
		Route			={Command="VIDEO OUTPUT ROUTING", 	Data=""},
}
-- Query routes: 'VIDEO OUTPUT ROUTING: \x0a\x0a'
-- Set route:    'VIDEO OUTPUT ROUTING:\x0a10 2\x0a\x0a'

-- Helper functions
-- A function to determine common print statement scenarios for troubleshooting
function SetupDebugPrint()
	if DebugPrint=="Tx/Rx" then
		DebugTx,DebugRx=true,true
	elseif DebugPrint=="Tx" then
		DebugTx=true
	elseif DebugPrint=="Rx" then
		DebugRx=true
	elseif DebugPrint=="Function Calls" then
		DebugFunction=true
	elseif DebugPrint=="All" then
		DebugTx,DebugRx,DebugFunction=true,true,true
	end
end

-- A function to clear controls/flags/variables and clears tables
function ClearVariables()
	if DebugFunction then print("ClearVariables() Called") end
	Controls["DeviceFirmware"].String = ""
	Controls["ModelName"].String = ""
	Controls["DeviceName"].String = ""
	DataBuffer = ""
	CommandQueue = {}
end

--Reset any of the "Unavailable" data;  Will cause a momentary colision that will resolve itself the customer names the device "Unavailable"
function ClearUnavailableData()
	if DebugFunction then print("ClearUnavailableData() Called") end
	-- If data was unavailable reset it; the next poll loop will test for it again
	for i,ctrl in ipairs({ "DeviceFirmware", "ModelName" }) do
		if(Controls[ctrl].String == "Unavailable")then
			Controls[ctrl].String = ""
		end
	end
end

-- Update the Status control
function ReportStatus(state,msg)
	if DebugFunction then print("ReportStatus() Called: "..state..". "..msg) end
	local msg=msg or ""
	Status.Value=StatusState[state]
	Status.String=msg
end


function Split(s, delimiter)
	if DebugFunction then print("Split() Called") end
	local result = {};
	for match in (s..delimiter):gmatch("(.-)"..delimiter) do
		table.insert(result, match);
	end
	return result;
end

--Parse a string from byte array
function ParseString(data)
	if DebugFunction then print("ParseString() Called") end
	local name = ""
	for i,byte in ipairs(data) do
		name = name .. string.char(byte)
	end
	return name
end

function GetPrintableHexString(str)
	local result_ = ""
	for i=1, #str do
		local c = str:sub(i,i)
		if c:byte() > 0x1F and c:byte() < 0x7F then
			result_ = result_..c
		else
			result_ = result_..string.format("\\x%02X", c:byte())
		end
	end
	return result_  
end

--A debounce timer on power up avoids reporting the TCP reset that occurs as ane error
function ClearDebounce()
	PowerOnDebounce = false
end
-------------------------------------------------------------------------------
-- Device functions
-------------------------------------------------------------------------------

--[[  Communication format
	All commands are  of the format:
	CommandName   Constant   Parameters   Suffix
	<Command>     ':\x0a'    <Data>      '\x0a\x0a'

  e.g. 'VIDEO OUTPUT ROUTING:\x0a10 2\x0a\x0a'

	Both Serial and TCP mode must contain functions:
	Connect()
	And a receive handler that passes data to ParseData()
]]

-- Take a request object and queue it for sending.  Object format is of:
--  { Command=string, Data={string} }
function Send(cmd, sendImmediately)
	value = string.format("%s:\x0a%s\x0a\x0a",cmd.Command, cmd.Data)
	if DebugFunction then print("DoSend("..value..") Called") end

	--Check for if a command is already queued
	for i, val in ipairs(CommandQueue) do
		if(val == value)then
			--Some Commands should be sent immediately
			if sendImmediately then
				--remove other copies of a command and move to head of the queue
				table.remove(CommandQueue,i)
				if DebugTx then print("Sending: "..GetPrintableHexString(value)) end
				table.insert(CommandQueue,1,value)
			end
			return
		end
	end
	--Queue the command if it wasn't found
	table.insert(CommandQueue,value)
	SendNextCommand()
end

--Timeout functionality
-- Close the current and start a new connection with the next command
-- This was included due to behaviour within the Comms Serial; may be redundant check on TCP mode
CommunicationTimer.EventHandler = function()
	if DebugFunction then print("CommunicationTimer Event (timeout) Called") end
	ReportStatus("MISSING","Communication Timeout")
	CommunicationTimer:Stop()
	CommandProcessing = false
	SendNextCommand()
end 

	--  Serial mode Command function  --
if ConnectionType == "Serial" then
	print("Serial Mode Initializing...")
	-- Create Serial Connection
	Comms = SerialPorts[1]
	Baudrate, DataBits, Parity = 9600, 8, "N"

	--Send the display the next command off the top of the queue
	function SendNextCommand()
	if DebugFunction then print("SendNextCommand("..CommandProcessing..") Called") end
	if CommandProcessing then
		-- Do Nothing
	elseif #CommandQueue > 0 then
		CommandProcessing = true
		if DebugTx then print("Sending: "..GetPrintableHexString(CommandQueue[1])) end
		Comms:Write( table.remove(CommandQueue,1) )
		CommunicationTimer:Start(CommandTimeout)
	else
		CommunicationTimer:Stop()
	end
	end

	function Disconnected()
		if DebugFunction then print("Disconnected() Called") end
		CommunicationTimer:Stop() 
		CommandQueue = {}
		Heartbeat:Stop()
	end
	
		-- Clear old and open the socket, sending the next queued command
	function Connect()
		if DebugFunction then print("Connect() Called") end
		Comms:Close()
		Comms:Open(Baudrate, DataBits, Parity)
	end

	-- Handle events from the serial port
	Comms.Connected = function(serialTable)
		if DebugFunction then print("Connected handler called Called") end
		ReportStatus("OK","")
		Connected()
	end
	
	Comms.Reconnect = function(serialTable)
		if DebugFunction then print("Reconnect handler called Called") end
		Connected()
	end
	
	Comms.Data = function(serialTable, data)
		ReportStatus("OK","")
		CommunicationTimer:Stop() 
		CommandProcessing = false
		local msg = DataBuffer .. Comms:Read(1024)
		DataBuffer = "" 
		if DebugRx then 
			if msg:len() < 50 then
				print("Received["..#msg.."]: "..GetPrintableHexString(msg))
			else
				print("Received["..#msg.."]: "..msg:sub(1,50))
			end 
		end
		ParseResponse(msg)
		SendNextCommand()
	end
	
	Comms.Closed = function(serialTable)
		if DebugFunction then print("Closed handler called Called") end
		Disconnected()
		ReportStatus("MISSING","Connection closed")
	end
	
	Comms.Error = function(serialTable, error)
		if DebugFunction then print("Socket Error handler called Called") end
		Disconnected()
		ReportStatus("MISSING",error)
	end
	
	Comms.Timeout = function(serialTable, error)
		if DebugFunction then print("Socket Timeout handler called Called") end
		Disconnected()
		ReportStatus("MISSING","Serial Timeout")
	end

	--[[
	Controls["Reset"].EventHandler = function()
		if DebugFunction then print("Reset handler called Called") end
		PowerupTimer:Stop()
		ClearVariables()
		Disconnected()
		Connect()
	end
	]]
	
	--  Ethernet Command Function  --
else
	print("TCP Mode Initializing...")
	--IPAddress = Controls.IPAddress
	--Port = Controls.Port
	-- Create Sockets
	Comms = TcpSocket.New()
	Comms.ReconnectTimeout = 5
	Comms.ReadTimeout = 10  --Tested to verify 6 seconds necessary for input switches;  Appears some TV behave mroe slowly
	Comms.WriteTimeout = 10

	--Send the display the next command off the top of the queue
	function SendNextCommand()
		if DebugFunction then print("SendNextCommand() Called") end
		if CommandProcessing then
		-- Do Nothing
		elseif #CommandQueue > 0 then
			if not Comms.IsConnected then
				Connect()
			else
				CommandProcessing = true
				if DebugTx then print("Sending: "..GetPrintableHexString(CommandQueue[1])) end
				Comms:Write( table.remove(CommandQueue,1) )
			end
		end
	end
	
	function Disconnected()
		if DebugFunction then print("Disconnected() Called") end
		if Comms.IsConnected then
			Comms:Disconnect()
		end
		CommandQueue = {}
		Heartbeat:Stop()
	end
	
	-- Clear old and open the socket
	function Connect()
		if DebugFunction then print("Connect() Called") end
		if Controls.IPAddress.String ~= "Enter an IP Address" and Controls.IPAddress.String ~= "" then
			if Comms.IsConnected then
				Comms:Disconnect()
			end
			Comms:Connect(Controls.IPAddress.String, Controls.TcpPort.Value)
		else
			ReportStatus("MISSING","No IP Address or Port")
		end
	end
		
	-- Handle events from the socket;  Nearly identical to Serial
	Comms.EventHandler = function(sock, evt, err)
		if DebugFunction then print("Ethernet Socket EventHandler: "..tostring(evt)) end

		if evt == TcpSocket.Events.Connected then
			if DebugRx then print("Connected "..tostring(evt)) end
			ReportStatus("OK","")
			Connected()
		elseif evt == TcpSocket.Events.Reconnect then
		--Disconnected()
	
		elseif evt == TcpSocket.Events.Data then
			ReportStatus("OK","")
			CommandProcessing = false
			TimeoutCount = 0
			local line = sock:Read(BufferLength)
			local msg = DataBuffer
			DataBuffer = "" 
			while (line ~= nil) do
				msg = msg..line
				line = sock:Read(BufferLength)
			end 
			if DebugRx then 
				if msg:len() < 50 then
					print("Received["..#msg.."]: "..GetPrintableHexString(msg))
				else
					print("Received["..#msg.."]: "..msg:sub(1,50))
				end 
			end
			ParseResponse(msg)  
			SendNextCommand()
		
		elseif evt == TcpSocket.Events.Closed then
			if DebugRx then print("Disconnected "..tostring(evt)) end
			Disconnected()
			ReportStatus("MISSING","Socket closed")
	
		elseif evt == TcpSocket.Events.Error then
			if DebugRx then print("Socket error "..tostring(err)) end
			Disconnected()
			ReportStatus("MISSING","Socket error")
		
		elseif evt == TcpSocket.Events.Timeout then
			if DebugRx then print("Socket timeout error "..tostring(err)) end
			TimeoutCount = TimeoutCount + 1
			if TimeoutCount > 3 then
				Disconnected()
				ReportStatus("MISSING","Socket Timeout")
			end
	
		else
			if DebugRx then print("Socket unknown  "..tostring(err)) end
			Disconnected()
			ReportStatus("MISSING",err)
		end
	end

	--Ethernet specific event handlers
	Controls["IPAddress"].EventHandler = function()
		if DebugFunction then print("IP Address Event Handler Called") end
		if Controls["IPAddress"].String == "" then Controls["IPAddress"].String = "Enter an IP Address" end
		ClearVariables()
		Initialize()
	end

	Controls["TcpPort"].EventHandler = function()
		if DebugFunction then print("Port Event Handler Called") end
		ClearVariables()
		Initialize()
	end

end

function Query(cmd)
	Send({
		Command = cmd.Command .. "?",
		Data = cmd.Data
	})
end

function SetRouteLayerFeedback(layer, output, input)
	if DebugFunction then print("SetRouteLayerFeedback(layer: "..layer..", output: "..output..", index: "..input..")") end
	--if DebugFunction then print('Handling Route: "'..msg["Data"]..'"') end
	if output~=nil and input~=nil then
		local in_ = tonumber(input)
		local out_ = tonumber(output)
		if out_~=nil and out_ <= Properties['Output Count'].Value and in_~=nil and in_ <= Properties['Input Count'].Value then
			for i=1, Properties['Input Count'].Value do
				Controls["vid-input_"..i.."-output_" ..output].Boolean = (in_==i) 
			end
		end
	end
end

function SetRouteAllFeedback(outputs)
	if DebugFunction then print("SetRouteAllFeedback("..table.concat(outputs)..")") end
	for o=1, #outputs do 
		SetRouteLayerFeedback(Layers.Video, o, outputs[o])
	end
end

--  Device Request and Data handlers

--[[ Test the device once for
	Model Number
	Device Name
	Model Name
	Serial Number
	SW Revision
]]

-- Initial data grab from device
function GetDeviceInfo()
	if DebugFunction then print("GetDeviceInfo() Called") end
	if Properties["Get Device Info"].Value then
    --QueryRoutes()
	end
end

local function QueryRoutes()
	Query({Command = Request["Route"].Command, Data = Layers.Video ..',*'})
end

function Connected()
	if DebugFunction or DebugRx then print("Connected() Called") end
	CommunicationTimer:Stop()
	CommandProcessing = false
	--Send({Command = Request["Help"].Command, Data = ""})
	Heartbeat:Start(PollRate)   
	--QueryRoutes()
	SendNextCommand()
end

function ParseProtocol(str)
  --print('ParseProtocol('..str..')')
  local k_,v_ = str:match('([^:]+): (.+)')
  --print('ParseProtocol('..k_..', '..v_..')')
  if k_=='Version' then -- '2.8'
  		Controls["DeviceFirmware"].String = v_
  end
end

function ParseDevice(str)
  --print('ParseDevice('..str..')')
  local k_,v_ = str:match('([^:]+): (.+)')
  --print('ParseDevice('..k_..', '..v_..')')
  if k_=='Device present' then -- 'true'
  elseif k_=='Model name' then -- Smart Videohub 12G 40x40
    Controls["ModelName"].String = v_
  elseif k_=='Friendly name' then -- Smart Videohub 12G 40x40
    Controls["DeviceName"].String = v_
  elseif k_=='Unique ID' then -- '7C2E0DA49FCC'
  	Controls["SerialNumber"].String = v_
  elseif k_=='Video inputs' then -- '40'
   	Properties["Input Count"].Value = tonumber(v_)
  elseif k_=='Video processing units' then -- '0'
  elseif k_=='Video outputs' then -- '40'
   	Properties["Output Count"].Value = tonumber(v_)
  elseif k_=='Video monitoring outputs' then -- '0'
  elseif k_=='Serial ports' then -- '0'
  end
end

function ParseOutputLabels(str)
  --print('ParseOutputLabels('..str..')')
  local out_, name_ = str:match('(%d+) (.+)')
    --print('ParseOutputLabel('..out_..', '..name_..')')
    if Controls["output_" .. out_ .. "-name"]~=nil then
      Controls["output_" .. out_ .. "-name"].String = name_
    end
end

local InputLabels = {}

function ParseInputLabels(str)
  --print('ParseInputLabels('..str..')')
  local in_, name_ = str:match('(%d+) (.+)')
    --print('ParseInputLabel('..in_..', '..name_..')')
    if Controls["input_" .. in_ .. "-name"]~=nil then
      Controls["input_" .. in_ .. "-name"].String = name_
      InputLabels[tonumber(in_)] = str
    end
end

function ParseLocks(str)
  --print('ParseLocks('..str..')')
  local out_, v_ = str:match('(%d+) ([LUO])') -- U:unlock, L:lock(returns O, not L), O:On (lock)
  -- outputs can be locked so that the system can't unlock them, in this case they return 'L' 
  if v_~=nil then
    local locked_ = v_~='U'  
    --print('ParseLocks('..out_..', '..tostring(locked_)..')')
    if Controls["output_" .. out_ .. "-lock"]~=nil then
      Controls["output_" .. out_ .. "-lock"].Boolean = locked_
      Controls["output_" .. out_ .. "-lock"].Legend = v_
    end
  end
end

function ParseRoute(str) -- input and output 0 exist
  --print('ParseRoute('..str..')')
  local out_, in_ = str:match('(%d+) (%d+)')
  print('ParseRoute('..out_..', '..in_..')')
  for i=0, Properties["Input Count"].Value do
    if Controls["vid-input_" .. i .. "-output_" .. out_]~=nil then
      --print("Controls[vid-input_" .. i .. "-output_" .. out_..'].Boolean = '..tostring(i==tonumber(in_)))
      Controls["vid-input_" .. i .. "-output_" .. out_].Boolean = i==tonumber(in_)
    end
  end
    --print('choice['..in_..']:'..Controls["output_" ..out_.. "-source"].Choices[tonumber(in_)+1])
    Controls["output_" ..out_.. "-source"].String =  Controls["output_" ..out_.. "-source"].Choices[tonumber(in_)+1]
end

function ParseConfig(str)
  --print('ParseConfig('..str..')')
  local k_,v_ = str:match('([^:]+): (.+)')
  --print('ParseConfig('..k_..', '..v_..')')
  if k_=='Take Mode' then -- 'true'
    --print(k_..', '..tostring(v_=='true')) 
    Controls["TakeMode"].Boolean = (v_=='true')
  end
end 

local callbacks_ = {
  ['PROTOCOL PREAMBLE']     = ParseProtocol,
  ['VIDEOHUB DEVICE']       = ParseDevice,
  ['OUTPUT LABELS']         = ParseOutputLabels,
  ['INPUT LABELS']          = ParseInputLabels,
  ['VIDEO OUTPUT LOCKS']    = ParseLocks,
  ['VIDEO OUTPUT ROUTING']  = ParseRoute,
  ['CONFIGURATION']         = ParseConfig,
  ['END PRELUDE'] = {},
  ['ACK']         = {},
  ['NAK']         = {}
}

function ParseResponse(msg)
	local delimPos_ = msg:find("\x0a\x0a")
	if DebugFunction then 
  	if delimPos_==nil then
        print("ParseResponse("..string.len(msg)..", delimiter not found) Called") 
        local g_ = msg:gmatch('(.-)\x0a\x0a') -- get the sections of data
        print("match == nil: "..tostring(g_==nil))
      else
        print("ParseResponse("..string.len(msg)..","..delimPos_..") Called") 
      end
  end
	local valid_ = msg:len()>0 and delimPos_~=nil
	--Message is too short, buffer the chunk and wait for more
	if not valid_ then 
		delimPos = delimPos or 0
		if DebugRx then 
			if msg:len() < 50 then 
				print("invalid["..#msg..","..delimPos.."]: "..msg)
			else
				print("invalid["..#msg..","..delimPos.."]: "..msg:sub(1,50))
			end 
		end  
		DataBuffer = DataBuffer .. msg
	else
		--Pack the data for the handler
    local cb_ = nil
    local g_ = msg:gmatch('(.-)\x0a\x0a') -- get the sections of data
    for m_ in g_ do
      --print('match: '..m_) -- good
      if m_:sub(-1)~='\x0a' then m_=m_..'\x0a' end -- the first match removed the \x0a from the last match
      local g1_ = m_:gmatch('(.-)\x0a')  -- e.g. "VIDEO OUTPUT ROUTING:\x0D\x0A2 3\x0D\x0A\x0D\x0A"i = 1
      local i = 1
      for m1_ in g1_ do
        --print('match1: '..m1_)
        if i==1 then
          m1_ = m1_:gsub(':','')
          if callbacks_[m1_]~=nil then 
            if m1_=='NAK' or m1_=='ACK' then 
              if DebugFunction then print(m1_..' received') end
            else
              if DebugFunction then print('Parsing category: '..m1_) end
              cb_=callbacks_[m1_]
            end
          else 
            if DebugFunction then print('unhandled category: '..m1_) end
            cb_=nil
          end
        elseif cb_~=nil then cb_(m1_) end
        i=i+1
      end
      if cb_~=nil and cb_==ParseInputLabels then 
        --if DebugFunction then print('InputLabels') end
        local choices_ = {}
		    for i = 0, Properties['Input Count'].Value-1 do
          if InputLabels[i]~=nil then table.insert(choices_, InputLabels[i]) 
          else table.insert(choices_, i..' INPUT '..i) end
        end
        --if DebugFunction then print('choices_') end
		    for o = 0, Properties['Output Count'].Value-1 do
          Controls["output_" .. o .. "-source"].Choices = choices_
        end
      end
    end 

		--Re-process any remaining data
		if delimPos_~=nil and (delimPos_+2 < msg:len()) then
			ParseResponse( msg:sub(delimPos_+2,-1) )
		end
	end
		
end

-------------------------------------------------------------------------------
-- Device routing functions
-------------------------------------------------------------------------------
local function SetRoute(layer, dest, src, state)
	if DebugFunction then print("Send layer " .. layer .. " from src " .. src .. " to dest " .. dest) end
	local cmd_ = Request["Route"]
	cmd_.Data = dest..' '.. src
	Send(cmd_)
	if SimulateFeedback then ParseResponse(string.format("%s\x0a %s\x0a\x0a", cmd_.Command, cmd_.Data)) end
end

local function SetOutputLock(index, value)
	if DebugFunction then print("Set output " .. index .. " lock to " .. tostring(value)) end
	local cmd_ = Request["OutputLock"]
	cmd_.Data = index..' '.. (value and 'L' or 'U') -- U:unlock, L:lock(returns O, not L), O:On (lock)
  -- outputs can be locked so that the system can't unlock them, in this case they return 'L' 
	Send(cmd_)
end

-------------------------------------------------------------------------------
-- Initialize
-------------------------------------------------------------------------------	
function TestFeedbacks()
  local test_ = "INPUT LABELS:\x0A0 INPUT ZERO\x0A1 INPUT ONE\x0A2 INPUT TWO\x0A\x0A"
  ParseResponse(test_)
end

function Initialize()
	if DebugFunction then print("Initialize() Called: "..GetPrettyName()) end
	--helper.TablePrint(Controls, 1)

	Layers = {
		Video = 1,
		Audio = 2
	}

	--helper.TablePrint(Properties, 1)
	if(Properties['Output Count'].Value > 0 and Properties['Input Count'].Value > 0) then
		for o = 0, Properties['Output Count'].Value-1 do

      Controls["output_" .. o .. "-lock"].EventHandler = function(ctl) 
  			if DebugFunction then print("output_" .. o .. "-lock pressed: "..tostring(ctl.Boolean)) end
        SetOutputLock(o, ctl.Boolean)
      end

      Controls["output_" .. o .. "-source"].EventHandler = function(ctl) 
        local in_, name_ = ctl.String:match('(%d+) (.+)')
  			if DebugFunction then print("output_" .. o .. "-source selected: "..name_) end
        SetRoute(Layers.Video, o, tonumber(in_), true) 
      end 

			for i = 0, Properties['Input Count'].Value-1 do
				-- Crosspoint EventHandlers
				Controls["vid-input_" .. i .. "-output_" .. o].EventHandler = function(ctl) 
					if DebugFunction then print("vid-input_" .. i .. "-output_" .. o .. " pressed") end
					SetRoute(Layers.Video, o, i, ctl.Value)
				end
			end
			
		end
	
	end

	Disconnected()
	Connect()
	--TestFeedbacks()
	--Heartbeat:Start(PollRate)
end

-- Timer EventHandlers  --
Heartbeat.EventHandler = function()
	if DebugFunction then print("Heartbeat Event Handler Called - CommandQueue size: "..#CommandQueue) end
end

SetupDebugPrint()
Initialize()
