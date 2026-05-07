function Div(div)
  local attr = div.attributes or {}
  local ex = attr["solution"]
  if ex ~= nil then
    ex = string.lower(ex)    
    if ex == "true" or ex == "1" then
      return pandoc.Null()
    end
  end

  return nil
end