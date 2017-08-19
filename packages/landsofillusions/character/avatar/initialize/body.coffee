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
          neck: new LOI.Character.Part.Property.OneOf
            name: 'neck'
            type: 'Avatar.Body.Neck'
          shape: new LOI.Character.Part.Property.OneOf
            name: 'shape'
            type: 'Avatar.Body.HeadShape'
        renderer: new LOI.Character.Avatar.Renderers.Default
          origin:
            landmark: 'atlas'
    
      HeadShape: new LOI.Character.Avatar.Parts.SkinShape
        type: 'Avatar.Body.HeadShape'
        name: 'head shape'
        renderer: new LOI.Character.Avatar.Renderers.Shape
          origin:
            landmark: 'atlas'
        landmarks:
          atlas: new LOI.Character.Avatar.Landmark.Position
            name: 'atlas'
    
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
    
      Torso: new LOI.Character.Part
        type: 'Avatar.Body.Torso'
        name: 'torso'
        renderer: new LOI.Character.Avatar.Renderers.Default
          origin:
            landmark: 'navel'
        properties:
          chest: new LOI.Character.Part.Property.OneOf
            name: 'chest'
            type: 'Avatar.Body.Chest'
          abdomen: new LOI.Character.Part.Property.OneOf
            name: 'abdomen'
            type: 'Avatar.Body.Abdomen'
          groin: new LOI.Character.Part.Property.OneOf
            name: 'groin'
            type: 'Avatar.Body.Groin'
    
      Chest: new LOI.Character.Part
        type: 'Avatar.Body.Chest'
        name: 'chest'
        properties:
          shape: new LOI.Character.Part.Property.OneOf
            name: 'shape'
            type: 'Avatar.Body.ChestShape'
          modifications: new LOI.Character.Part.Property.Array
            name: 'additions'
            types: ['Avatar.Body.ChestBodyFat', 'Avatar.Body.ChestMuscles', 'Avatar.Body.Breasts']
    
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
    
      ChestBodyFat: new LOI.Character.Avatar.Parts.SkinShape
        type: 'Avatar.Body.ChestBodyFat'
        name: 'chest body fat'
    
      ChestMuscles: new LOI.Character.Avatar.Parts.SkinShape
        type: 'Avatar.Body.ChestMuscles'
        name: 'chest muscles'
    
      Breasts: new LOI.Character.Part
        type: 'Avatar.Body.Breasts'
        name: 'breasts'
        properties:
          positionX: new LOI.Character.Part.Property.Integer
            name: 'horizontal position'
            min: -2
            max: 2
          positionY: new LOI.Character.Part.Property.Integer
            name: 'vertical position'
          scaleX: new LOI.Character.Part.Property.Integer
            name: 'horizontal size'
          scaleY: new LOI.Character.Part.Property.Integer
            name: 'vertical size'
          nippleX: new LOI.Character.Part.Property.Integer
            name: 'horizontal position of nipples'
          nippleY: new LOI.Character.Part.Property.Integer
            name: 'vertical position of nipples'
          nippleShade: new LOI.Character.Avatar.Properties.RelativeColorShade
            name: 'shade of nipples'
            baseColor: (hierarchy) ->
              bodyNode = hierarchy.ancestorNodeWith (node) -> node.type is 'Body'
              bodyNode.properties.skin
          shape: new LOI.Character.Part.Property.OneOf
            name: 'shape'
            type: 'Avatar.Body.BreastsShape'
        landmarks:
          nipplePosition: new LOI.Character.Avatar.Landmark.Position
          outerEdgePosition: new LOI.Character.Avatar.Landmark.Position
          bottomEdgePosition: new LOI.Character.Avatar.Landmark.Position
    
      BreastsShape: new LOI.Character.Part
        type: 'Avatar.Body.BreastsShape'
        name: 'breasts shape'
        properties:
          topShape: new LOI.Character.Part.Property.OneOf
            name: 'top shape'
            type: 'Avatar.Body.BreastsShapeTop'
          bottomShape: new LOI.Character.Part.Property.OneOf
            name: 'bottom shape'
            type: 'Avatar.Body.BreastsShapeBottom'
        landmarks:
          centerPosition: new LOI.Character.Avatar.Landmark.Position
          edgePosition: new LOI.Character.Avatar.Landmark.Position
    
      BreastsShapeTop: new LOI.Character.Avatar.Parts.SkinShape
        type: 'Avatar.Body.BreastsShapeTop'
        name: 'breasts shape top'
        landmarks:
          centerPosition: new LOI.Character.Avatar.Landmark.Position
          edgePosition: new LOI.Character.Avatar.Landmark.Position
    
      BreastsShapeBottom: new LOI.Character.Avatar.Parts.SkinShape
        type: 'Avatar.Body.BreastsShapeBottom'
        name: 'breasts shape bottom'
        landmarks:
          centerPosition: new LOI.Character.Avatar.Landmark.Position
          edgePosition: new LOI.Character.Avatar.Landmark.Position
    
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
    
      GroinShape: new LOI.Character.Avatar.Parts.SkinShape
        type: 'Avatar.Body.GroinShape'
        name: 'groin shape'
        renderer: new LOI.Character.Avatar.Renderers.Shape
          origin:
            landmark: 'hypogastrium'
            x: 0
            y: -2.5
        landmarks:
          navel: new LOI.Character.Avatar.Landmark.Position
            name: 'navel'
          acetabulumLeft: new LOI.Character.Avatar.Landmark.Position
            name: 'acetabulumLeft'
          acetabulumRight: new LOI.Character.Avatar.Landmark.Position
            name: 'acetabulumRight'
    
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
