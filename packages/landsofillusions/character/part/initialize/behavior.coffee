LOI = LandsOfIllusions

_.extend LOI.Character.Part.Types,
  Behavior: new LOI.Character.Part
    type: 'Behavior'
    properties:
      personality: new LOI.Character.Part.Property.OneOf
        type: 'Personality'

  Personality: new LOI.Character.Part
    type: 'Personality'
    properties:
      factors: new LOI.Character.Part.Property.Array
        type: 'PersonalityFactor'
      autoTraits: new LOI.Character.Part.Property.Boolean

  PersonalityFactor: new LOI.Character.Part
    type: 'PersonalityFactor'
    properties:
      positivePoints: new LOI.Character.Part.Property.Integer
      negativePoints: new LOI.Character.Part.Property.Integer
      traits: new LOI.Character.Part.Property.Array
        type: 'PersonalityTrait'

  PersonalityTrait: new LOI.Character.Part
    type: 'PersonalityTrait'
    properties:
      id: new LOI.Character.Part.Property.String
      weight: new LOI.Character.Part.Property.Integer
