LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Parts.Wall extends Pinball.Part
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Parts.Wall'
  @fullName: -> "wall"
  @description: ->
    "
      The edge of the playfield.
    "
    
  @imageUrl: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/wall.png'
  
  @avatarShapes: -> [
    Pinball.Part.Avatar.Extrusion
  ]
  
  @initialize()

  createAvatar: ->
    new Pinball.Part.Avatar @,
      mass: 0
      height: 0.05
      restitution: 0.9
      friction: 0.01
