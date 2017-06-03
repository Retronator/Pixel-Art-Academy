LOI = LandsOfIllusions

_.extend LOI.Character.Part.Types,
  Body: new LOI.Character.Part
    type: 'Body'
    name: 'body'
    properties:
      head: new LOI.Character.Part.Property.OneOf
        name: 'head'
        type: 'Head'
      torso: new LOI.Character.Part.Property.OneOf
        name: 'torso'
        type: 'Torso'
      arms: new LOI.Character.Part.Property.OneOf
        name: 'arms'
        type: 'Arms'
      legs: new LOI.Character.Part.Property.OneOf
        name: 'legs'
        type: 'Legs'
      skin: new LOI.Character.Part.Property.Color

  Torso: new LOI.Character.Part
    type: 'Torso'
    name: 'torso'
    properties:
      chest: new LOI.Character.Part.Property.OneOf
        name: 'chest'
        type: 'Chest'
      abdomen: new LOI.Character.Part.Property.OneOf
        name: 'belly'
        type: 'Abdomen'
      groin: new LOI.Character.Part.Property.OneOf
        name: 'groin'
        type: 'Groin'

  Chest: new LOI.Character.Part
    type: 'Chest'
    name: 'chest'
    properties:
      shape: new LOI.Character.Part.Property.OneOf
        name: 'shape'
        type: 'ChestShape'
      modifications: new LOI.Character.Part.Property.Array
        name: 'additions'
        types: ['ChestBodyFat', 'ChestMuscles', 'Breasts']

  ChestShape: new LOI.Character.Part.Shape
    type: 'ChestShape'
    name: 'chest shape'

  ChestBodyFat: new LOI.Character.Part.Shape
    type: 'ChestBodyFat'
    name: 'chest body fat'

  ChestMuscles: new LOI.Character.Part.Shape
    type: 'ChestMuscles'
    name: 'chest muscles'

  Breasts: new LOI.Character.Part
    type: 'Breasts'
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
      nippleShade: new LOI.Character.Part.Property.RelativeColorShade
        name: 'shade of nipples'
        baseColor: (hierarchy) ->
          bodyNode = hierarchy.ancestorNodeWith (node) -> node.type is 'Body'
          bodyNode.properties.skin
      shape: new LOI.Character.Part.Property.OneOf
        name: 'shape'
        type: 'BreastsShape'
    landmarks:
      nipplePosition: new LOI.Character.Part.Landmark.Position
      outerEdgePosition: new LOI.Character.Part.Landmark.Position
      bottomEdgePosition: new LOI.Character.Part.Landmark.Position

  BreastsShape: new LOI.Character.Part
    type: 'BreastsShape'
    name: 'breasts shape'
    properties:
      topShape: new LOI.Character.Part.Property.OneOf
        name: 'top shape'
        type: 'BreastsShapeTop'
      bottomShape: new LOI.Character.Part.Property.OneOf
        name: 'bottom shape'
        type: 'BreastsShapeBottom'
    landmarks:
      centerPosition: new LOI.Character.Part.Landmark.Position
      edgePosition: new LOI.Character.Part.Landmark.Position

  BreastsShapeTop: new LOI.Character.Part.Shape
    type: 'BreastsShapeTop'
    name: 'breasts shape top'
    landmarks:
      centerPosition: new LOI.Character.Part.Landmark.Position
      edgePosition: new LOI.Character.Part.Landmark.Position

  BreastsShapeBottom: new LOI.Character.Part.Shape
    type: 'BreastsShapeBottom'
    name: 'breasts shape bottom'
    landmarks:
      centerPosition: new LOI.Character.Part.Landmark.Position
      edgePosition: new LOI.Character.Part.Landmark.Position
