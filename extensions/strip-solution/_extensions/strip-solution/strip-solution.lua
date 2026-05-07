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

local function abort(message)
  if type(fatal) == "function" then
    fatal(message, 3)
  else
    io.stderr:write("ERROR: " .. message .. "\n")
    os.exit(1)
  end
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

local function attribute(el, key)
  local attr = el.attributes or {}
  return attr[key]
end

local function strip(value)
  if value == nil then
    return nil
  end

  return tostring(value):match("^%s*(.-)%s*$")
end

local function teaching_role(value)
  if value == nil then
    return nil
  end

  local role = strip(value):lower()
  if role == "exercise" or role == "solution" then
    return role
  end

  abort("strip-solution: unknown teaching value '" .. tostring(value) .. "'. Expected 'exercise' or 'solution'.")
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

local function combined_teaching_role(el, code)
  local attr_role = teaching_role(attribute(el, "teaching"))
  if code == nil then
    return attr_role
  end

  local option_role = teaching_role(cell_option(code, "teaching"))
  if attr_role ~= nil and option_role ~= nil and attr_role ~= option_role then
    abort(
      "strip-solution: conflicting teaching values '"
        .. attr_role
        .. "' and '"
        .. option_role
        .. "' on the same block."
    )
  end

  return attr_role or option_role
end

local function classify_block(el, code)
  local role = combined_teaching_role(el, code)
  local legacy_exercise = truthy_attribute(el, "exercise")
    or (code ~= nil and truthy(cell_option(code, "exercise")))
  local legacy_solution = truthy_attribute(el, "solution")
    or (code ~= nil and truthy(cell_option(code, "solution")))

  if legacy_exercise and legacy_solution then
    abort("strip-solution: block cannot be both exercise and solution.")
  end

  local legacy_role = nil
  if legacy_exercise then
    legacy_role = "exercise"
  elseif legacy_solution then
    legacy_role = "solution"
  end

  if role ~= nil and legacy_role ~= nil and role ~= legacy_role then
    abort(
      "strip-solution: conflicting teaching markers; teaching is '"
        .. role
        .. "' but legacy marker is '"
        .. legacy_role
        .. "'."
    )
  end

  return role or legacy_role
end

local function should_strip(el, code)
  local role = classify_block(el, code)
  local show = show_solutions()
  if show == nil then
    return nil
  elseif show then
    if role == "exercise" then
      return {}
    end
  elseif role == "solution" then
    return {}
  end

  return nil
end

return {
  Div = function(div)
    return should_strip(div)
  end,
  CodeBlock = function(code)
    return should_strip(code, code.text)
  end,
}
