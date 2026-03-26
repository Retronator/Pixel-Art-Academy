console = {
  texts = {}
}

console.log = function(...)
  text = ""

  objects = {...}

  if #objects == 1 and type(objects[1]) == "table" then
    console.logTable(objects[1])
    return
  end

  for object in all(objects) do
    if #text > 0 then
      text = text.." "
    end
    text = text..tostr(object)
  end

  add(console.texts, text)
  if #console.texts > 128 / 6 then
    deli(console.texts, 1)
  end
end

console.logTable = function(object, indent)
  indent = indent or ''
  for key, value in pairs(object) do
    if type(value) == "table" then
      console.log(indent..key..":")
      console.logTable(value, indent..' ')
    else
      console.log(indent..key..": "..tostr(value))
    end
  end
end

console.draw = function()
  y = min(1, 128 - 6 * #console.texts)
  x = 1
  for text in all(console.texts) do
    for offsetX = -1, 1 do
      for offsetY = -1, 1 do
        print(text, x + offsetX, y + offsetY, 0)
      end
    end
    print(text, x, y, 7)
    y = y + 6
  end
end
