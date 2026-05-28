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

local function meta_bool(value)
  local s = stringify(value)
  if s == nil then
    return false
  end

  s = s:lower()
  return s == "true" or s == "1" or s == "yes"
end

local function abort(message)
  io.stderr:write("ERROR: " .. message .. "\n")
  os.exit(1)
end

local function trim_slashes(value)
  return value:gsub("^/+", ""):gsub("/+$", "")
end

local function js_string(value)
  value = tostring(value)
  value = value:gsub("\\", "\\\\")
  value = value:gsub("'", "\\'")
  value = value:gsub("\r", "\\r")
  value = value:gsub("\n", "\\n")
  value = value:gsub("</", "<\\/")
  return "'" .. value .. "'"
end

local function basename_without_extension(path)
  if path == nil or path == "" then
    return nil
  end

  local filename = path:match("([^/]+)$") or path
  return filename:gsub("%.[^.]+$", "")
end

local function document_basename()
  local candidates = {}

  if quarto.doc then
    if type(quarto.doc.project_output_file) == "function" then
      table.insert(candidates, quarto.doc.project_output_file())
    end
    table.insert(candidates, quarto.doc.output_file)
    table.insert(candidates, quarto.doc.input_file)
  end

  for _, candidate in ipairs(candidates) do
    local base = basename_without_extension(candidate)
    if base ~= nil and base ~= "" then
      return base
    end
  end

  abort("colab-link: could not determine the current document filename.")
end

local function colab_config()
  local repo = stringify(quarto.metadata.get("teaching.colab.repo"))
  local branch = stringify(quarto.metadata.get("teaching.colab.branch")) or "built-notebooks"
  local root = stringify(quarto.metadata.get("teaching.colab.root")) or "built_notebooks"
  local notebook_profile = stringify(quarto.metadata.get("teaching.colab.notebook-profile")) or "student"
  local text = stringify(quarto.metadata.get("teaching.colab.text")) or "Open in Google Colab"
  local icon = stringify(quarto.metadata.get("teaching.colab.icon")) or "box-arrow-up-right"

  if repo == nil then
    abort("colab-link: documents with 'colab: true' require 'teaching.colab.repo: owner/repo'.")
    return nil
  end

  if not repo:match("^[^/%s]+/[^/%s]+$") then
    abort("colab-link: 'teaching.colab.repo' must be in 'owner/repo' form.")
    return nil
  end

  return {
    repo = trim_slashes(repo),
    branch = trim_slashes(branch),
    root = trim_slashes(root),
    notebook_profile = trim_slashes(notebook_profile),
    text = text,
    icon = icon,
  }
end

local function colab_url(config)
  local notebook = document_basename() .. ".ipynb"
  local path = table.concat({
    config.root,
    config.notebook_profile,
    notebook,
  }, "/")

  return string.format(
    "https://colab.research.google.com/github/%s/blob/%s/%s",
    config.repo,
    config.branch,
    path
  )
end

local function injection_script(url, text, icon)
  return string.format([[
<script>
document.addEventListener('DOMContentLoaded', function () {
  const url = %s;
  const text = %s;
  const icon = %s;

  function createItem() {
    const item = document.createElement('li');
    const link = document.createElement('a');
    link.href = url;
    const iconEl = document.createElement('i');
    iconEl.className = 'bi bi-' + icon;
    link.appendChild(iconEl);
    link.appendChild(document.createTextNode(text));
    item.appendChild(link);
    return item;
  }

  function hasLink(container) {
    if (!container) {
      return false;
    }
    return Array.from(container.querySelectorAll('a')).some(function (link) {
      return link.href === url || link.getAttribute('href') === url;
    });
  }

  const formats = document.querySelector('.quarto-alternate-formats');
  if (formats) {
    let list = formats.querySelector('ul');
    if (!list) {
      list = document.createElement('ul');
      formats.appendChild(list);
    }
    if (!hasLink(list)) {
      list.appendChild(createItem());
    }
    return;
  }

  const block = document.createElement('div');
  block.className = 'quarto-alternate-formats';
  const heading = document.createElement('h2');
  heading.textContent = 'Other Formats';
  const list = document.createElement('ul');
  list.appendChild(createItem());
  block.appendChild(heading);
  block.appendChild(list);

  const margin = document.querySelector('#quarto-margin-sidebar');
  if (margin) {
    margin.appendChild(block);
    return;
  }

  const main = document.querySelector('main');
  if (main) {
    main.insertBefore(block, main.firstChild);
    return;
  }

  document.body.insertBefore(block, document.body.firstChild);
});
</script>
]], js_string(url), js_string(text), js_string(icon))
end

function Pandoc(doc)
  if not quarto.doc.is_format("html") then
    return doc
  end

  if not meta_bool(doc.meta.colab) then
    return doc
  end

  local config = colab_config()
  if config == nil then
    return doc
  end

  local url = colab_url(config)
  local script = injection_script(url, config.text, config.icon)

  table.insert(doc.blocks, 1, pandoc.RawBlock("html", script))
  return doc
end
