local function meta_bool(key)
  local value = quarto.metadata.get(key)
  if value == nil then
    return nil
  end

  local s = pandoc.utils.stringify(value):lower()
  if s == "true" or s == "1" or s == "yes" then
    return true
  elseif s == "false" or s == "0" or s == "no" then
    return false
  else
    return nil
  end
end

local function show_solutions()
  return meta_bool("teaching.show-solutions")
end

local function truthy(value)
  if value == nil then
    return false
  end

  local s = tostring(value):lower()
  return s == "true" or s == "1" or s == "yes"
end

local function truthy_attribute(el, key)
  local attr = el.attributes or {}
  return truthy(attr[key])
end

local function cell_option(code, key)
  for line in code:gmatch("[^\r\n]+") do
    local normalized = line:gsub("\194\160", " ")
    local value = normalized:match("^%s*#|%s*" .. key .. "%s*:%s*(.-)%s*$")
      or normalized:match("^%s*//|%s*" .. key .. "%s*:%s*(.-)%s*$")
      or normalized:match("^%s*%-%-|%s*" .. key .. "%s*:%s*(.-)%s*$")

    if value ~= nil then
      return value
    elseif not normalized:match("^%s*$") and not normalized:match("^%s*[#/%-]+|") then
      return nil
    end
  end

  return nil
end

local function should_strip(el, is_solution, is_exercise)
  local show = show_solutions()
  if show == nil then
    return nil
  elseif show then
    if is_exercise(el) then
      return {}
    end
  elseif is_solution(el) then
    return {}
  end

  return nil
end

return {
  Div = function(div)
    return should_strip(
      div,
      function(el) return truthy_attribute(el, "solution") end,
      function(el) return truthy_attribute(el, "exercise") end
    )
  end,
  CodeBlock = function(code)
    return should_strip(
      code,
      function(el) return truthy_attribute(el, "solution") or truthy(cell_option(el.text, "solution")) end,
      function(el) return truthy_attribute(el, "exercise") or truthy(cell_option(el.text, "exercise")) end
    )
  end,
}
