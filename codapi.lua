function CodeBlock(el)
  if el.classes:includes("run") then
    local template = el.attributes.template or ""
    el.classes = el.classes:filter(function(c) return c ~= "run" end)
    el.attributes.template = nil

    local snippet = string.format(
      '<codapi-snippet sandbox="sqlite" editor="basic"%s></codapi-snippet>',
      template ~= "" and (' template="' .. template .. '"') or ""
    )
    return {el, pandoc.RawBlock("html", snippet)}
  end
end
