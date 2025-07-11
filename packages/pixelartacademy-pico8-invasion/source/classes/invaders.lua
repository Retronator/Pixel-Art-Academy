Invaders = {}
Invaders.__index = Invaders

function Invaders:new()
  local invaders = setmetatable({}, Invaders)

  -- Formation size

  invaders.columns = Game.design.invaders.formation.columns
  invaders.rows = Game.design.invaders.formation.rows

  invaders.fullFormationWidth = invaders.columns * Invader.sprite.bounds.width + (invaders.columns - 1) * Game.design.invaders.formation.horizontalSpacing
  invaders.fullFormationHeight = invaders.rows * Invader.sprite.bounds.height + (invaders.rows - 1) * Game.design.invaders.formation.verticalSpacing

  -- Formation bounds

  invaders.bounds = {
    left = -flr((invaders.fullFormationWidth - 1) / 2),
    top = -flr((invaders.fullFormationHeight - 1) / 2)
  }

  invaders.bounds.right = invaders.bounds.left + invaders.fullFormationWidth - 1
  invaders.bounds.bottom = invaders.bounds.top + invaders.fullFormationHeight - 1

  -- Formation slots

  invaders.formation = {}

  for columnNumber = 1, invaders.columns do
    local x = invaders.bounds.left + flr((Invader.sprite.bounds.width - 1) / 2) + (columnNumber - 1) * (Invader.sprite.bounds.width + Game.design.invaders.formation.horizontalSpacing)
    invaders.formation[columnNumber] = {}

    for rowNumber = 1, invaders.rows do
      local y = invaders.bounds.top + flr((Invader.sprite.bounds.height - 1) / 2) + (rowNumber - 1) * (Invader.sprite.bounds.height + Game.design.invaders.formation.verticalSpacing)
      invaders.formation[columnNumber][rowNumber] = {
        x = x,
        y = y,
        moved = false
      }
    end
  end

  -- Alive count

  invaders.aliveCount = invaders.columns * invaders.rows

  invaders.aliveCountByRows = {}
  for rowNumber = 1, invaders.rows do add(invaders.aliveCountByRows, invaders.columns) end

  invaders.aliveCountByColumns = {}
  for columnNumber = 1, invaders.columns do add(invaders.aliveCountByColumns, invaders.rows) end

  invaders.aliveRowsCount = invaders.rows
  invaders.aliveColumnsCount = invaders.columns

  -- Formation position

  local edgeMargin = min(Game.design.invaders.formation.horizontalSpacing, Game.design.invaders.formation.verticalSpacing)

  if Game.design.invaders.formation.horizontalAlignment == HorizontalAlignment.Left then
    invaders.x = Game.design.playfieldBounds.left - invaders.bounds.left + edgeMargin

  elseif Game.design.invaders.formation.horizontalAlignment == HorizontalAlignment.Right then
    invaders.x = Game.design.playfieldBounds.right - invaders.bounds.right - edgeMargin

  else
    invaders.x = Game.design.playfieldBounds.left + flr(Game.design.playfieldBounds.width / 2)
  end

  if Game.design.invaders.formation.verticalAlignment == VerticalAlignment.Top then
    invaders.y = Game.design.playfieldBounds.top - invaders.bounds.top + edgeMargin

  elseif Game.design.invaders.formation.verticalAlignment == VerticalAlignment.Bottom then
    invaders.y = Game.design.playfieldBounds.bottom - invaders.bounds.bottom - edgeMargin

  else
    invaders.y = Game.design.playfieldBounds.top + flr(Game.design.playfieldBounds.height / 2)
  end

  -- Movement direction

  if Game.design.invaders.attackDirection == DesignOptions.Invaders.AttackDirection.Down or Game.design.invaders.attackDirection == DesignOptions.Invaders.AttackDirection.Up then
    invaders.attackOrientation = Orientations.Vertical
    invaders.moveDirection = Directions.Right

  else
    invaders.attackOrientation = Orientations.Horizontal
    invaders.moveDirection = Directions.Down

  end

  invaders.currentIndividualColumnNumber = 0
  invaders.currentIndividualRowNumber = 0

  -- Spawning

  invaders.spawnedAll = false
  invaders.spawnDuration = 0

  -- Shooting

  if Game.design.invaderProjectiles.movement == Directions.Down or Game.design.invaderProjectiles.movement == Directions.Up then
    invaders.shootingOrientation = Orientations.Vertical

  else
    invaders.shootingOrientation = Orientations.Horizontal

  end

  invaders.shootingDuration = 0
  invaders:setShootingTimeout()

  return invaders
end

-- Individual Movement

function Invaders:resetIndividualMovement()
  if self.attackOrientation == Orientations.Vertical then
    if self.moveDirection == Directions.Right then
      self.currentIndividualColumnNumber = self.columns
    else
      self.currentIndividualColumnNumber = 1
    end

    if Game.design.invaders.attackDirection == DesignOptions.Invaders.AttackDirection.Down then
      self.currentIndividualRowNumber = self.rows
    else
      self.currentIndividualRowNumber = 1
    end

  else
    if self.moveDirection == Directions.Down then
      self.currentIndividualRowNumber = self.rows
    else
      self.currentIndividualRowNumber = 1
    end

    if Game.design.invaders.attackDirection == DesignOptions.Invaders.AttackDirection.Right then
      self.currentIndividualColumnNumber = self.columns
    else
      self.currentIndividualColumnNumber = 1
    end
  end
end

function Invaders:individualMovementHasValidInvader()
  return not (self.currentIndividualRowNumber < 1 or self.currentIndividualRowNumber > self.rows or self.currentIndividualColumnNumber < 1 or self.currentIndividualColumnNumber > self.columns)
end

function Invaders:individualMovementHasSpawnedInvader()
  if not self:individualMovementHasValidInvader() then
    return false

  else
    return self.formation[self.currentIndividualColumnNumber][self.currentIndividualRowNumber].invader ~= nil

  end
end

function Invaders:individualMovementHasAliveInvader()
  if not self:individualMovementHasSpawnedInvader() then
    return false

  else
    return self.formation[self.currentIndividualColumnNumber][self.currentIndividualRowNumber].invader.alive

  end
end

function Invaders:moveIndividualMovementToNextAliveInvader()
  while true do
    local moveInAttackOrientation = false

    if self.attackOrientation == Orientations.Vertical then
      if self.moveDirection == Directions.Right then
        self.currentIndividualColumnNumber = self.currentIndividualColumnNumber - 1

        if self.currentIndividualColumnNumber < 1 then
          moveInAttackOrientation = true
          self.currentIndividualColumnNumber = self.columns
        end

      else
        self.currentIndividualColumnNumber = self.currentIndividualColumnNumber + 1

        if self.currentIndividualColumnNumber > self.columns then
          moveInAttackOrientation = true
          self.currentIndividualColumnNumber = 1
        end

      end

      if moveInAttackOrientation then
        if Game.design.invaders.attackDirection == DesignOptions.Invaders.AttackDirection.Down then
          self.currentIndividualRowNumber = self.currentIndividualRowNumber - 1
        else
          self.currentIndividualRowNumber = self.currentIndividualRowNumber + 1
        end
      end

    else
      if self.moveDirection == Directions.Down then
        self.currentIndividualRowNumber = self.currentIndividualRowNumber - 1

        if self.currentIndividualRowNumber < 1 then
          moveInAttackOrientation = true
          self.currentIndividualRowNumber = self.columns
        end

      else
        self.currentIndividualRowNumber = self.currentIndividualRowNumber + 1

        if self.currentIndividualRowNumber > self.columns then
          moveInAttackOrientation = true
          self.currentIndividualRowNumber = 1
        end
      end

      if moveInAttackOrientation then
        if Game.design.invaders.attackDirection == DesignOptions.Invaders.AttackDirection.Right then
          self.currentIndividualColumnNumber = self.currentIndividualColumnNumber - 1

        else
          self.currentIndividualColumnNumber = self.currentIndividualColumnNumber + 1
        end
      end
    end

    if self:individualMovementHasAliveInvader() or not self:individualMovementHasValidInvader() then
      return
    end
  end
end

-- Spawning

function Invaders:spawnNextInvader()
  local spawnByRow = invaders.attackOrientation == Orientations.Vertical
  local firstCount, secondCount

  if spawnByRow then
    firstCount = Game.design.invaders.formation.rows
    secondCount = Game.design.invaders.formation.columns
  else
    firstCount = Game.design.invaders.formation.columns
    secondCount = Game.design.invaders.formation.rows
  end

  for firstNumber = 1, firstCount do
    for secondNumber = 1, secondCount do

      if spawnByRow then
        if Game.design.invaders.attackDirection == DesignOptions.Invaders.AttackDirection.Down then
          formationSpot = self.formation[secondNumber][firstNumber]
        else
          formationSpot = self.formation[secondNumber][self.rows - firstNumber + 1]
        end
      else
        if Game.design.invaders.attackDirection == DesignOptions.Invaders.AttackDirection.Right then
          formationSpot = self.formation[firstNumber][secondNumber]
        else
          formationSpot = self.formation[self.columns - firstNumber + 1][secondNumber]
        end
      end

      if formationSpot.invader == nil then
        local x = self.x + formationSpot.x
        local y = self.y + formationSpot.y
        formationSpot.invader = scene:addInvader(x, y)
        return
      end
    end
  end

  self.spawnedAll = true
end

-- Movement

function Invaders:moveNextInvader()
  if (not self:individualMovementHasAliveInvader()) then
    self:moveIndividualMovementToNextAliveInvader()

    if (not self:individualMovementHasAliveInvader()) then
      return
    end
  end

  formationSpot = self.formation[self.currentIndividualColumnNumber][self.currentIndividualRowNumber]
  formationSpot.invader:moveTo(self.x + formationSpot.x, self.y + formationSpot.y)

  self:moveIndividualMovementToNextAliveInvader()
end

-- Shooting

function Invaders:setShootingTimeout()
  local fullRatio = self.aliveCount / (self.rows * self.columns)
  local timeoutFull = Game.design.invaders.formation.shooting.timeoutFull
  local timeoutEmpty = Game.design.invaders.formation.shooting.timeoutEmpty
  local timeoutLevel = max(timeoutEmpty, timeoutFull - (game.level - 1) * Game.design.invaders.formation.shooting.timeoutFullDecreasePerLevel)
  local timeoutAverage = timeoutEmpty + fullRatio * (timeoutLevel - timeoutEmpty)
  local timeoutFactor = 1 + (rnd(2) - 1) * Game.design.invaders.formation.shooting.variability

  self.shootingTimeout = timeoutAverage * timeoutFactor
end

function Invaders:shoot()
  local shooters = {}

  local shootByRow = invaders.shootingOrientation == Orientations.Vertical
  local firstCount, secondCount

  if shootByRow then
    firstCount = Game.design.invaders.formation.columns
    secondCount = Game.design.invaders.formation.rows
  else
    firstCount = Game.design.invaders.formation.rows
    secondCount = Game.design.invaders.formation.columns
  end

  for firstNumber = 1, firstCount do
    local shooter

    for secondNumber = 1, secondCount do
      if shootByRow then
        if Game.design.invaderProjectiles.movement == Directions.Up then
          formationSpot = self.formation[firstNumber][secondNumber]
        else
          formationSpot = self.formation[firstNumber][self.rows - secondNumber + 1]
        end
      else
        if Game.design.invaderProjectiles.movement == Directions.Up then
          formationSpot = self.formation[secondNumber][firstNumber]
        else
          formationSpot = self.formation[self.columns - secondNumber + 1][firstNumber]
        end
      end

      if formationSpot.invader ~= nil and formationSpot.invader.alive then
        shooter = formationSpot.invader
        break
      end
    end

    if shooter then
      add(shooters, shooter)
    end
  end

  if #shooters > 0 then
    local randomShooter = shooters[1 + flr(rnd(#shooters))]
    scene:addInvaderProjectile(randomShooter)
  end
end

-- Update

function Invaders:update()
  -- Spawn invaders.
  if not self.spawnedAll then
    if Game.design.invaders.formation.spawnDelay > 0 then
      self.spawnDuration = self.spawnDuration + dt
      if self.spawnDuration >= Game.design.invaders.formation.spawnDelay then
        self:spawnNextInvader()
        self.spawnDuration = 0
      end
    else
      while not self.spawnedAll do
        self:spawnNextInvader()
      end
    end
  end

  -- Update alive count.
  invaders.aliveCount = 0
  for rowNumber = 1, invaders.rows do invaders.aliveCountByRows[rowNumber] = 0 end
  for columnNumber = 1, invaders.columns do invaders.aliveCountByColumns[columnNumber] = 0 end

  for columnNumber = 1, invaders.columns do
    for rowNumber = 1, invaders.rows do
      if invaders.formation[columnNumber][rowNumber].invader ~= nil and invaders.formation[columnNumber][rowNumber].invader.alive then
        invaders.aliveCount = invaders.aliveCount + 1
        invaders.aliveCountByRows[rowNumber] = invaders.aliveCountByRows[rowNumber] + 1
        invaders.aliveCountByColumns[columnNumber] = invaders.aliveCountByColumns[columnNumber] + 1
      end
    end
  end

  invaders.aliveRowsCount = 0
  invaders.aliveColumnsCount = 0
  for rowNumber = 1, invaders.rows do
    if invaders.aliveCountByRows[rowNumber] > 0 then
      invaders.aliveRowsCount = invaders.aliveRowsCount + 1
    end
  end
  for columnNumber = 1, invaders.columns do
    if invaders.aliveCountByColumns[columnNumber] > 0 then
      invaders.aliveColumnsCount = invaders.aliveColumnsCount + 1
    end
  end

  -- Update bounds.
  invaders.bounds = {
    left = -flr((invaders.fullFormationWidth - 1) / 2),
    top = -flr((invaders.fullFormationHeight - 1) / 2)
  }

  invaders.bounds.right = invaders.bounds.left + invaders.fullFormationWidth - 1
  invaders.bounds.bottom = invaders.bounds.top + invaders.fullFormationHeight - 1

  for rowNumber = 1, invaders.rows do
    if invaders.aliveCountByRows[rowNumber] > 0 then
      break
    else
      invaders.bounds.top = invaders.bounds.top + Invader.sprite.bounds.height + Game.design.invaders.formation.verticalSpacing
    end
  end

  for rowNumber = invaders.rows, 1, -1 do
    if invaders.aliveCountByRows[rowNumber] > 0 then
      break
    else
      invaders.bounds.bottom = invaders.bounds.bottom - Invader.sprite.bounds.height - Game.design.invaders.formation.verticalSpacing
    end
  end

  for columnNumber = 1, invaders.columns do
    if invaders.aliveCountByColumns[columnNumber] > 0 then
      break
    else
      invaders.bounds.left = invaders.bounds.left + Invader.sprite.bounds.width + Game.design.invaders.formation.horizontalSpacing
    end
  end

  for columnNumber = invaders.columns, 1, -1 do
    if invaders.aliveCountByColumns[columnNumber] > 0 then
      break
    else
      invaders.bounds.right = invaders.bounds.right - Invader.sprite.bounds.width - Game.design.invaders.formation.horizontalSpacing
    end
  end

  -- Move invaders.
  if game:isGameplayActive() then
    if not self:individualMovementHasValidInvader() then
      -- Formation movement
      local attack = false

      if invaders.moveDirection == Directions.Down then
        self.y = self.y + Game.design.invaders.formation.verticalSpeed

        if self.y + self.bounds.bottom >= Game.design.playfieldBounds.bottom or Game.design.invaders.formation.verticalSpeed == 0 then
          self.y = self.y - Game.design.invaders.formation.verticalSpeed
          invaders.moveDirection = Directions.Up
          attack = true
        end

      elseif invaders.moveDirection == Directions.Up then
        self.y = self.y - Game.design.invaders.formation.verticalSpeed

        if self.y + self.bounds.top <= Game.design.playfieldBounds.top or Game.design.invaders.formation.verticalSpeed == 0 then
          self.y = self.y + Game.design.invaders.formation.verticalSpeed
          invaders.moveDirection = Directions.Down
          attack = true
        end

      elseif invaders.moveDirection == Directions.Right then
        self.x = self.x + Game.design.invaders.formation.horizontalSpeed

        if self.x + self.bounds.right >= Game.design.playfieldBounds.right or Game.design.invaders.formation.horizontalSpeed == 0 then
          self.x = self.x - Game.design.invaders.formation.horizontalSpeed
          invaders.moveDirection = Directions.Left
          attack = true
        end

      elseif invaders.moveDirection == Directions.Left then
        self.x = self.x - Game.design.invaders.formation.horizontalSpeed

        if self.x + self.bounds.left <= Game.design.playfieldBounds.left or Game.design.invaders.formation.horizontalSpeed == 0  then
          self.x = self.x + Game.design.invaders.formation.horizontalSpeed
          invaders.moveDirection = Directions.Right
          attack = true
        end
      end

      if attack then
        if Game.design.invaders.attackDirection == Directions.Down then
          self.y = self.y + Game.design.invaders.formation.verticalSpeed

        elseif Game.design.invaders.attackDirection == Directions.Up then
          self.y = self.y - Game.design.invaders.formation.verticalSpeed

        elseif Game.design.invaders.attackDirection == Directions.Right then
          self.x = self.x + Game.design.invaders.formation.horizontalSpeed

        elseif Game.design.invaders.attackDirection == Directions.Left then
          self.x = self.x - Game.design.invaders.formation.horizontalSpeed

        end
      end

      -- Reset individual movement.
      invaders:resetIndividualMovement()
    end

    local moveCount

    if Game.design.invaders.formation.movement == DesignOptions.Invaders.Formation.Movement.Individual then
      moveCount = 1

    else
      moveCount = invaders.aliveCount
    end

    for moveIndex = 1, moveCount do
      self:moveNextInvader()
    end

    -- Shoot.
    if self.aliveCount > 0 and #scene.invaderProjectiles < Game.design.invaderProjectiles.maxCount then
      self.shootingDuration = self.shootingDuration + dt
      if self.shootingDuration >= self.shootingTimeout then
        self:shoot()
        self.shootingDuration = 0
        self:setShootingTimeout()
      end
    end
  end
end
