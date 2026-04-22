local function meta_bool(key, default)
  local value = quarto.metadata.get(key)
  if value == nil then
    return default
  end

  local s = pandoc.utils.stringify(value):lower()
  if s == "true" then
    return true
  elseif s == "false" then
    return false
  else
    return default
  end
end

local key_map = {
  note = "teaching.collapse-notes",
  warning = "teaching.collapse-warnings",
  important = "teaching.collapse-importants",
  tip = "teaching.collapse-tips",
  caution = "teaching.collapse-cautions",
}

function Callout(callout)
  local key = key_map[callout.type]
  if key == nil then
    return
  end

  local should_collapse = meta_bool(key, false)

  -- preserve explicit user choice if present
  if should_collapse and callout.collapse == nil then
    callout.collapse = true
  end
end