function HorizontalRule()
  if FORMAT:match("html") then
    return {}
  end
end

function Para(el)
  if FORMAT:match("html") and #el.content == 5 and pandoc.utils.stringify(el) == ". . ." then
    return {}
  end
end

function CodeBlock(el)
  if el.classes:includes("run") then
    local template = el.attributes.template or ""
    el.classes = el.classes:filter(function(c) return c ~= "run" end)
    el.attributes.template = nil

    if FORMAT:match("html") then
      local snippet = string.format(
        '<codapi-snippet sandbox="sqlite" engine="wasi" editor="basic"%s></codapi-snippet>',
        template ~= "" and (' template="' .. template .. '"') or ""
      )
      return {el, pandoc.RawBlock("html", snippet)}
    else
      return el
    end
  end
end

function Div(el)
  if FORMAT:match("html") and el.classes:includes("notes") then
    return {}
  end
end
