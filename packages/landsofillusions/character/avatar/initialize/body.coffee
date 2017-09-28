LOI = LandsOfIllusions

LOI.Character.Part.registerClasses
  Avatar:
    Body: new LOI.Character.Part
      type: 'Avatar.Body'
      name: 'body'
      properties:
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
        skin: new LOI.Character.Avatar.Properties.Color
          name: 'skin'
          colorsPresetName: 'Skin'
          default:
            hue: 3
            shade: 4
      renderer: new LOI.Character.Avatar.Renderers.Body
        origin:
          landmark: 'navel'
            
    allPartTypeIds: ->
      types = []
    
      addTypes = (type) =>
        # Go over all the properties of the type and add all sub-types.
        typeClass = _.nestedProperty LOI.Character.Part.Types, type
    
        for propertyName, property of typeClass.options.properties when property.options?.type?
          type = property.options.type
    
          types.push type
          addTypes type
    
      addTypes 'Avatar.Body'
      addTypes 'Avatar.Outfit'
    
      types

LOI.Character.Part.registerClasses
  Avatar:
    Body:
      Head: new LOI.Character.Part
        type: 'Avatar.Body.Head'
        name: 'head'
        properties:
          neck: new LOI.Character.Part.Property.OneOf
            name: 'neck'
            type: 'Avatar.Body.Neck'
          shape: new LOI.Character.Part.Property.OneOf
            name: 'shape'
            type: 'Avatar.Body.HeadShape'
          eyes: new LOI.Character.Part.Property.OneOf
            name: 'eyes'
            type: 'Avatar.Body.Eyes'
          hair: new LOI.Character.Part.Property.Array
            name: 'hair'
            type: 'Avatar.Body.Hair'
          hairBehind: new LOI.Character.Part.Property.Array
            name: 'hair behind'
            type: 'Avatar.Body.Hair'
          facialHair: new LOI.Character.Part.Property.Array
            name: 'facial hair'
            type: 'Avatar.Body.FacialHair'
        renderer: new LOI.Character.Avatar.Renderers.Head
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
        renderer: new LOI.Character.Avatar.Renderers.Shape
          origin:
            landmark: 'forehead'
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

      Eyes: new LOI.Character.Part
        type: 'Avatar.Body.Eyes'
        name: 'eyes'
        properties:
          shape: new LOI.Character.Part.Property.OneOf
            name: 'shape'
            type: 'Avatar.Body.EyeShape'
          iris: new LOI.Character.Avatar.Properties.Color
            name: 'iris'
            colorsPresetName: 'Default'
            default:
              hue: 0
              shade: 4

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
        renderer: new LOI.Character.Avatar.Renderers.Default
          origin:
            landmark: 'navel'
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
          breastsOffsetX: new LOI.Character.Part.Property.Integer
            name: 'breasts horizontal offset'
          breastsOffsetY: new LOI.Character.Part.Property.Integer
            name: 'breasts vertical offset'
        renderer: new LOI.Character.Avatar.Renderers.Chest
          origin:
            landmark: 'xiphoid'

      ChestShape: new LOI.Character.Avatar.Parts.SkinShape
        type: 'Avatar.Body.ChestShape'
        name: 'chest shape'
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
          nippleOffsetX: new LOI.Character.Part.Property.Integer
            name: 'nipple horizontal offset'
          nippleOffsetY: new LOI.Character.Part.Property.Integer
            name: 'nipple vertical offset'
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
        renderer: new LOI.Character.Avatar.Renderers.Breasts
          origin:
            landmark: 'breastCenter'

      BreastShapeTop: new LOI.Character.Avatar.Parts.SkinShape
        type: 'Avatar.Body.BreastShapeTop'
        name: 'breasts shape top'
        landmarks:
          breastCenter: new LOI.Character.Avatar.Landmark.Position
            name: 'breastCenter'

      BreastShapeBottom: new LOI.Character.Avatar.Parts.SkinShape
        type: 'Avatar.Body.BreastShapeBottom'
        name: 'breasts shape bottom'
        landmarks:
          breastCenter: new LOI.Character.Avatar.Landmark.Position
            name: 'breastCenter'

      NippleShape: new LOI.Character.Avatar.Parts.Shape
        type: 'Avatar.Body.NippleShape'
        name: 'nipple shape'
        landmarks:
          breastCenter: new LOI.Character.Avatar.Landmark.Position
            name: 'breastCenter'
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
        renderer: new LOI.Character.Avatar.Renderers.Shape
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
        renderer: new LOI.Character.Avatar.Renderers.Shape
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
        renderer: new LOI.Character.Avatar.Renderers.Shape
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
        renderer: new LOI.Character.Avatar.Renderers.Shape
          origin:
            landmark: 'acetabulumLeft'
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
        renderer: new LOI.Character.Avatar.Renderers.Shape
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
        renderer: new LOI.Character.Avatar.Renderers.Shape
          origin:
            landmark: 'ankle'
            x: 0
            y: -1
        landmarks:
          ankle: new LOI.Character.Avatar.Landmark.Position
            name: 'ankle'
