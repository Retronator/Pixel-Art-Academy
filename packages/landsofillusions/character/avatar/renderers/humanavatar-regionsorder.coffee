LOI = LandsOfIllusions

LOI.Character.Avatar.Renderers.HumanAvatar.regionsOrder =
  "#{LOI.Engine.RenderingSides.Keys.Front}": [
    LOI.HumanAvatar.Regions.HairBehind

    LOI.HumanAvatar.Regions.RightUpperArm
    LOI.HumanAvatar.Regions.LeftUpperArm

    LOI.HumanAvatar.Regions.Torso
    LOI.HumanAvatar.Regions.HairMiddle
    LOI.HumanAvatar.Regions.Head
    LOI.HumanAvatar.Regions.HairFront

    LOI.HumanAvatar.Regions.RightLowerArm
    LOI.HumanAvatar.Regions.RightHand

    LOI.HumanAvatar.Regions.LeftLowerArm
    LOI.HumanAvatar.Regions.LeftHand

    LOI.HumanAvatar.Regions.RightFoot
    LOI.HumanAvatar.Regions.RightLowerLeg
    LOI.HumanAvatar.Regions.RightUpperLeg

    LOI.HumanAvatar.Regions.LeftFoot
    LOI.HumanAvatar.Regions.LeftLowerLeg
    LOI.HumanAvatar.Regions.LeftUpperLeg

    LOI.HumanAvatar.Regions.SexOrgan
  ]
  
  "#{LOI.Engine.RenderingSides.Keys.FrontLeft}": [
    LOI.HumanAvatar.Regions.HairBehind

    LOI.HumanAvatar.Regions.RightUpperArm
    LOI.HumanAvatar.Regions.RightLowerArm
    LOI.HumanAvatar.Regions.RightHand

    LOI.HumanAvatar.Regions.RightFoot
    LOI.HumanAvatar.Regions.RightLowerLeg
    LOI.HumanAvatar.Regions.RightUpperLeg

    LOI.HumanAvatar.Regions.Torso
    LOI.HumanAvatar.Regions.SexOrgan
    LOI.HumanAvatar.Regions.HairMiddle
    LOI.HumanAvatar.Regions.Head
    LOI.HumanAvatar.Regions.HairFront

    LOI.HumanAvatar.Regions.LeftFoot
    LOI.HumanAvatar.Regions.LeftLowerLeg
    LOI.HumanAvatar.Regions.LeftUpperLeg
    
    LOI.HumanAvatar.Regions.LeftUpperArm
    LOI.HumanAvatar.Regions.LeftLowerArm
    LOI.HumanAvatar.Regions.LeftHand
  ]
  
  "#{LOI.Engine.RenderingSides.Keys.Left}": [
    LOI.HumanAvatar.Regions.HairBehind
    
    LOI.HumanAvatar.Regions.RightUpperArm
    LOI.HumanAvatar.Regions.RightLowerArm
    LOI.HumanAvatar.Regions.RightHand

    LOI.HumanAvatar.Regions.RightFoot
    LOI.HumanAvatar.Regions.RightLowerLeg
    LOI.HumanAvatar.Regions.RightUpperLeg

    LOI.HumanAvatar.Regions.Torso
    LOI.HumanAvatar.Regions.SexOrgan
    LOI.HumanAvatar.Regions.HairMiddle
    LOI.HumanAvatar.Regions.Head
    LOI.HumanAvatar.Regions.HairFront

    LOI.HumanAvatar.Regions.LeftFoot
    LOI.HumanAvatar.Regions.LeftLowerLeg
    LOI.HumanAvatar.Regions.LeftUpperLeg
    
    LOI.HumanAvatar.Regions.LeftUpperArm
    LOI.HumanAvatar.Regions.LeftLowerArm
    LOI.HumanAvatar.Regions.LeftHand
  ]

  "#{LOI.Engine.RenderingSides.Keys.BackLeft}": [
    LOI.HumanAvatar.Regions.HairBehind

    LOI.HumanAvatar.Regions.RightHand
    LOI.HumanAvatar.Regions.RightLowerArm
    LOI.HumanAvatar.Regions.RightUpperArm

    LOI.HumanAvatar.Regions.SexOrgan

    LOI.HumanAvatar.Regions.RightFoot
    LOI.HumanAvatar.Regions.RightLowerLeg
    LOI.HumanAvatar.Regions.RightUpperLeg

    LOI.HumanAvatar.Regions.LeftFoot
    LOI.HumanAvatar.Regions.LeftLowerLeg
    LOI.HumanAvatar.Regions.LeftUpperLeg

    LOI.HumanAvatar.Regions.Head
    LOI.HumanAvatar.Regions.HairMiddle
    LOI.HumanAvatar.Regions.Torso
    LOI.HumanAvatar.Regions.HairFront

    LOI.HumanAvatar.Regions.LeftHand
    LOI.HumanAvatar.Regions.LeftLowerArm
    LOI.HumanAvatar.Regions.LeftUpperArm
  ]

  "#{LOI.Engine.RenderingSides.Keys.Back}": [
    LOI.HumanAvatar.Regions.HairBehind

    LOI.HumanAvatar.Regions.RightUpperArm
    LOI.HumanAvatar.Regions.RightLowerArm
    LOI.HumanAvatar.Regions.RightHand

    LOI.HumanAvatar.Regions.SexOrgan

    LOI.HumanAvatar.Regions.RightFoot
    LOI.HumanAvatar.Regions.RightLowerLeg
    LOI.HumanAvatar.Regions.RightUpperLeg

    LOI.HumanAvatar.Regions.LeftFoot
    LOI.HumanAvatar.Regions.LeftLowerLeg
    LOI.HumanAvatar.Regions.LeftUpperLeg

    LOI.HumanAvatar.Regions.LeftUpperArm
    LOI.HumanAvatar.Regions.LeftLowerArm
    LOI.HumanAvatar.Regions.LeftHand

    LOI.HumanAvatar.Regions.Head
    LOI.HumanAvatar.Regions.HairMiddle
    LOI.HumanAvatar.Regions.Torso
    LOI.HumanAvatar.Regions.HairFront
  ]

# Last three sides are symmetric.

symmetricSides = [
  LOI.Engine.RenderingSides.Keys.FrontLeft
  LOI.Engine.RenderingSides.Keys.Left
  LOI.Engine.RenderingSides.Keys.BackLeft
]

for side in symmetricSides
  mirrorSide = LOI.Engine.RenderingSides.mirrorSides[side]

  order = for region in LOI.Character.Avatar.Renderers.HumanAvatar.regionsOrder[side]
    mirrorId = region.id.replace('Left', '_').replace('Right', 'Left').replace('_', 'Right')
    LOI.HumanAvatar.Regions[mirrorId]

  LOI.Character.Avatar.Renderers.HumanAvatar.regionsOrder[mirrorSide] = order
