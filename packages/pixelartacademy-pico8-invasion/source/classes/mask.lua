Mask = {}
Mask.__index = Mask

function Mask:new(sprite)
  local mask = setmetatable({}, Mask)
  
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

function Mask:removeSprite(originX, originY, sprite, spriteCenterX, spriteCenterY)
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
  local regionX2 = (sprite.spriteSheetIndex % spriteSheetTilesPerRow) * 8
  local regionY2 = flr(sprite.spriteSheetIndex / spriteSheetTilesPerRow) * 8

  -- Compare every pixel in the overlap.
  for globalX = overlapLeft, overlapRight do
    for globalY = overlapTop, overlapBottom do
      local maskX = globalX - originX + 1
      local maskY = globalY - originY + 1
      local sheetX = globalX - originX2 + regionX2
      local sheetY = globalY - originY2 + regionY2

      -- If sprite pixel is not transparent, remove it from the mask.
      if sget(sheetX, sheetY) ~= 0 then
        self.value[maskX][maskY] = false
      end
    end
  end
end
