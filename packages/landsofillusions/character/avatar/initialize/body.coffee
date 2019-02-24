LOI = LandsOfIllusions

LOI.Character.Part.registerClasses
  Avatar:
    Body: new LOI.Character.Part
      type: 'Avatar.Body'
      name: 'body'
      properties:
        # Skin must be created first because other renderers depend on it.
        skin: new LOI.Character.Avatar.Properties.Color
          name: 'skin'
          colorsPresetName: 'Skin'
          default:
            hue: 3
            shade: 4
        arms: new LOI.Character.Part.Property.OneOf
          name: 'arms'
          type: 'Avatar.Body.Arms'
        torso: new LOI.Character.Part.Property.OneOf
          name: 'torso'
          type: 'Avatar.Body.Torso'
        head: new LOI.Character.Part.Property.OneOf
          name: 'head'
          type: 'Avatar.Body.Head'
        legs: new LOI.Character.Part.Property.OneOf
          name: 'legs'
          type: 'Avatar.Body.Legs'
      renderer: new LOI.Character.Avatar.Renderers.Body
        origin:
          landmark: 'navel'

LOI.Character.Part.registerClasses
  Avatar:
    Body:
      Head: new LOI.Character.Part
        type: 'Avatar.Body.Head'
        name: 'head'
        properties:
          shape: new LOI.Character.Part.Property.OneOf
            name: 'shape'
            type: 'Avatar.Body.HeadShape'
          eyes: new LOI.Character.Part.Property.OneOf
            name: 'eyes'
            type: 'Avatar.Body.Eyes'
          hair: new LOI.Character.Part.Property.Array
            name: 'hair'
            type: 'Avatar.Body.Hair'
          facialHair: new LOI.Character.Part.Property.Array
            name: 'facial hair'
            type: 'Avatar.Body.FacialHair'
        renderer: new LOI.Character.Avatar.Renderers.Head
          region: LOI.HumanAvatar.Regions.Head
          origin:
            landmark: 'atlas'
            x: 0
            y: 2

      Hair: new LOI.Character.Part
        type: 'Avatar.Body.Hair'
        name: 'hair'
        properties:
          color: new LOI.Character.Avatar.Properties.Color
            name: 'color'
            colorsPresetName: 'Default'
            default:
              hue: 0
              shade: 2
          shapes: new LOI.Character.Part.Property.Array
            name: 'shapes'
            type: 'Avatar.Body.HairShape'

      HairShape: new LOI.Character.Avatar.Parts.Shape
        type: 'Avatar.Body.HairShape'
        name: 'hair shape'
        properties:
          region: new LOI.Character.Part.Property.String
            name: 'region'
            values: LOI.HumanAvatar.Regions.Hair.options.multipleRegions
        materials:
          hair: (part) ->
            hairPart = part.ancestorPartOfType LOI.Character.Part.Types.Avatar.Body.Hair
            hairPart.properties.color
        landmarks:
          forehead: new LOI.Character.Avatar.Landmark.Position
            name: 'forehead'

      FacialHair: new LOI.Character.Part
        type: 'Avatar.Body.FacialHair'
        name: 'facial hair'
        properties:
          color: new LOI.Character.Avatar.Properties.Color
            name: 'color'
            colorsPresetName: 'Default'
            default:
              hue: 0
              shade: 2
          shapes: new LOI.Character.Part.Property.Array
            name: 'shapes'
            type: 'Avatar.Body.FacialHairShape'

      FacialHairShape: new LOI.Character.Avatar.Parts.Shape
        type: 'Avatar.Body.FacialHairShape'
        name: 'facial hair shape'
        renderer: new LOI.Character.Avatar.Renderers.Shape
          origin:
            landmark: 'mouth'
        materials:
          facialHair: (part) ->
            facialHairPart = part.ancestorPartOfType LOI.Character.Part.Types.Avatar.Body.FacialHair
            facialHairPart.properties.color
        landmarks:
          mouth: new LOI.Character.Avatar.Landmark.Position
            name: 'mouth'

      HeadShape: new LOI.Character.Avatar.Parts.SkinShape
        type: 'Avatar.Body.HeadShape'
        name: 'head shape'
        default: 'landsofillusions/character/avatar/body/head/2/Head 2'
        renderer: new LOI.Character.Avatar.Renderers.Shape
          origin:
            landmark: 'atlas'
        landmarks:
          atlas: new LOI.Character.Avatar.Landmark.Position
            name: 'atlas'
          eyeLeft: new LOI.Character.Avatar.Landmark.Position
            name: 'eyeLeft'
          eyeRight: new LOI.Character.Avatar.Landmark.Position
            name: 'eyeRight'
          forehead: new LOI.Character.Avatar.Landmark.Position
            name: 'forehead'
          mouth: new LOI.Character.Avatar.Landmark.Position
            name: 'mouth'

      Eyes: new LOI.Character.Part
        type: 'Avatar.Body.Eyes'
        name: 'eyes'
        properties:
          # Iris must be defined first since shape depends on it.
          iris: new LOI.Character.Avatar.Properties.Color
            name: 'iris'
            colorsPresetName: 'Default'
            default:
              hue: 0
              shade: 4
          shape: new LOI.Character.Part.Property.OneOf
            name: 'shape'
            type: 'Avatar.Body.EyeShape'

      EyeShape: new LOI.Character.Avatar.Parts.Shape
        type: 'Avatar.Body.EyeShape'
        name: 'eye shape'
        renderer: new LOI.Character.Avatar.Renderers.Shape
          origin:
            landmark: 'eyeCenter'
            x: 0
            y: 0
        materials:
          iris: (part) ->
            eyesPart = part.ancestorPartOfType LOI.Character.Part.Types.Avatar.Body.Eyes
            eyesPart.properties.iris
        landmarks:
          eyeCenter: new LOI.Character.Avatar.Landmark.Position
            name: 'eyeCenter'

      Torso: new LOI.Character.Part
        type: 'Avatar.Body.Torso'
        name: 'torso'
        properties:
          groin: new LOI.Character.Part.Property.OneOf
            name: 'groin'
            type: 'Avatar.Body.Groin'
          abdomen: new LOI.Character.Part.Property.OneOf
            name: 'abdomen'
            type: 'Avatar.Body.Abdomen'
          chest: new LOI.Character.Part.Property.OneOf
            name: 'chest'
            type: 'Avatar.Body.Chest'
          neck: new LOI.Character.Part.Property.OneOf
            name: 'neck'
            type: 'Avatar.Body.Neck'
        renderer: new LOI.Character.Avatar.Renderers.Default
          region: LOI.HumanAvatar.Regions.Torso
          origin:
            landmark: 'navel'

      Neck: new LOI.Character.Part
        type: 'Avatar.Body.Neck'
        name: 'neck'
        properties:
          shape: new LOI.Character.Part.Property.OneOf
            name: 'shape'
            type: 'Avatar.Body.NeckShape'

      NeckShape: new LOI.Character.Avatar.Parts.SkinShape
        type: 'Avatar.Body.NeckShape'
        name: 'neck shape'
        default: 'landsofillusions/character/avatar/body/torso/neck/Neck'
        renderer: new LOI.Character.Avatar.Renderers.Shape
          origin:
            landmark: 'atlas'
            x: 0
            y: -1
        landmarks:
          atlas: new LOI.Character.Avatar.Landmark.Position
            name: 'atlas'
          suprasternalNotch: new LOI.Character.Avatar.Landmark.Position
            name: 'suprasternalNotch'

      Chest: new LOI.Character.Part
        type: 'Avatar.Body.Chest'
        name: 'chest'
        properties:
          shape: new LOI.Character.Part.Property.OneOf
            name: 'shape'
            type: 'Avatar.Body.ChestShape'
          breasts: new LOI.Character.Part.Property.OneOf
            name: 'breasts'
            type: 'Avatar.Body.Breasts'
        renderer: new LOI.Character.Avatar.Renderers.Chest
          origin:
            landmark: 'xiphoid'

      ChestShape: new LOI.Character.Avatar.Parts.SkinShape
        type: 'Avatar.Body.ChestShape'
        name: 'chest shape'
        default: 'landsofillusions/character/avatar/body/torso/chest/mesomorph/Chest mesomorph'
        renderer: new LOI.Character.Avatar.Renderers.Shape
          origin:
            landmark: 'xiphoid'
            x: 0
            y: 3.5
        landmarks:
          xiphoid: new LOI.Character.Avatar.Landmark.Position
            name: 'xiphoid'
          suprasternalNotch: new LOI.Character.Avatar.Landmark.Position
            name: 'suprasternalNotch'
          shoulderLeft: new LOI.Character.Avatar.Landmark.Position
            name: 'shoulderLeft'
          shoulderRight: new LOI.Character.Avatar.Landmark.Position
            name: 'shoulderRight'
          breastLeft: new LOI.Character.Avatar.Landmark.Position
            name: 'breastLeft'
          breastRight: new LOI.Character.Avatar.Landmark.Position
            name: 'breastRight'

      Breasts: new LOI.Character.Part
        type: 'Avatar.Body.Breasts'
        name: 'breasts'
        properties:
          nippleShade: new LOI.Character.Avatar.Properties.RelativeColorShade
            name: 'nipple shade'
            baseColor: (part) ->
              bodyPart = part.ancestorPartOfType LOI.Character.Part.Types.Avatar.Body
              bodyPart.properties.skin
          topShape: new LOI.Character.Part.Property.OneOf
            name: 'top shape'
            type: 'Avatar.Body.BreastShapeTop'
          bottomShape: new LOI.Character.Part.Property.OneOf
            name: 'bottom shape'
            type: 'Avatar.Body.BreastShapeBottom'
          nippleShape: new LOI.Character.Part.Property.OneOf
            name: 'nipple shape'
            type: 'Avatar.Body.NippleShape'
        renderer: new LOI.Character.Avatar.Renderers.Default
          origin:
            landmark: 'breastCenter'

      BreastShapeTop: new LOI.Character.Avatar.Parts.SkinShape
        type: 'Avatar.Body.BreastShapeTop'
        name: 'breasts shape top'
        default: 'landsofillusions/character/avatar/body/torso/chest/breasts/top/2/Breast top 2'
        landmarks:
          breastCenter: new LOI.Character.Avatar.Landmark.Position
            name: 'breastCenter'
          nipple: new LOI.Character.Avatar.Landmark.Position
            name: 'nipple'

      BreastShapeBottom: new LOI.Character.Avatar.Parts.SkinShape
        type: 'Avatar.Body.BreastShapeBottom'
        name: 'breasts shape bottom'
        default: 'landsofillusions/character/avatar/body/torso/chest/breasts/bottom/2/Breast bottom 2'
        landmarks:
          breastCenter: new LOI.Character.Avatar.Landmark.Position
            name: 'breastCenter'

      NippleShape: new LOI.Character.Avatar.Parts.Shape
        type: 'Avatar.Body.NippleShape'
        name: 'nipple shape'
        default: 'landsofillusions/character/avatar/body/torso/chest/breasts/nipples/Nipple male'
        landmarks:
          nipple: new LOI.Character.Avatar.Landmark.Position
            name: 'nipple'
        materials:
          nipple: (part) ->
            breastsPart = part.ancestorPartOfType LOI.Character.Part.Types.Avatar.Body.Breasts
            breastsPart.properties.nippleShade

      Abdomen: new LOI.Character.Part
        type: 'Avatar.Body.Abdomen'
        name: 'abdomen'
        properties:
          shape: new LOI.Character.Part.Property.OneOf
            name: 'shape'
            type: 'Avatar.Body.AbdomenShape'
    
      AbdomenShape: new LOI.Character.Avatar.Parts.SkinShape
        type: 'Avatar.Body.AbdomenShape'
        name: 'abdomen shape'
        default: 'landsofillusions/character/avatar/body/torso/abdomen/ectomorph/1/'
        renderer: new LOI.Character.Avatar.Renderers.Shape
          origin:
            landmark: 'navel'
        landmarks:
          xiphoid: new LOI.Character.Avatar.Landmark.Position
            name: 'xiphoid'
          navel: new LOI.Character.Avatar.Landmark.Position
            name: 'navel'
          hypogastrium: new LOI.Character.Avatar.Landmark.Position
            name: 'hypogastrium'
    
      Groin: new LOI.Character.Part
        type: 'Avatar.Body.Groin'
        name: 'groin'
        properties:
          shape: new LOI.Character.Part.Property.OneOf
            name: 'shape'
            type: 'Avatar.Body.GroinShape'
          sexOrgan: new LOI.Character.Part.Property.OneOf
            name: 'sex organ'
            type: 'Avatar.Body.SexOrgan'
          pubicHair: new LOI.Character.Part.Property.OneOf
            name: 'pubic hair'
            type: 'Avatar.Body.PubicHair'

      GroinShape: new LOI.Character.Avatar.Parts.SkinShape
        type: 'Avatar.Body.GroinShape'
        name: 'groin shape'
        default: 'landsofillusions/character/avatar/body/torso/groin/narrow/Groin narrow'
        renderer: new LOI.Character.Avatar.Renderers.Shape
          origin:
            landmark: 'hypogastrium'
            x: 0
            y: -2.5
        landmarks:
          hypogastrium: new LOI.Character.Avatar.Landmark.Position
            name: 'hypogastrium'
          acetabulumLeft: new LOI.Character.Avatar.Landmark.Position
            name: 'acetabulumLeft'
          acetabulumRight: new LOI.Character.Avatar.Landmark.Position
            name: 'acetabulumRight'
          pubicSymphysis: new LOI.Character.Avatar.Landmark.Position
            name: 'pubicSymphysis'

      SexOrgan: new LOI.Character.Part
        type: 'Avatar.Body.SexOrgan'
        name: 'sex organ'
        properties:
          shape: new LOI.Character.Part.Property.OneOf
            name: 'shape'
            type: 'Avatar.Body.SexOrganShape'

      SexOrganShape: new LOI.Character.Avatar.Parts.SkinShape
        type: 'Avatar.Body.SexOrganShape'
        name: 'sex organ shape'
        properties:
          region: new LOI.Character.Part.Property.String
            name: 'region'
            values: ['Torso', 'SexOrgan']
        renderer: new LOI.Character.Avatar.Renderers.Shape
          origin:
            landmark: 'pubicSymphysis'
        landmarks:
          pubicSymphysis: new LOI.Character.Avatar.Landmark.Position
            name: 'pubicSymphysis'

      PubicHair: new LOI.Character.Part
        type: 'Avatar.Body.PubicHair'
        name: 'pubic hair'
        properties:
          color: new LOI.Character.Avatar.Properties.Color
            name: 'color'
            colorsPresetName: 'Default'
            default:
              hue: 0
              shade: 2
          shapes: new LOI.Character.Part.Property.Array
            name: 'shapes'
            type: 'Avatar.Body.PubicHairShape'

      PubicHairShape: new LOI.Character.Avatar.Parts.Shape
        type: 'Avatar.Body.PubicHairShape'
        name: 'pubic hair shape'
        properties:
          region: new LOI.Character.Part.Property.String
            name: 'region'
            values: ['Torso', 'SexOrgan']
        renderer: new LOI.Character.Avatar.Renderers.Shape
          origin:
            landmark: 'pubicSymphysis'
        materials:
          pubicHair: (part) ->
            pubicHairPart = part.ancestorPartOfType LOI.Character.Part.Types.Avatar.Body.PubicHair
            pubicHairPart.properties.color
        landmarks:
          pubicSymphysis: new LOI.Character.Avatar.Landmark.Position
            name: 'pubicSymphysis'

      Arms: new LOI.Character.Part
        type: 'Avatar.Body.Arms'
        name: 'arms'
        properties:
          upperArm: new LOI.Character.Part.Property.OneOf
            name: 'upper arm'
            type: 'Avatar.Body.UpperArm'
          lowerArm: new LOI.Character.Part.Property.OneOf
            name: 'lower arm'
            type: 'Avatar.Body.LowerArm'
          hand: new LOI.Character.Part.Property.OneOf
            name: 'hand'
            type: 'Avatar.Body.Hand'
        renderer: new LOI.Character.Avatar.Renderers.Default
          origin:
            landmark: 'elbow'

      UpperArm: new LOI.Character.Part
        type: 'Avatar.Body.UpperArm'
        name: 'upper arm'
        properties:
          shape: new LOI.Character.Part.Property.OneOf
            name: 'shape'
            type: 'Avatar.Body.UpperArmShape'
    
      UpperArmShape: new LOI.Character.Avatar.Parts.SkinShape
        type: 'Avatar.Body.UpperArmShape'
        name: 'upper arm shape'
        default: 'landsofillusions/character/avatar/body/arms/upperarm/Upper arm'
        renderer: new LOI.Character.Avatar.Renderers.Shape
          region: LOI.HumanAvatar.Regions.UpperArms
          origin:
            landmark: 'elbow'
            x: 0
            y: 3
        landmarks:
          shoulder: new LOI.Character.Avatar.Landmark.Position
            name: 'shoulder'
          elbow: new LOI.Character.Avatar.Landmark.Position
            name: 'elbow'
    
      LowerArm: new LOI.Character.Part
        type: 'Avatar.Body.LowerArm'
        name: 'lower arm'
        properties:
          shape: new LOI.Character.Part.Property.OneOf
            name: 'shape'
            type: 'Avatar.Body.LowerArmShape'
    
      LowerArmShape: new LOI.Character.Avatar.Parts.SkinShape
        type: 'Avatar.Body.LowerArmShape'
        name: 'lower arm shape'
        default: 'landsofillusions/character/avatar/body/arms/lowerarm/Lower arm'
        renderer: new LOI.Character.Avatar.Renderers.Shape
          region: LOI.HumanAvatar.Regions.LowerArms
          origin:
            landmark: 'elbow'
            x: 0
            y: -6
        landmarks:
          elbow: new LOI.Character.Avatar.Landmark.Position
            name: 'elbow'
          wrist: new LOI.Character.Avatar.Landmark.Position
            name: 'wrist'
    
      Hand: new LOI.Character.Part
        type: 'Avatar.Body.Hand'
        name: 'hand'
        properties:
          shape: new LOI.Character.Part.Property.OneOf
            name: 'shape'
            type: 'Avatar.Body.HandShape'
    
      HandShape: new LOI.Character.Avatar.Parts.SkinShape
        type: 'Avatar.Body.HandShape'
        name: 'hand shape'
        default: 'landsofillusions/character/avatar/body/arms/hand/Hand'
        renderer: new LOI.Character.Avatar.Renderers.Shape
          region: LOI.HumanAvatar.Regions.Hands
          origin:
            landmark: 'wrist'
            x: 0
            y: -1
        landmarks:
          wrist: new LOI.Character.Avatar.Landmark.Position
            name: 'wrist'
    
      Legs: new LOI.Character.Part
        type: 'Avatar.Body.Legs'
        name: 'legs'
        properties:
          foot: new LOI.Character.Part.Property.OneOf
            name: 'foot'
            type: 'Avatar.Body.Foot'
          lowerLeg: new LOI.Character.Part.Property.OneOf
            name: 'lower leg'
            type: 'Avatar.Body.LowerLeg'
          thigh: new LOI.Character.Part.Property.OneOf
            name: 'thigh'
            type: 'Avatar.Body.Thigh'
        renderer: new LOI.Character.Avatar.Renderers.Default
          origin:
            landmark: 'knee'

      Thigh: new LOI.Character.Part
        type: 'Avatar.Body.Thigh'
        name: 'thigh'
        properties:
          shape: new LOI.Character.Part.Property.OneOf
            name: 'shape'
            type: 'Avatar.Body.ThighShape'
    
      ThighShape: new LOI.Character.Avatar.Parts.SkinShape
        type: 'Avatar.Body.ThighShape'
        name: 'thigh shape'
        default: 'landsofillusions/character/avatar/body/legs/thigh/Thigh 2'
        renderer: new LOI.Character.Avatar.Renderers.Shape
          region: LOI.HumanAvatar.Regions.UpperLegs
          origin:
            landmark: 'acetabulum'
            x: 0
            y: -7
        landmarks:
          acetabulum: new LOI.Character.Avatar.Landmark.Position
            name: 'acetabulum'
          knee: new LOI.Character.Avatar.Landmark.Position
            name: 'knee'
    
      LowerLeg: new LOI.Character.Part
        type: 'Avatar.Body.LowerLeg'
        name: 'lower leg'
        properties:
          shape: new LOI.Character.Part.Property.OneOf
            name: 'shape'
            type: 'Avatar.Body.LowerLegShape'
    
      LowerLegShape: new LOI.Character.Avatar.Parts.SkinShape
        type: 'Avatar.Body.LowerLegShape'
        name: 'lower leg shape'
        default: 'landsofillusions/character/avatar/body/legs/lowerleg/Lower leg 2'
        renderer: new LOI.Character.Avatar.Renderers.Shape
          region: LOI.HumanAvatar.Regions.LowerLegs
          origin:
            landmark: 'knee'
            x: 0
            y: -6
        landmarks:
          knee: new LOI.Character.Avatar.Landmark.Position
            name: 'knee'
          ankle: new LOI.Character.Avatar.Landmark.Position
            name: 'ankle'
    
      Foot: new LOI.Character.Part
        type: 'Avatar.Body.Foot'
        name: 'foot'
        properties:
          shape: new LOI.Character.Part.Property.OneOf
            name: 'shape'
            type: 'Avatar.Body.FootShape'
    
      FootShape: new LOI.Character.Avatar.Parts.SkinShape
        type: 'Avatar.Body.FootShape'
        name: 'foot shape'
        default: 'landsofillusions/character/avatar/body/legs/foot/Foot'
        renderer: new LOI.Character.Avatar.Renderers.Shape
          region: LOI.HumanAvatar.Regions.Feet
          origin:
            landmark: 'ankle'
            x: 0
            y: -1
        landmarks:
          ankle: new LOI.Character.Avatar.Landmark.Position
            name: 'ankle'
