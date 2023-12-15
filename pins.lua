if props["Connection Type"].Value=="Serial" then 
  table.insert(pins,{Name="input", Direction="input", Domain="serial"})
end