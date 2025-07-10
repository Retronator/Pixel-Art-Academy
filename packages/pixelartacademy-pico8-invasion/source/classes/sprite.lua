Sprite = {}
Sprite.__index = Sprite

spriteSheetTilesPerRow = 16

function Sprite:new(spriteSheetIndex, spriteSheetWidth, spriteSheetHeight)
  local sprite = setmetatable({}, Sprite)

  sprite.spriteSheetIndex = spriteSheetIndex
  sprite.spriteSheetWidth = spriteSheetWidth
  sprite.spriteSheetHeight = spriteSheetHeight
  
  -- Analyze the sprite sheet to automatically determine the bounding box.
  local regionX = (spriteSheetIndex % spriteSheetTilesPerRow) * 8
  local regionY = flr(spriteSheetIndex / spriteSheetTilesPerRow) * 8
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

function Sprite:getPixel(x, y)
  local regionX = (self.spriteSheetIndex % spriteSheetTilesPerRow) * 8
  local regionY = flr(self.spriteSheetIndex / spriteSheetTilesPerRow) * 8
  local sheetX = regionX + self.bounds.left + x
  local sheetY = regionY + self.bounds.top + y
  return sget(sheetX, sheetY)
end

function Sprite:draw(centerX, centerY, mask)
  if mask ~= nil then
    local originX1 = flr(centerX) - self.centerX
    local originY1 = flr(centerY) - self.centerY
    local left = originX1 + self.bounds.left
    local top = originY1 + self.bounds.top

    local regionX = (self.spriteSheetIndex % spriteSheetTilesPerRow) * 8
    local regionY = flr(self.spriteSheetIndex / spriteSheetTilesPerRow) * 8

    for maskX = 1, self.bounds.width do
      for maskY = 1, self.bounds.height do
        if mask.value[maskX][maskY] then
          local sheetX = regionX + self.bounds.left + maskX - 1
          local sheetY = regionY + self.bounds.top + maskY - 1

          color = sget(sheetX, sheetY)

          if color ~= 0 then
            local globalX = left + maskX - 1
            local globalY = top + maskY - 1
            pset(globalX, globalY, color)
          end
        end
      end
    end
  else
    spr(self.spriteSheetIndex, centerX - self.centerX, centerY - self.centerY, self.spriteSheetWidth, self.spriteSheetHeight)
  end
end

function Sprite:isInPlayfield(centerX, centerY)
  local left = centerX - self.relativeCenterX
  local right = left + self.bounds.width - 1
  local top = centerY - self.relativeCenterY
  local bottom = top + self.bounds.height - 1

  return right >= game.design.playfieldBounds.left and left <= game.design.playfieldBounds.right and bottom >= game.design.playfieldBounds.top and top <= game.design.playfieldBounds.bottom
end

function Sprite:overlaps(centerX, centerY, sprite, spriteCenterX, spriteCenterY, spriteMask)
  -- Compute origins in world space.
  local originX1 = flr(centerX) - self.centerX
  local originY1 = flr(centerY) - self.centerY
  local originX2 = flr(spriteCenterX) - sprite.centerX
  local originY2 = flr(spriteCenterY) - sprite.centerY

  -- Compute bounding boxes in world space.
  local left1 = originX1 + self.bounds.left
  local top1 = originY1 + self.bounds.top
  local right1 = originX1 + self.bounds.right
  local bottom1 = originY1 + self.bounds.bottom

  local left2 = originX2 + sprite.bounds.left
  local top2 = originY2 + sprite.bounds.top
  local right2 = originX2 + sprite.bounds.right
  local bottom2 = originY2 + sprite.bounds.bottom

  -- Compute overlap area in world space.
  local overlapLeft = max(left1, left2)
  local overlapTop = max(top1, top2)
  local overlapRight = min(right1, right2)
  local overlapBottom = min(bottom1, bottom2)

  -- No need to do pixel-by-pixel comparison if there is no overlap.
  if overlapLeft > overlapRight or overlapTop > overlapBottom then
    return false
  end

  -- Compute origins in the sprite sheet space.
  local regionX1 = (self.spriteSheetIndex % spriteSheetTilesPerRow) * 8
  local regionY1 = flr(self.spriteSheetIndex / spriteSheetTilesPerRow) * 8
  local regionX2 = (sprite.spriteSheetIndex % spriteSheetTilesPerRow) * 8
  local regionY2 = flr(sprite.spriteSheetIndex / spriteSheetTilesPerRow) * 8

  -- Compare every pixel in the overlap.
  for globalX = overlapLeft, overlapRight do
    for globalY = overlapTop, overlapBottom do
      local spriteMaskIsTrue = true

      if spriteMask ~= nil then
        local maskX = globalX - originX2 - sprite.bounds.left + 1
        local maskY = globalY - originY2 - sprite.bounds.top + 1
        spriteMaskIsTrue = spriteMask.value[maskX][maskY]
      end

      if spriteMaskIsTrue then
        local sheetX1 = globalX - originX1 + regionX1
        local sheetY1 = globalY - originY1 + regionY1
        local sheetX2 = globalX - originX2 + regionX2
        local sheetY2 = globalY - originY2 + regionY2

        -- If both pixels are not transparent, we have an overlap.
        if sget(sheetX1, sheetY1) ~= 0 and sget(sheetX2, sheetY2) ~= 0 then
          return true
        end
      end
    end
  end

  -- No pixels were overlapping.
  return false
end
