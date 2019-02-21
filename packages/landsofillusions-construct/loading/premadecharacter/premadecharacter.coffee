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
      character: Document.ReferenceField LOI.Character, [], false
      bio: Document.ReferenceField AB.Translation, ['translations'], false

  # Methods

  @cloneToCurrentUser: @method 'cloneToCurrentUser'

  # Subscriptions

  @all: @subscription 'all'

if Meteor.isServer
  importDirective = 'LandsOfIllusions.Character.preMadeCharacter'
  
  LOI.GameContent.addToExport ->
    documents = []

    # Export all pre-made character documents.
    preMadeCharacters = LOI.Construct.Loading.PreMadeCharacter.documents.fetch()
    documents.push preMadeCharacters...

    # Add bios.
    bios = AB.Translation.documents.fetch
      _id: $in: (preMadeCharacter.bio._id for preMadeCharacter in preMadeCharacters)

    documents.push bios...

    # Add the characters they're pointing to.
    characters = LOI.Character.documents.fetch
      _id: $in: (preMadeCharacter.character._id for preMadeCharacter in preMadeCharacters)

    # We omit the user in the exported characters.
    for character in characters
      delete character.user
      character._importDirective = importDirective

    documents.push characters...
    
    # Add character names.
    names = AB.Translation.documents.fetch
      _id: $in: (character.avatar.fullName._id for character in characters)

    documents.push names...

    documents
      
  LOI.GameContent.addImportDirective importDirective, (character) ->
    # Associate the template back to the (new) admin.
    unless admin = RA.User.documents.findOne username: 'admin'
      console.warn "Admin user hasn't been created yet. Restart server to update template authors."

      # Delete ID to skip importing for now.
      delete character._id

      return

    character.user = _id: admin._id
