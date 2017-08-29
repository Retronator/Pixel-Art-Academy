AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

class LOI.Construct.Loading.PreMadeCharacter extends AM.Document
  @id: -> 'LandsOfIllusions.Construct.Loading.PreMadeCharacter'
  # character: character data
  #   _id
  # bio: description of the character
  #   _id
  #   translations
  @Meta
    name: @id()
    fields: =>
      character: @ReferenceField LOI.Character, [], false
      bio: @ReferenceField AB.Translation, ['translations'], false

  # Methods

  @cloneToCurrentUser: @method 'cloneToCurrentUser'

  # Subscriptions

  @all: @subscription 'all'
