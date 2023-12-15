table.insert(props,{
  Name = 'Input Count',
  Type = 'integer',
  Min = 2,
  Max = 127,
  Value = 6
})
table.insert(props,{
  Name = 'Output Count',
  Type = 'integer',
  Min = 1,
  Max = 127,
  Value = 2
})
table.insert(props,{
  Name    = "Connection Type",
  Type    = "enum", 
  Choices = {"Ethernet", "Serial"},
  Value   = "Ethernet"
})
table.insert(props,{
  Name  = "Poll Interval",
  Type  = "integer",
  Min   = 1,
  Max   = 60, 
  Value = 60
})
table.insert(props,{
  Name    = "Debug Print",
  Type    = "enum",
  Choices = {"None", "Tx/Rx", "Tx", "Rx", "Function Calls", "All"},
  Value   = "None"
})
