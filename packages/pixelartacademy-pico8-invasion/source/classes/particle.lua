Particle = {}
Particle.__index = Particle

maxParticleSpeed = 100

function Particle:new(x, y, color, explosionX, explosionY)
  local particle = setmetatable({}, Particle)

  particle.x = x
  particle.y = y
  particle.color = color

  local dX = x - explosionX + rnd(2) - 1
  local dY = y - explosionY + rnd(2) - 1
  local d = sqrt(dX * dX + dY * dY)
  local speed = mid(-maxParticleSpeed, 100 / sqrt(d), maxParticleSpeed)

  particle.velocityX = dX / d * speed + rnd(10) - 5
  particle.velocityY = dY / d * speed + rnd(10) - 5

  return particle
end

function Particle:update()
  self.velocityY = self.velocityY + 10 * dt
  self.x = self.x + self.velocityX * dt
  self.y = self.y + self.velocityY * dt
end

function Particle:draw()
  pset(self.x, self.y, self.color)
end
