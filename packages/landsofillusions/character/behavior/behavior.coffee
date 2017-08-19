AM = Artificial.Mummification
LOI = LandsOfIllusions

# Behavior hierarchy
#
# personality
#   factors: array of
#     positivePoints: how many points the player has manually assigned to the positive side of the factor
#     negativePoints: how many points the player has manually assigned to the negative side of the factor
#     traits: array of
#       key: the unique adjective name of this trait
#       weight: -1, 0, 1 value indicating manually-selected alignment with this trait
#   autoTraits
# activities: array of
#   key: system name of the activity
#   hoursPerWeek: average amount of hours spent per week
# perks: array of
#   key: system name of the perk
class LOI.Character.Behavior
  constructor: (@character) ->
    # Create the behavior hierarchy.
    behaviorDataField = AM.Hierarchy.create
      templateClass: LOI.Character.Part.Template
      type: LOI.Character.Part.Types.Avatar.Outfit.options.type
      load: => @character.document()?.behavior
      save: (address, value) =>
        LOI.Character.updateBehavior @character.id, address, value

    @part = LOI.Character.Part.Types.Behavior.create
      dataLocation: new AM.Hierarchy.Location
        rootField: behaviorDataField
