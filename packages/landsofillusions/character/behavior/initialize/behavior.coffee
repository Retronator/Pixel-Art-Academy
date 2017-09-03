LOI = LandsOfIllusions

LOI.Character.Part.registerClasses
  Behavior: new LOI.Character.Part
    type: 'Behavior'
    properties:
      npc: new LOI.Character.Part.Property.Boolean
      personality: new LOI.Character.Part.Property.OneOf
        type: 'Behavior.Personality'
      activities: new LOI.Character.Behavior.Activities
        type: 'Behavior.Activity'
        templateType: 'Behavior.Activities'
      environment: new LOI.Character.Part.Property.OneOf
        type: 'Behavior.Environment'
      perks: new LOI.Character.Behavior.Perks
        type: 'Behavior.Perk'

LOI.Character.Part.registerClasses
  Behavior:
    Personality: new LOI.Character.Behavior.Personality
      type: 'Behavior.Personality'
      properties:
        factors: new LOI.Character.Part.Property.Array
          type: 'Behavior.Personality.Factor'
        autoTraits: new LOI.Character.Part.Property.Boolean

    Activity: new LOI.Character.Behavior.Activity
      type: 'Behavior.Activity'
      properties:
        key: new LOI.Character.Part.Property.String
        hoursPerWeek: new LOI.Character.Part.Property.Integer

    Environment: new LOI.Character.Behavior.Environment
      type: 'Behavior.Environment'
      properties:
        clutter: new LOI.Character.Part.Property.OneOf
          type: 'Behavior.Environment.Clutter'
        people: new LOI.Character.Behavior.Environment.People
          type: 'Behavior.Environment.Person'
          templateType: 'Behavior.Environment.People'

    Perk: new LOI.Character.Behavior.Perk
      type: 'Behavior.Perk'
      properties:
        key: new LOI.Character.Part.Property.String

LOI.Character.Part.registerClasses
  Behavior:
    Personality:
      Factor: new LOI.Character.Behavior.Personality.Factor
        type: 'Behavior.Personality.Factor'
        properties:
          index: new LOI.Character.Part.Property.Integer
          positivePoints: new LOI.Character.Part.Property.Integer
          negativePoints: new LOI.Character.Part.Property.Integer
          traits: new LOI.Character.Behavior.Personality.Traits
            type: 'Behavior.Personality.Trait'

      Trait: new LOI.Character.Part
        type: 'Behavior.Personality.Trait'
        properties:
          key: new LOI.Character.Part.Property.String
          weight: new LOI.Character.Part.Property.Integer

    Environment:
      Clutter: new LOI.Character.Part
        type: 'Behavior.Environment.Clutter'
        properties:
          average: new LOI.Character.Part.Property.Integer
          ideal: new LOI.Character.Part.Property.Integer

      Person: new LOI.Character.Part
        type: 'Behavior.Environment.Person'
        properties:
          relationshipType: new LOI.Character.Part.Property.String
          relationshipStrength: new LOI.Character.Part.Property.Integer
          livingProximity: new LOI.Character.Part.Property.String
          artSupport: new LOI.Character.Part.Property.Integer
          doesArt: new LOI.Character.Part.Property.Boolean
          joins: new LOI.Character.Part.Property.Boolean
          characterId: new LOI.Character.Part.Property.String
