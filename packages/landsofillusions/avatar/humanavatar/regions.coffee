AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.HumanAvatar.Regions =

  # Head

  Head: new LOI.Engine.RenderingRegion
    id: 'Head'
    bounds: new AE.Rectangle 0, 0, 30, 20
    origin:
      landmark: 'atlas'
      x: 15
      y: 15

  Hair: new LOI.Engine.RenderingRegion
    id: 'Hair'
    multipleRegions: ['HairFront', 'HairBack']

  HairFront: new LOI.Engine.RenderingRegion
    id: 'HairFront'
    bounds: new AE.Rectangle 0, 0, 30, 20
    origin:
      landmark: 'atlas'
      x: 15
      y: 15

  HairBack: new LOI.Engine.RenderingRegion
    id: 'HairBack'
    bounds: new AE.Rectangle 0, 0, 30, 20
    origin:
      landmark: 'atlas'
      x: 15
      y: 15

  # Torso

  Torso: new LOI.Engine.RenderingRegion
    id: 'Torso'
    bounds: new AE.Rectangle 0, 20, 30, 30
    origin:
      landmark: 'navel'
      x: 15
      y: 15

  SexOrgan: new LOI.Engine.RenderingRegion
    id: 'SexOrgan'
    bounds: new AE.Rectangle 0, 20, 30, 30
    origin:
      landmark: 'pubicSymphysis'
      x: 15
      y: 21

  # Arms

  RightUpperArm: new LOI.Engine.RenderingRegion
    id: 'RightUpperArm'
    bounds: new AE.Rectangle 30, 0, 10, 20
    origin:
      landmark: 'shoulder'
      x: 5
      y: 10
    flipHorizontal: true

  LeftUpperArm: new LOI.Engine.RenderingRegion
    id: 'LeftUpperArm'
    bounds: new AE.Rectangle 40, 0, 10, 20
    origin:
      landmark: 'shoulder'
      x: 5
      y: 10

  UpperArms: new LOI.Engine.RenderingRegion
    id: 'UpperArms'
    multipleRegions: ['LeftUpperArm', 'RightUpperArm']

  RightLowerArm: new LOI.Engine.RenderingRegion
    id: 'RightLowerArm'
    bounds: new AE.Rectangle 30, 20, 10, 20
    origin:
      landmark: 'elbow'
      x: 5
      y: 10
    flipHorizontal: true

  LeftLowerArm: new LOI.Engine.RenderingRegion
    id: 'LeftLowerArm'
    bounds: new AE.Rectangle 40, 20, 10, 20
    origin:
      landmark: 'elbow'
      x: 5
      y: 10

  LowerArms: new LOI.Engine.RenderingRegion
    id: 'LowerArms'
    multipleRegions: ['LeftLowerArm', 'RightLowerArm']

  RightHand: new LOI.Engine.RenderingRegion
    id: 'RightHand'
    bounds: new AE.Rectangle 30, 40, 10, 20
    origin:
      landmark: 'wrist'
      x: 5
      y: 10
    flipHorizontal: true

  LeftHand: new LOI.Engine.RenderingRegion
    id: 'LeftHand'
    bounds: new AE.Rectangle 40, 40, 10, 20
    origin:
      landmark: 'wrist'
      x: 5
      y: 10

  Hands: new LOI.Engine.RenderingRegion
    id: 'Hands'
    multipleRegions: ['RightHand', 'LeftHand']

  # Legs

  RightUpperLeg: new LOI.Engine.RenderingRegion
    id: 'RightUpperLeg'
    bounds: new AE.Rectangle 50, 0, 20, 30
    origin:
      landmark: 'acetabulum'
      x: 10
      y: 10
    flipHorizontal: true

  LeftUpperLeg: new LOI.Engine.RenderingRegion
    id: 'LeftUpperLeg'
    bounds: new AE.Rectangle 70, 0, 20, 30
    origin:
      landmark: 'acetabulum'
      x: 10
      y: 10

  UpperLegs: new LOI.Engine.RenderingRegion
    id: 'UpperLegs'
    multipleRegions: ['RightUpperLeg', 'LeftUpperLeg']

  RightLowerLeg: new LOI.Engine.RenderingRegion
    id: 'RightLowerLeg'
    bounds: new AE.Rectangle 50, 20, 20, 20
    origin:
      landmark: 'knee'
      x: 10
      y: 10
    flipHorizontal: true

  LeftLowerLeg: new LOI.Engine.RenderingRegion
    id: 'LeftLowerLeg'
    bounds: new AE.Rectangle 70, 20, 20, 20
    origin:
      landmark: 'knee'
      x: 10
      y: 10

  LowerLegs: new LOI.Engine.RenderingRegion
    id: 'LowerLegs'
    multipleRegions: ['RightLowerLeg', 'LeftLowerLeg']

  RightFoot: new LOI.Engine.RenderingRegion
    id: 'RightFoot'
    bounds: new AE.Rectangle 50, 40, 20, 20
    origin:
      landmark: 'ankle'
      x: 10
      y: 10
    flipHorizontal: true

  LeftFoot: new LOI.Engine.RenderingRegion
    id: 'LeftFoot'
    bounds: new AE.Rectangle 70, 40, 20, 20
    origin:
      landmark: 'ankle'
      x: 10
      y: 10

  Feet: new LOI.Engine.RenderingRegion
    id: 'Feet'
    multipleRegions: ['RightFoot', 'LeftFoot']
