console = {
  texts = {}
}

console.log = function(...)
  text = ""
  for object in all({...}) do
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
