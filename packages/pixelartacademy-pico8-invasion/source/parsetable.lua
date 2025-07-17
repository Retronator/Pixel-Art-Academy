tabCharCode = 9
spaceCharCode = 32

function parseTable(text)
  local tableStack = {}
  local currentTable = {}
  add(tableStack, currentTable)

  lines = split(text, "\n")

  for line in all(lines) do
    -- Trim whitespace.
    while ord(line) == tabCharCode or ord(line) == spaceCharCode do
      line = sub(line, 2)
    end

    -- Skip empty lines.
    if line ~= "" then
      local parts = split(line, "=")
      local key, value

      if (parts[1] == "}") then
        -- The table is complete, pop from stack.
        deli(tableStack)
        currentTable = tableStack[#tableStack]
      else
        if (#parts == 1) then
          -- We have an array value.
          local nextIndex = #currentTable + 1
          key = nextIndex
          value = line
        else
          -- We have a key-value pair.
          key = parts[1]
          value = parts[2]
        end

        if (value == "{") then
          -- Value is a table.
          local newTable = {}
          currentTable[key] = newTable
          currentTable = newTable
          add(tableStack, newTable)
        else
          -- Simply store the value
          currentTable[key] = value
        end
      end
    end
  end

  return currentTable
end
