LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Parts.Cube extends Pinball.Part
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Parts.Cube'
  @fullName: -> "cube"
  @description: ->
    "
      Just a test cube.
    "

  @initialize()

  createAvatar: ->
    new Pinball.Part.Avatar.Box @,
      mass: 0.11 # 5 cm³ of plaster at 849 kg/m³
      friction: 1
      size:
        x: 0.05, y: 0.05, z: 0.05
