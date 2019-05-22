AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

class LOI.Character.PreMadeCharacter extends AM.Document
  @id: -> 'LandsOfIllusions.Character.PreMadeCharacter'
  # character: character data
  #   _id
  # bio: description of the character
  #   _id
  #   translations
  @Meta
    name: @id()
    fields: =>
      character: Document.ReferenceField LOI.Character, [], false
      bio: Document.ReferenceField AB.Translation, ['translations'], false

  # Methods

  @cloneToCurrentUser: @method 'cloneToCurrentUser'

  # Subscriptions

  @all: @subscription 'all'
