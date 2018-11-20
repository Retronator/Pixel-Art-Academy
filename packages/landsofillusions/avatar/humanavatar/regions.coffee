AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.HumanAvatar.Regions =
  Head: new LOI.Engine.RenderingRegion
    id: 'Head'
    bounds: new AE.Rectangle 0, 0, 20, 20
    origin:
      landmark: 'atlas'
      x: 15
      y: 15

  Torso: new LOI.Engine.RenderingRegion
    id: 'Torso'
    bounds: new AE.Rectangle 0, 20, 20, 30
    origin:
      landmark: 'navel'
      x: 15
      y: 15

  RightArm: new LOI.Engine.RenderingRegion
    id: 'RightArm'
    bounds: new AE.Rectangle 30, 0, 10, 30
    origin:
      landmark: 'shoulderRight'
      x: 5
      y: 10
    flipHorizontal: true

  LeftArm: new LOI.Engine.RenderingRegion
    id: 'LeftArm'
    bounds: new AE.Rectangle 40, 0, 10, 30
    origin:
      landmark: 'shoulderLeft'
      x: 5
      y: 10

  Arms: new LOI.Engine.RenderingRegion
    id: 'Arms'
    multipleRegions: ['LeftArm', 'RightArm']
