Mask = {}
Mask.__index = Mask

function Mask:new(sprite)
  local mask = setmetatable({}, Mask)

  mask.sprite = sprite
  mask.width = sprite.bounds.width
  mask.height = sprite.bounds.height
  mask.value = {}

  for x = 1, mask.width do
    mask.value[x] = {}
    for y = 1, mask.height do
      local color = sprite:getPixel(x - 1, y - 1)
      mask.value[x][y] = color > 0
    end
  end

  return mask
end

function Mask:removeSprite(originX, originY, sprite, spriteCenterX, spriteCenterY, explosionX, explosionY)
  -- Compute origins in world space.
  local originX2 = flr(spriteCenterX) - sprite.centerX
  local originY2 = flr(spriteCenterY) - sprite.centerY

  -- Compute bounding boxes in world space.
  local left1 = originX
  local top1 = originY
  local right1 = originX + self.width - 1
  local bottom1 = originY + self.height - 1

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
  local regionX1 = (self.sprite.spriteSheetIndex % spriteSheetTilesPerRow) * 8
  local regionY1 = flr(self.sprite.spriteSheetIndex / spriteSheetTilesPerRow) * 8
  local regionX2 = (sprite.spriteSheetIndex % spriteSheetTilesPerRow) * 8
  local regionY2 = flr(sprite.spriteSheetIndex / spriteSheetTilesPerRow) * 8

  -- Compare every pixel in the overlap.
  for globalX = overlapLeft, overlapRight do
    for globalY = overlapTop, overlapBottom do
      local maskX = globalX - originX + 1
      local maskY = globalY - originY + 1

      if self.value[maskX][maskY] then
        local sheet2X = globalX - originX2 + regionX2
        local sheet2Y = globalY - originY2 + regionY2

        -- If sprite pixel is not transparent, remove it from the mask.
        if sget(sheet2X, sheet2Y) ~= 0 then
          self.value[maskX][maskY] = false

          local sheet1X = regionX1 + self.sprite.bounds.left + maskX - 1
          local sheet1Y = regionY1 + self.sprite.bounds.top + maskY - 1
          local color = sget(sheet1X, sheet1Y)

          scene:addParticle(globalX, globalY, color, explosionX, explosionY)
        end
      end
    end
  end
end
