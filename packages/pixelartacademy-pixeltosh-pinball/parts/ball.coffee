LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Parts.Ball extends Pinball.Part
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Parts.Ball'
  @fullName: -> "ball"
  @description: ->
    "
      Marks the place where the ball will spawn.
    "
    
  @imageUrl: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/ball.png'
  
  @avatarShapes: -> [
    Pinball.Part.Avatar.Sphere
  ]
  
  @initialize()

  createAvatar: ->
    new Pinball.Part.Avatar @,
      mass: 0.086 # kg
      # Coefficients of restitution and friction will be multiplied with the
      # collider so we set it to 1 on the ball to only use the value on the collider.
      restitution: 1
      friction: 1
      # Coefficient of rolling friction will be added to the collider so
      # we set it to 0 on the ball to only use the value on the collider.
      rollingFriction: 0
