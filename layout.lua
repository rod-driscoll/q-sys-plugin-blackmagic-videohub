local CurrentPage = PageNames[props["page_index"].Value]
	
local colors = {  -- taken from some other plugin and not really kept track
  Background  = {232,232,232},
  Transparent = {255,255,255,0},
  Text        = {24,24,24},
  Header      = {0,0,0},
  Button      = {48,32,40},
  Red         = {217,32,32},
  DarkRed     = {80,16,16},
  Green       = {32,217,32},
  OKGreen     = {48,144,48},
  Blue        = {32,32,233},
  Black       = {0,0,0},
  White       = {255,255,255},
  Gray        = {96,96,96}
}

local function label(graphic)
  for k,v in pairs({
    Type = 'Label',
    Color = { 0, 0, 0 },
    HTextAlign = 'Right',
    FontSize = 14
  }) do graphic[k] = graphic[k] or v; end;
  table.insert(graphics, graphic);
end;

local function textinput(layout)
  for k,v in pairs({
    Color = { 208, 208, 208 },
    StrokeColor = { 102, 102, 102 },
    StrokeWidth = 2,
    CornerRadius = 8,
    FontSize = 12,
    Margin = 10,
    TextBoxStyle = 'Normal'
  }) do layout[k] = layout[k] or v; end;
  return layout;
  end;

layout["code"]={PrettyName="code",Style="None"}  
    
if(CurrentPage == 'Setup') then
  -- User defines connection properties
  table.insert(graphics,{Type="GroupBox",Text="Connect",Fill=colors.Background,StrokeWidth=1,CornerRadius=4,HTextAlign="Left",Position={5,5},Size={400,120}})
  if props["Connection Type"].Value=="Ethernet" then 
    table.insert(graphics,{Type="Text",Text="IP Address",Position={15,35},Size={100,16},FontSize=14,HTextAlign="Right"})
    layout["IPAddress"] = {PrettyName="Settings~IP Address",Style="Text",Color=colors.White,Position={120,35},Size={99,16},FontSize=12}
    table.insert(graphics,{Type="Text",Text="Port",Position={15,60},Size={100,16},FontSize=14,HTextAlign="Right"})
    layout["TcpPort"] = {PrettyName="Settings~Port",Style="Text",Position={120,60},Size={99,16},FontSize=12}
    table.insert(graphics,{Type="Text",Text="(9990 default)",Position={221,60},Size={100,18},FontSize=10,HTextAlign="Left"})
  else
    table.insert(graphics,{Type="Text",Text="Reset Serial",Position={5,32},Size={110,16},FontSize=14,HTextAlign="Right"})
    layout["Reset"] = {PrettyName="Settings~Reset Serial", Style="Button", Color=colors.Button, FontColor=colors.Red, FontSize=14, CornerRadius=2, Position={120,30}, Size={50,20} }
  end

  -- Status fields updated upon connect show model/name/serial/sw rev
  table.insert(graphics,{Type="GroupBox",Text="Status",Fill=colors.Background,StrokeWidth=1,CornerRadius=4,HTextAlign="Left",Position={5,135},Size={400,220}})
  layout["Status"] = {PrettyName="Status~Connection Status", Position={40,165}, Size={330,32}, Padding=4 }
  table.insert(graphics,{Type="Text",Text="Friendly Name",Position={15,212},Size={100,16},FontSize=12,HTextAlign="Right"})
  layout["DeviceName"] = {PrettyName="Status~Friendly Name", Style="Text", HTextAlign="Left", IsReadOnly=true, Color=colors.Transparent, StrokeWidth=0, FontSize=14, IsBold=true, FontColor=colors.Text, Position={120,211}, Size={255,16} }
  table.insert(graphics,{Type="Text",Text="Model Name",Position={15,235},Size={100,16},FontSize=12,HTextAlign="Right"})
  layout["ModelName"] = {PrettyName="Status~Model Name", Style="Text", HTextAlign="Left", IsReadOnly=true, Color=colors.Transparent, StrokeWidth=0, FontSize=14, IsBold=true, FontColor=colors.Text, Position={120,234}, Size={255,16} }
  table.insert(graphics,{Type="Text",Text="Serial Number",Position={15,258},Size={100,16},FontSize=12,HTextAlign="Right"})
  layout["SerialNumber"] = {PrettyName="Status~Serial Number", Style="Text", HTextAlign="Left", IsReadOnly=true, Color=colors.Transparent, StrokeWidth=0, FontSize=14, IsBold=true, FontColor=colors.Text, Position={120,257}, Size={255,16} }
    table.insert(graphics,{Type="Text",Text="Software Version",Position={15,281},Size={100,16},FontSize=12,HTextAlign="Right"})
  layout["DeviceFirmware"] = {PrettyName="Status~SW Version", Style="Text", HTextAlign="Left", IsReadOnly=true, Color=colors.Transparent, StrokeWidth=0, FontSize=14, IsBold=true, FontColor=colors.Text, Position={120,280}, Size={255,16} }

  table.insert(graphics,{Type="Text",Text=GetPrettyName(),Position={15,200},Size={380,14},FontSize=10,HTextAlign="Right", Color=colors.Gray})

elseif(CurrentPage == 'Device') then 
  
  --local helper = require("Helpers")
  helper = {}
  helper.Copy = function(tbl, seen)
    if type(tbl) ~= 'table' then return tbl end
    if seen and seen[tbl] then return seen[tbl] end 
    local s = seen or {}
    local res = setmetatable({}, getmetatable(tbl))
    s[tbl] = res
    for k, v in pairs(tbl) do
        res[helper.Copy(k, s)] = helper.Copy(v, s)
    end
    if res==nil then print('Copy(): returning nil') end
    return res
  end  

  -- create objects for each section so they can be modified easily

  local UI_crosspoints = {
    Position    = { 0, 8 },
    --Size        = { 0, 0 }, -- GroupBox contains Size of the whole object
    --buttons
    Padding     = { 4, 4 },
    GroupPadding= { 4, 4 },
    Button      = { Style = "Button", Size = { 36, 36}, Margin = 0 },
    NameText    = { Style = "Text", Type="Text", Color=colors.White, FontSize=10, HTextAlign="Center", WordWrap = true },
    NumButtons  = { props['Input Count'].Value, props['Output Count'].Value },
    Label       = { Style = "Label", Size = { 74, 14} , Type="Text", FontSize=10, HTextAlign="Center", WordWrap = true },
    Buttons     = {}, -- to be filled in Init()
    --groupbox
    GroupBox    = { Type="GroupBox", Text="Crosspoints", StrokeWidth=1, CornerRadius=4, HTextAlign="Left" },
    
    Init = function (self)
      if self.NumButtons[1] > 12 or self.NumButtons[2] > 12 then 
        self.Padding     = { 1, 1 }
        self.Button.Size = { 18, 18 }
      end
      self.GroupBox.Size = {
        self.Padding[1] + self.NumButtons[1]*(self.Padding[1] + self.Button.Size[1]),
        self.Padding[2] + self.NumButtons[2]*(self.Padding[2] + self.Button.Size[2]) + self.Label.Size[2]
      }        
      self.GroupBox.Position  = self.Position
      self.Buttons = {}

      for i=0, self.NumButtons[1]-1 do
        --local lbl_ = helper.Copy(self.Label) todo

        for o=0, self.NumButtons[2]-1 do
          local btn_ = helper.Copy(self.Button)
          btn_['PrettyName'] = "Crosspoints~Output "..o.."~In" .. i .. " -> Out" .. o
          btn_['Legend'] = tostring(i)
          btn_['Position']={
            self.Position[1] + self.Padding[1] + i*(self.Button.Size[1] + self.Padding[1]),
            self.Position[2] + self.Padding[2] + o*(self.Button.Size[2] + self.Padding[2]) + self.Label.Size[2]
          }
          btn_.Layout_ID = "vid-input_" ..i.. "-output_" .. o
          table.insert(self.Buttons, btn_)
        end
      end
    end,

    Draw = function(self, layout)
      table.insert(graphics, self.GroupBox)
      for _,b in ipairs(self.Buttons) do 
        layout[b.Layout_ID] = b -- layout is the global layout
      end 
    end,

    GetButtonPositions = function(self) -- returns diagonal buttons for getting locations to line up other objects
      local pos_ = {}
      for i=0, self.NumButtons[1]-1 do
        pos_[i]={
          self.Position[1] + self.Padding[1] + i*(self.Button.Size[1] + self.Padding[1]),
          self.Position[2] + self.Padding[2] + i*(self.Button.Size[2] + self.Padding[2]) + self.Label.Size[2]
        }
      end
      return pos_
    end     
  }

  --UI_crosspoints.NumButtons = { props['Input Count'].Value, props['Output Count'].Value }
  --print(table.concat(UI_crosspoints:GetSize(),','))

  -- add outputs (names, locks)
  local UI_outputObjects = {
    Position    = helper.Copy(UI_crosspoints.Position),
    --buttons
    Padding     = helper.Copy(UI_crosspoints.Padding),
    --Button      = helper.Copy(UI_crosspoints.Button),
    NameText    = helper.Copy(UI_crosspoints.NameText), --Size = { 36, 54}      
    NumButtons  = props['Output Count'].Value,
    Buttons     = {}, -- to be filled in Init()
    --groupbox
    GroupBox    = helper.Copy(UI_crosspoints.GroupBox),

    Init = function(self)
      local positions = UI_crosspoints:GetButtonPositions()
      self.NameText.Size = { 54, UI_crosspoints.Button.Size[2] }
      self.LockButtons = {}
      -- GroupBox
      self.GroupBox.Size = {
        self.Padding[1], -- horiz, to be increased as buttons added
        UI_crosspoints.GroupBox.Size[2] -- vert same as crosspoint GroupBox
      }        
      self.GroupBox.Position = self.Position
      self.GroupBox.Text="Outputs"

      for o=0, self.NumButtons-1 do
        -- Names
        local name_ = helper.Copy(self.NameText)
        name_['PrettyName'] = "Outputs~".. o .."~name"
        name_['Position']={ positions[0][1], positions[o][2] } -- horiz always the same, vert moves down
        name_.Layout_ID = "output_" .. o .. "-name"
        if o==0 then self.GroupBox.Size[1] = self.GroupBox.Size[1] + name_.Size[1] + self.Padding[1] end
        table.insert(self.Buttons, name_)
        
        -- Locks
        local btn_ = helper.Copy(UI_crosspoints.Button)
        name_['PrettyName'] = "Outputs~".. o .."~lock"
        btn_['Legend'] = tostring(o)
        btn_['Position']={ 
          name_.Position[1] + name_.Size[1] + self.Padding[1], -- horiz always the same
          positions[o][2] -- vert moves down to line up with the crosspoint buttons
        } 
        btn_.Layout_ID = "output_" .. o .. "-lock"
        if o==0 then self.GroupBox.Size[1] = self.GroupBox.Size[1] + btn_.Size[1] + self.Padding[1] end

        table.insert(self.Buttons, btn_)
      end
      -- set new position of UI_Crosspoints
      UI_crosspoints.Position[1] = self.GroupBox.Position[1] + self.GroupBox.Size[1] + self.Padding[1]  -- move the xpts over
      UI_crosspoints:Init() -- update locations of all internal objects
    end,

    Draw = function(self, layout)
      table.insert(graphics, self.GroupBox)
      for _,b in ipairs(self.Buttons) do 
        layout[b.Layout_ID] = b -- layout is the global layout
      end 
    end
  }

 -- add inputs (names)
 local UI_inputObjects = {
  Position    = {},
  --buttons
  Padding     = helper.Copy(UI_crosspoints.Padding),
  Button      = helper.Copy(UI_crosspoints.Button),
  NameText    = helper.Copy(UI_crosspoints.NameText), --Size = { 36, 54}      
  NumButtons  = props['Input Count'].Value,
  Buttons     = {}, -- to be filled in Init()
  --groupbox
  GroupBox    = helper.Copy(UI_crosspoints.GroupBox),

  Init = function(self)
    local positions = UI_crosspoints:GetButtonPositions()
    self.NameText.Size = { UI_crosspoints.Button.Size[1], 54 }
    -- GroupBox   
    self.GroupBox.Size = {
      UI_crosspoints.GroupBox.Size[1], -- horiz, same as crosspoints
      UI_crosspoints.Label.Size[2] + self.Padding[2], -- vert, increase as objects added
    }        
    self.Position = {
      UI_crosspoints.GroupBox.Position[1],
      UI_crosspoints.GroupBox.Position[2] + UI_crosspoints.GroupBox.Size[2] + self.Padding[2]
    }
    self.GroupBox.Position = self.Position
    self.GroupBox.Text="Inputs"

    for i=0, self.NumButtons-1 do
      -- Names
      local name_ = helper.Copy(self.NameText)
      name_['PrettyName'] = "Inputs~".. i .."~name"
      name_['Position']={ 
        positions[i][1], -- horiz moves accross
        UI_crosspoints.Label.Size[2] + self.Padding[2] + self.GroupBox.Position[2] -- vert always the same
      }
      name_.Layout_ID = "input_" .. i .. "-name"

      if i==0 then self.GroupBox.Size[2] = self.GroupBox.Size[2] + name_.Size[2] + self.Padding[2] end
      table.insert(self.Buttons, name_)
    end
  end,

  Draw = function(self, layout)
    table.insert(graphics, self.GroupBox)
    for _,b in ipairs(self.Buttons) do 
      layout[b.Layout_ID] = b -- layout is the global layout
    end 
  end
}
  -- move base position of xpts

  UI_outputObjects.Position = helper.Copy(UI_crosspoints.Position)


  UI_crosspoints.Position = { UI_crosspoints.Position[1], UI_crosspoints.Position[2] } -- move UI_crosspoints over
  --UI_crosspoints:AddRowToLeft()

  UI_crosspoints:Init() -- initialize the crosspoints so other components can reference it's positions
  UI_outputObjects:Init() -- this also moves crosspoints to the right
  UI_inputObjects:Init()
  
  UI_crosspoints:Draw(layout)
  UI_outputObjects:Draw(layout)
  UI_inputObjects:Draw(layout)

  -- add some group boxes and labels to make it pretty

end