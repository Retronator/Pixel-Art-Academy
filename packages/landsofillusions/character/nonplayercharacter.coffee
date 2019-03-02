AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

# A plain object version of character, used for holding NPC data in the same format as character.
class LOI.NonPlayerCharacter
  # debugName: auto-generated best translation of the full name of this character for debugging (do not use in the game!).
  # avatar: information for the representation of the character
  #   body: avatar data for character's body representation
  #   outfit: avatar data for character's current clothes/accessories
  # behavior: avatar data for character's behavior design
  # profile: miscellaneous information about the NPC
  #   age: integer, 13 to 150
  #   country: ISO region code
  #   aspiration: any string
  #   favorites: an object of strings for various categories
  constructor: (document) ->
    # Transfer fields of document to the new object.
    @[key] = value for own key, value of document
