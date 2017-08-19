LOI = LandsOfIllusions

LOI.Character.Part.registerClasses
  Behavior: new LOI.Character.Part
    type: 'Behavior'
    properties:
      personality: new LOI.Character.Part.Property.OneOf
        type: 'Behavior.Personality'
      focalPoints: new LOI.Character.Part.Property.Array
        type: 'Behavior.FocalPoint'
      perks: new LOI.Character.Part.Property.Array
        type: 'Behavior.Perk'

LOI.Character.Part.registerClasses
  Behavior:
    Personality: new LOI.Character.Behavior.Personality
      type: 'Behavior.Personality'
      properties:
        factors: new LOI.Character.Part.Property.Array
          type: 'Behavior.Personality.Factor'
        autoTraits: new LOI.Character.Part.Property.Boolean

    FocalPoint: new LOI.Character.Behavior.FocalPoint
      type: 'Behavior.FocalPoint'
      properties:
        key: new LOI.Character.Part.Property.String
        hoursPerWeek: new LOI.Character.Part.Property.Integer

    Perk: new LOI.Character.Behavior.Perk
      type: 'Behavior.Perk'
      properties:
        key: new LOI.Character.Part.Property.String

LOI.Character.Part.registerClasses
  Behavior:
    Personality:
      Factor: new LOI.Character.Part
        type: 'Behavior.Personality.Factor'
        properties:
          index: new LOI.Character.Part.Property.Integer
          positivePoints: new LOI.Character.Part.Property.Integer
          negativePoints: new LOI.Character.Part.Property.Integer
          traits: new LOI.Character.Part.Property.Array
            type: 'Behavior.Personality.Trait'

      Trait: new LOI.Character.Part
        type: 'Behavior.Personality.Trait'
        properties:
          key: new LOI.Character.Part.Property.String
          weight: new LOI.Character.Part.Property.Integer
