LOI = LandsOfIllusions

# Behavior hierarchy
#
# personality
#   factors: array of
#     positivePoints: how many points the player has manually assigned to the positive side of the factor
#     negativePoints: how many points the player has manually assigned to the negative side of the factor
#     traits: array of
#       name: the unique adjective name of this trait
#       weight: -1, 0, 1 value indicating manually-selected alignment with this trait
#   autoTraits
# focalPoints: array of
#   name: name of the focal point
#   hoursPerWeek: average amount of hours spent per week

_.extend LOI.Character.Part.Types,
  Behavior: new LOI.Character.Part
    type: 'Behavior'
    properties:
      personality: new LOI.Character.Part.Property.OneOf
        type: 'Personality'
      focalPoints: new LOI.Character.Part.Property.Array
        type: 'FocalPoint'

  Personality: new LOI.Character.Part
    type: 'Personality'
    properties:
      factors: new LOI.Character.Part.Property.Array
        type: 'PersonalityFactor'
      autoTraits: new LOI.Character.Part.Property.Boolean

  PersonalityFactor: new LOI.Character.Part
    type: 'PersonalityFactor'
    properties:
      index: new LOI.Character.Part.Property.Integer
      positivePoints: new LOI.Character.Part.Property.Integer
      negativePoints: new LOI.Character.Part.Property.Integer
      traits: new LOI.Character.Part.Property.Array
        type: 'PersonalityTrait'

  PersonalityTrait: new LOI.Character.Part
    type: 'PersonalityTrait'
    properties:
      name: new LOI.Character.Part.Property.String
      weight: new LOI.Character.Part.Property.Integer

  FocalPoint: new LOI.Character.Part
    type: 'FocalPoint'
    properties:
      name: new LOI.Character.Part.Property.String
      hoursPerWeek: new LOI.Character.Part.Property.Integer
