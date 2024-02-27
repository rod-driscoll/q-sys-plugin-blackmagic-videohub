
table.insert(ctrls, {
  Name         = "code",
  ControlType  = "Text",
  Count        = 1,
  UserPin      = true,
  PinStyle     = "Input"
})

-- Configuration Controls --
table.insert(ctrls, {
  Name         = "IPAddress",
  ControlType  = "Text",
  Count        = 1,
  DefaultValue = "Enter an IP Address",
  UserPin      = true,
  PinStyle     = "Both"
})
table.insert(ctrls, {
  Name         = "TcpPort",
  ControlType  = "Knob",
  ControlUnit  = "Integer",
  DefaultValue = 9990,
  Min          = 1,
  Max          = 65535,
  Count        = 1,
  UserPin      = true,
  PinStyle     = "Both"
})
table.insert(ctrls, {
  Name         = "ModelName",
  ControlType  = "Text",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = 1
})
table.insert(ctrls, {
  Name         = "DeviceName",
  ControlType  = "Text",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = 1
})
table.insert(ctrls, {
  Name         = "DeviceFirmware",
  ControlType  = "Text",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = 1
})
table.insert(ctrls, {
  Name         = "SerialNumber",
  ControlType  = "Text",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = 1
})

-- Status Controls --
table.insert(ctrls, {
  Name          = "Status",
  ControlType   = "Indicator",
  IndicatorType = Reflect and "StatusGP" or "Status",
  PinStyle      = "Output",
  UserPin       = true,
  Count         = 1
})

table.insert(ctrls, {
  Name         = "TakeMode",
  ControlType  = "Button",
  ButtonType   = "Toggle",
  PinStyle     = "Both",
  UserPin      = true,
  Count        = 1
})

    -- Switching Controls --
    for i = 1, props['Output Count'].Value do
      for s = 1, props['Input Count'].Value do
          table.insert(ctrls, {
                  Name = "vid-input_" .. s .. "-output_" .. i,
                  ControlType = "Button",
                  ButtonType = "Toggle",
                  PinStyle = "Both",
                  UserPin = true
              }
          )
      end
  end

-- input Controls --
for i = 1, props['Input Count'].Value do
  table.insert(ctrls,{
    Name         = "input_" .. i .. "-name",
    ControlType  = "Text",
    DefaultValue = "Input " .. i,
    Count        = 1,
    UserPin      = true,
    PinStyle     = "Both"
  })
end

-- output Controls --
for i = 1, props['Output Count'].Value do
  table.insert(ctrls,{
    Name         = "output_" .. i .. "-name",
    ControlType  = "Text",
    DefaultValue = "Output " .. i,
    Count        = 1,
    UserPin      = true,
    PinStyle     = "Both"
  })
  table.insert(ctrls, {
    Name         = "output_" .. i .. "-lock",
    ControlType  = "Button",
    ButtonType   = "Toggle",
    Count        = 1,
    UserPin      = true,
    PinStyle     = "Both"
  })
  table.insert(ctrls, {
    Name         = "output_" .. i .. "-source",
    ControlType  = "Text",
    Style        = "ComboBox",
    Count        = 1,
    UserPin      = true,
    PinStyle     = "Both"
  })
end