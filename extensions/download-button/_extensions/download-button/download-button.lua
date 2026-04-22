local function stringify(value)
  if value == nil then
    return nil
  end
  local s = pandoc.utils.stringify(value)
  if s == "" then
    return nil
  end
  return s
end

local function basename(path)
  return path:match("([^/]+)$") or path
end

local function infer_icon(filename)
  local ext = filename:match("%.([^.]+)$")
  if not ext then
    return "📥"
  end

  ext = ext:lower()

  local icons = {
    pml = "🧬",
    csv = "📊",
    xlsx = "📊",
    tsv = "📊",
    txt = "📄",
    pdf = "📄",
    png = "🖼️",
    jpg = "🖼️",
    jpeg = "🖼️",
    svg = "🖼️",
    zip = "📦",
    gz = "📦",
    tar = "📦",
    py = "🐍",
    ipynb = "📓",
  }

  return icons[ext] or "📥"
end

return {
  ["download-button"] = function(args, kwargs, meta, raw_args, context)
    local path = stringify(kwargs["path"] or args[1])
    if not path then
      error("download-button requires 'path'")
    end

    local filename = stringify(kwargs["filename"] or args[2]) or basename(path)
    local icon = stringify(kwargs["icon"] or args[4]) or infer_icon(filename)
    local text = stringify(kwargs["text"] or args[3]) or ("Download " .. filename)

    local classes = stringify(kwargs["class"]) or "btn btn-outline-primary"
    local html = string.format(
      '<a class="%s" href="%s" download="%s">%s %s</a>',
      classes,
      path,
      filename,
      icon,
      text
    )

    return pandoc.RawInline("html", html)
  end
}