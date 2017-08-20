AM = Artificial.Mummification
LOI = LandsOfIllusions

# Behavior hierarchy
#
# npc: boolean whether this character isn't controlled by the player (but is fully autonomous)
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
# environment
#   clutter
#     average: integer 1-5 how much clutter is usually around the character (minimal/tidy/average/messy/chaos)
#     ideal: integer 1-5 what's the most productive level of clutter for the character
#   people: array of
#     relationshipType: enumeration how this person relates to the character (Dad/Mom/Brother/Sister/Sibling/Son/Daughter/Child/OtherFamily/Wife/Husband/Girlfriend/Boyfriend/SignificantOther/Friend)
#     relationshipStrength: integer from 1 to 3, how much this person stays in touch (monthly/weekly/daily)
#     livingProximity: enumeration where this person lives (Local/Housemate/Roommate/Internet)
#     artSupport: integer from -2 to 2, how much this person supports the arts (hateful/unsupportive/neutral/supportive/sponsor)
#     doesArt: boolean whether this person does art
#     joins: boolean whether this person moves with the character to Retropolis
#     characterId: optional id if you want this person to be a specific npc character
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
