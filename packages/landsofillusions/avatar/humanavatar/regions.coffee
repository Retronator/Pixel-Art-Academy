AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.HumanAvatar.Regions =

  # Head

  Head: new LOI.Engine.RenderingRegion
    id: 'Head'
    bounds: new AE.Rectangle 0, 96, 16, 16
    origin:
      landmark: 'atlas'
      x: 8
      y: 8

  Hair: new LOI.Engine.RenderingRegion
    id: 'Hair'
    multipleRegions: ['HairFront', 'HairMiddle', 'HairBehind']

  HairFront: new LOI.Engine.RenderingRegion
    id: 'HairFront'
    bounds: new AE.Rectangle 0, 0, 32, 32
    origin:
      landmark: 'headCenter'
      x: 16
      y: 16

  HairMiddle: new LOI.Engine.RenderingRegion
    id: 'HairMiddle'
    bounds: new AE.Rectangle 32, 0, 32, 32
    origin:
      landmark: 'headCenter'
      x: 16
      y: 16

  HairBehind: new LOI.Engine.RenderingRegion
    id: 'HairBehind'
    bounds: new AE.Rectangle 32, 32, 32, 32
    origin:
      landmark: 'headCenter'
      x: 16
      y: 16

  # Torso

  Torso: new LOI.Engine.RenderingRegion
    id: 'Torso'
    bounds: new AE.Rectangle 16, 64, 24, 32
    origin:
      landmark: 'navel'
      x: 12
      y: 16

  SexOrgan: new LOI.Engine.RenderingRegion
    id: 'SexOrgan'
    bounds: new AE.Rectangle 0, 112, 16, 16
    origin:
      landmark: 'pubicSymphysis'
      x: 8
      y: 8

  TorsoClothes: new LOI.Engine.RenderingRegion
    id: 'TorsoClothes'
    bounds: new AE.Rectangle 40, 64, 24, 48
    origin:
      landmark: 'navel'
      x: 12
      y: 16

  # Arms

  RightUpperArm: new LOI.Engine.RenderingRegion
    id: 'RightUpperArm'
    bounds: new AE.Rectangle 0, 32, 16, 16
    origin:
      landmark: 'shoulder'
      x: 8
      y: 8
    flipHorizontal: true

  LeftUpperArm: new LOI.Engine.RenderingRegion
    id: 'LeftUpperArm'
    bounds: new AE.Rectangle 16, 32, 16, 16
    origin:
      landmark: 'shoulder'
      x: 8
      y: 8

  UpperArms: new LOI.Engine.RenderingRegion
    id: 'UpperArms'
    multipleRegions: ['LeftUpperArm', 'RightUpperArm']

  RightLowerArm: new LOI.Engine.RenderingRegion
    id: 'RightLowerArm'
    bounds: new AE.Rectangle 0, 48, 16, 16
    origin:
      landmark: 'elbow'
      x: 8
      y: 8
    flipHorizontal: true

  LeftLowerArm: new LOI.Engine.RenderingRegion
    id: 'LeftLowerArm'
    bounds: new AE.Rectangle 16, 48, 16, 16
    origin:
      landmark: 'elbow'
      x: 8
      y: 8

  LowerArms: new LOI.Engine.RenderingRegion
    id: 'LowerArms'
    multipleRegions: ['LeftLowerArm', 'RightLowerArm']

  RightHand: new LOI.Engine.RenderingRegion
    id: 'RightHand'
    bounds: new AE.Rectangle 0, 64, 16, 16
    origin:
      landmark: 'wrist'
      x: 8
      y: 8
    flipHorizontal: true

  LeftHand: new LOI.Engine.RenderingRegion
    id: 'LeftHand'
    bounds: new AE.Rectangle 0, 80, 16, 16
    origin:
      landmark: 'wrist'
      x: 8
      y: 8

  Hands: new LOI.Engine.RenderingRegion
    id: 'Hands'
    multipleRegions: ['RightHand', 'LeftHand']

  # Legs

  RightUpperLeg: new LOI.Engine.RenderingRegion
    id: 'RightUpperLeg'
    bounds: new AE.Rectangle 0, 160, 16, 24
    origin:
      landmark: 'acetabulum'
      x: 8
      y: 8
    flipHorizontal: true

  LeftUpperLeg: new LOI.Engine.RenderingRegion
    id: 'LeftUpperLeg'
    bounds: new AE.Rectangle 16, 160, 16, 24
    origin:
      landmark: 'acetabulum'
      x: 8
      y: 8

  UpperLegs: new LOI.Engine.RenderingRegion
    id: 'UpperLegs'
    multipleRegions: ['RightUpperLeg', 'LeftUpperLeg']

  RightLowerLeg: new LOI.Engine.RenderingRegion
    id: 'RightLowerLeg'
    bounds: new AE.Rectangle 0, 184, 16, 24
    origin:
      landmark: 'knee'
      x: 8
      y: 8
    flipHorizontal: true

  LeftLowerLeg: new LOI.Engine.RenderingRegion
    id: 'LeftLowerLeg'
    bounds: new AE.Rectangle 16, 184, 16, 24
    origin:
      landmark: 'knee'
      x: 8
      y: 8

  LowerLegs: new LOI.Engine.RenderingRegion
    id: 'LowerLegs'
    multipleRegions: ['RightLowerLeg', 'LeftLowerLeg']

  RightFoot: new LOI.Engine.RenderingRegion
    id: 'RightFoot'
    bounds: new AE.Rectangle 0, 128, 24, 16
    origin:
      landmark: 'ankle'
      x: 12
      y: 6
    flipHorizontal: true

  LeftFoot: new LOI.Engine.RenderingRegion
    id: 'LeftFoot'
    bounds: new AE.Rectangle 0, 144, 24, 16
    origin:
      landmark: 'ankle'
      x: 12
      y: 6

  Feet: new LOI.Engine.RenderingRegion
    id: 'Feet'
    multipleRegions: ['RightFoot', 'LeftFoot']
