local function show_solutions()
  local value = quarto.metadata.get("teaching.show-solutions")
  if value ~= nil then
    return pandoc.utils.stringify(value):lower() == "true"
  end

  local profile = os.getenv("QUARTO_PROFILE") or ""
  return profile:find("solution") ~= nil
end

local function has_class(div, class)
  for _, c in ipairs(div.classes or {}) do
    if c == class then return true end
  end
  return false
end

return {
  Div = function(div)
    if not has_class(div, "callout-solution") then
      return nil
    end

    -- Strip entirely when not in instructor profile
    if not show_solutions() then
      return {}
    end

    local value = quarto.metadata.get("teaching.default-solution-title")
    local title = div.attributes["title"] or value or "Solution"

    -- Render as a proper Quarto callout for the instructor
    return quarto.Callout({
      type = "important",
      title = title,
      collapse = true,
      content = div.content,
    })
  end
}