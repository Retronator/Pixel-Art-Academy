Sprite = {}
Sprite.__index = Sprite

function Sprite:new(spriteSheetIndex, spriteSheetWidth, spriteSheetHeight)
  local sprite = setmetatable({}, Sprite)

  sprite.spriteSheetIndex = spriteSheetIndex
  sprite.spriteSheetWidth = spriteSheetWidth
  sprite.spriteSheetHeight = spriteSheetHeight
  
  -- Analyze the sprite sheet to automatically determine the bounding box.
  local tiles_per_row = 16
  local regionX = (spriteSheetIndex % tiles_per_row) * 8
  local regionY = flr(spriteSheetIndex / tiles_per_row) * 8
  local regionWidth = spriteSheetWidth  * 8
  local regionHeight = spriteSheetHeight * 8

  local minX = regionWidth
  local minY = regionHeight
  local maxX = -1
  local maxY = -1

  for offsetX = 0, regionWidth - 1 do
    for offsetY = 0, regionHeight - 1 do
      local color = sget(regionX + offsetX, regionY + offsetY)

      if color ~= 0 then
        minX = min(minX, offsetX)
        minY = min(minY, offsetY)
        maxX = max(maxX, offsetX)
        maxY = max(maxY, offsetY)
      end
    end
  end

  -- See if any pixels were drawn.
  if maxX < 0 then
    -- Use the full sprite until the player draws something.
    sprite.bounds = {
      left = 0,
      right = regionWidth - 1,
      top = 0,
      bottom = regionHeight - 1
    }

  else
    sprite.bounds = {
      left = minX,
      right = maxX,
      top = minY,
      bottom = maxY
    }
  end

  sprite.bounds.width = sprite.bounds.right - sprite.bounds.left + 1
  sprite.bounds.height = sprite.bounds.bottom - sprite.bounds.top + 1

  sprite.relativeCenterX = flr((sprite.bounds.width - 1) / 2)
  sprite.relativeCenterY = flr((sprite.bounds.height - 1) / 2)

  sprite.centerX = sprite.bounds.left + sprite.relativeCenterX
  sprite.centerY = sprite.bounds.top + sprite.relativeCenterY

  return sprite
end

function Sprite:draw(centerX, centerY)
  spr(self.spriteSheetIndex, centerX - self.centerX, centerY - self.centerY, self.spriteSheetWidth, self.spriteSheetHeight)
end

function Sprite:isInPlayfield(centerX, centerY)
  local left = centerX - self.relativeCenterX
  local right = left + self.bounds.width - 1
  local top = centerY - self.relativeCenterY
  local bottom = top + self.bounds.height - 1

  return right >= gameDesign.playfieldBounds.left and left <= gameDesign.playfieldBounds.right and bottom >= gameDesign.playfieldBounds.top and top <= gameDesign.playfieldBounds.bottom
end
