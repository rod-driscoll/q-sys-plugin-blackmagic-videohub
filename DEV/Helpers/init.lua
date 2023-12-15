--[[
20231213 v1.1 Rod Driscoll
-added Copy()

20231029 v1.0 Rod Driscoll
-Initial version

rod@theavitgroup.com.au

These functions were created as i learnt Lua so chances are that many of them
 will become deprecated as I learn easier ways to manipulate tables
]]

local obj = {}

----------------------------------------------------------------------------
-- utility functions
----------------------------------------------------------------------------
obj.TablePrint = function(tbl, indent)
    if not indent then indent = 0 end 
    --print('TablePrint type.'..type(tbl))
    
    local function LinePrint(k,v,indent)
        --print('LinePrint - type.'..type(v)) 
        if not indent then indent = 0 end 
        local formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            obj.TablePrint(v, indent+1)
        elseif type(v) == 'string' or type(v) == 'boolean' or type(v) == 'number' then
            print(formatting .. tostring(v))
        --elseif type(v) == 'userdata' then
        else
            print(formatting .. 'Type.'..type(v))
        end
    end
    
    if type(tbl) == "table" then
        for k, v in pairs(tbl) do LinePrint(k,v,indent) end
    elseif type(tbl) == "userdata" then
        --for k, v in ipairs(tbl) do LinePrint(k,v) end
        --print(table.concat)
        pcall(function() print(tostring(tbl)) for k, v in pairs(tbl) do LinePrint(k,v) end end)
        --print('33 TablePrint type.'..type(tbl))
        --pcall(function() for k, v in ipairs(tbl) do LinePrint(k,v) end end)
        --print('35 TablePrint type.'..type(tbl))
    elseif type(tbl) == "string" then
        LinePrint('Type.'..type(tbl), tbl)
    else
        print('TablePrint Type.'..type(tbl))
    end
end

obj.UpdateItems = function(tbl, indent) -- this will print the whole array to a table
    print('UpdateItems() started -----------------------------------------------------')
    local table_ = {}
    if not indent then indent = 0 end 

    local function update(tbl, indent)

        local function linePrint(k,v,indent)
            --print('LinePrint - type.'..type(v))
            local formatting = string.rep("  ", indent) .. k .. ": "
            if type(v) == "table" then
                table.insert(table_, formatting)
                update(v, indent+1)
            elseif type(v) == 'string' or type(v) == 'boolean' or type(v) == 'number' then
                table.insert(table_, formatting .. tostring(v))
            --elseif type(v) == 'userdata' then
            else
                table.insert(table_, formatting .. 'Type.'..type(v))
            end
        end
        
        -- update() starts here
        if type(tbl) == "table" then
            for k, v in pairs(tbl) do linePrint(k,v,indent) end
        elseif type(tbl) == "userdata" then
            --for k, v in ipairs(tbl) do linePrint(k,v) end
            --print(table.concat)
            pcall(function() table.insert(table_, tostring(tbl)) for k, v in pairs(tbl) do linePrint(k,v) end end)
            --print('33 TablePrint type.'..type(tbl))
            --pcall(function() for k, v in ipairs(tbl) do linePrint(k,v) end end)
            --print('35 TablePrint type.'..type(tbl))
        elseif type(tbl) == "string" then
            linePrint('Type.'..type(tbl), tbl)
        else
            table.insert(table_, 'TablePrint Type.'..type(tbl))
        end
    end
    
    update(tbl, indent)
    print('UpdateItems() finished -----------------------------------------------------')
    obj.TablePrint(table_)
    return table_
end
--[[
obj.UpdateItems = function(data)  -- this will print the whole array to a table
    local table_ = {}
    for k,v in pairs(data) do
        local str_ = ""
        if type(v) == "string" then
            str_ = k..': '..v               -- 'status: online'
        else
            str_ = k..': Type.'..type(v)  -- 'status: Type.function'
        end
        --print(str_)
        table.insert(table_, str_)
    end
    --print('-----------------------------------------------------')
    return table_
end
]]

obj.dump = function(o)
    --print('object type: ', type(o))
    if type(o) == 'table' then
        --print('.table')
        local s = '{ '
        for k,v in pairs(o) do
            --print('type(k):',type(k),'type(v):',type(v))
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        s = s .. '} '
        --print(s)
        return s
    else
        if type(o) == 'userdata' then
            --print('.Type: ', o.Type)
        elseif type(o) == 'number' then
            --print('.number: ', o)
        elseif type(o) == 'string' then
            --print('.string: ', o)
        end
        return tostring(o)
    end
end

-- this might be replaceable wit TablePrint or table:concat when i learn more lua
obj.PrintControl = function(ctl)
    print('Control ----------------------------')
    --obj.TablePrint(ctl,2)
    pcall(function() if ctl.Name        ~=nil then print(".\tName:          "..tostring(ctl.Name        )) end end)
    pcall(function() if ctl.Index       ~=nil then print(".\tIndex:         "..tostring(ctl.Index       )) end end)
    pcall(function() if ctl.Legend      ~=nil then print(".\tLegend:        "..tostring(ctl.Legend      )) end end)
    pcall(function() if ctl.Value       ~=nil then print(".\tValue:         "..tostring(ctl.Value       )) end end)
    pcall(function() if ctl.String      ~=nil then print(".\tString:        "..tostring(ctl.String      )) end end)
    pcall(function() if ctl.Boolean     ~=nil then print(".\tBoolean:       "..tostring(ctl.Boolean     )) end end)
    pcall(function() if ctl.Position    ~=nil then print(".\tPosition:      "..tostring(ctl.Position    )) end end)
    pcall(function() if ctl.Type        ~=nil then print(".\tType:          "..tostring(ctl.Type        )) end end)
    pcall(function() if ctl.Direction   ~=nil then print(".\tDirection:     "..tostring(ctl.Direction   )) end end)
    pcall(function() if ctl.MinValue    ~=nil then print(".\tMinValue:      "..tostring(ctl.MinValue    )) end end)
    pcall(function() if ctl.MaxValue    ~=nil then print(".\tMaxValue:      "..tostring(ctl.MaxValue    )) end end)
    pcall(function() if ctl.MinString   ~=nil then print(".\tMinString:     "..tostring(ctl.MinString   )) end end)
    pcall(function() if ctl.MaxString   ~=nil then print(".\tMaxString:     "..tostring(ctl.MaxString   )) end end)
    pcall(function() if ctl.Color       ~=nil then print(".\tColor:         "..tostring(ctl.Color       )) end end)
    pcall(function() if ctl.Style       ~=nil then print(".\tStyle:         "..tostring(ctl.Style       )) end end)
    pcall(function() if ctl.IsInvisible ~=nil then print(".\tIsInvisible:   "..tostring(ctl.IsInvisible )) end end)
    pcall(function() if ctl.IsDisabled  ~=nil then print(".\tIsDisabled:    "..tostring(ctl.IsDisabled  )) end end)
end

obj.PrintComponent = function(name)
    blinker = Component.New(name)
    b_ctrls = Component.GetControls(blinker)
    print("Component GetControls("..name..")")
    for _,b_element in ipairs(b_ctrls) do
        PrintControl(b_element)
    end
end

obj.Copy = function(tbl, seen)
    if type(tbl) ~= 'table' then return tbl end
    if seen and seen[tbl] then return seen[tbl] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(tbl))
    s[tbl] = res
    for k, v in pairs(tbl) do
        res[obj.Copy(k, s)] = obj.Copy(v, s)
    end
    if res==nil then print('Copy(): returning nil') end
    return res
end

--GetTableItemWithKey( {['aa'] = 'aaa', ['bb'] = 'bbb'},  {['bb'] = 'bbb'} )
obj.GetTableItemWithKey = function(table, pair)
    local key_
    local value_
    for k,v in pairs(pair) do
        key_ = k
        value_ = pair[k]
        --print('["'..key_..'"] = "'..value_..'"')
    end
        --print('looking for ["'..key_..'"] = "'..value_..'"" in', type(table), 'len', #table)

    for i,v in pairs(table) do
        --print('... ["'..i..'"] = "'..v..'"')
        --print('... ["'..v..'"]')
        if i == key_ and v == value_ then
            --print('found ["'..key_..'"] = "'..value_..'"')
            return i,v
        end
    end
end

--[[]
  local mytable_ = {
    { ['name'] = 'aaa',   ['data'] = 'qqq' }, 
    { ['name'] = 'bbb',   ['data'] = 'www' }, 
    { ['name'] = 'ccc',   ['data'] = 'eee' }, 
    { ['name'] = 'ddd',   ['data'] = 'rrr' }
  }
  
  local mySearch_ = { ['name'] = 'ccc' }
  local myResult_ = GetArrayItemWithKey(mytable_, mySearch_)
  if myResult_ then
    print("['data'] = "..myResult_['data'])
  end
]]
obj.GetArrayItemWithKey = function(table, pair)
    local key_
    local value_
    for k,v in pairs(pair) do
        key_ = k
        value_ = pair[k]
        --print('["'..key_..'"] = "', value_..'"')
    end
    --print('looking for ["'..key_..'"] = "'..value_..'" in', type(table), 'len', #table)

    for i,v in pairs(table) do
        --print('searching ["'..v[key_]..'"]')
        if v[key_] == value_ then
            --print('found ["'..key_..'"] = "'..v[key_]..'"')
            return i, v
        end
    end
end

--local myResult_ = GetArrayKvpItemWithKey(Controls.Decoder_names.Choices, 'id')
obj.GetChoicesItem = function(array, key) -- where .Choices[x] = 'id: abc', key == 'id'
    for i,str in ipairs(array) do -- iterrate through Choices array
        --print('searching ["'..i..'"] '..str)
        local x,y = string.find(str, key..': ')
        if x == 1 then return string.sub(str, y+1, -1) end -- 'abc'
    end
    return false
end

obj.GetValueStringFromTable = function(data, str)  -- e.g. str will be like 'id: xyz'
    local str_ = ""                            -- e.g. if data['id'] = 'abc'
    local x = string.find(str, ': ')           -- e.g. return 'id: abc'
    if x then
        str_ = string.sub(str, 1, x-1)
        if data[str_] then
            if type(data[str_]) == 'string' then
                str_ = str_..': '..data[str_]
            else
                str_ = str_..': '..type(data[str_])
            end
        else
            str_ = str_..':'
        end
    end
    return str_
end

-- feead in original table and a table of updated values,
-- then update existing values without adding any new items
obj.UpdateItemsInArray = function(data, array)  -- this will only print items common to array
    local table_ = {} 
    for k,v in ipairs(array) do
        if data[v] then
            local str_ = ""
            if type( data[v]) == "string" then
                str_ = v..': '.. data[v]            -- 'status: online'
            else
                str_ = v..': Type.'..type(data[v])  -- 'status: Type.function'
            end
            print(str_)
            table.insert(table_, str_)
        end  
    end
    return table_
end

obj.GetIndexfromValue = function(table, value)
    --print('GetIndexfromValue('..value..')')
    for i=1, #table do
        --print('['..i..'] = '..table[i])
        if table[i] == value then return i end
    end
end

obj.find_value = function(target, value)
    --print("find_value("..value..") type: ", type(target))
    if(type(target) == 'table') then
        for i,v in pairs(target) do
            if v == value then return(i) end
        end  
    elseif(type(target) == 'array') then
        for i,v in ipairs(target) do
            if v == value then return(i) end
        end
    elseif(type(target) == 'string') then
        return(target:find(value))
    end
    return false
end
----------------------------------------------------------------------------
-- Initialisation
----------------------------------------------------------------------------

return obj