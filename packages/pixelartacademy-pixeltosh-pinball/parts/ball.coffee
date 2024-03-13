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

  @initialize()

  createAvatar: ->
    new Pinball.Part.Avatar.Sphere @,
      mass: 0.086 # kg
      radius: 0.0135
