AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

PNG = require 'fast-png'

class LOI.Character.PreMadeCharacter extends LOI.Character.PreMadeCharacter
  @Meta
    name: @id()
    replaceParent: true

  @importDatabaseContent: (arrayBuffer) ->
    imageData = PNG.decode arrayBuffer
    AM.EmbeddedImageData.extract imageData

  databaseContentPath: ->
    name = @character.refresh().debugName

    "landsofillusions/character/premadecharacter/#{name}"

  exportDatabaseContent: ->
    # Add last edit time if needed so that documents don't need unnecessary imports.
    @lastEditTime ?= new Date()

    character = LOI.Character.documents.findOne @character._id
    previewImage = character.getPreviewImage()
    imageData = AM.EmbeddedImageData.embed previewImage, @

    # Encode the PNG.
    arrayBuffer = PNG.encode imageData

    arrayBuffer: arrayBuffer
    path: "#{@databaseContentPath()}.premadecharacter.png"
    lastEditTime: @lastEditTime

databaseContentImportDirective = 'LandsOfIllusions.Character.preMadeCharacter'

AM.DatabaseContent.addToExport ->
  documents = []

  # Export all pre-made character documents.
  for preMadeCharacter in LOI.Character.PreMadeCharacter.documents.fetch()
    documents.push preMadeCharacter

    # Add bio.
    bio = AB.Translation.documents.findOne preMadeCharacter.bio._id
    path = preMadeCharacter.databaseContentPath()
    bio._databaseContentPath = "#{path}.bio"
    documents.push bio

    # Add the characters they're pointing to.
    character = LOI.Character.documents.findOne preMadeCharacter.character._id

    # We omit the user in the exported character.
    delete character.user
    character._databaseContentImportDirective = databaseContentImportDirective
    documents.push character

    # Add character name.
    path = character.databaseContentPath()
    name = AB.Translation.documents.findOne character.avatar.fullName._id
    name._databaseContentPath = "#{path}.name"
    documents.push name

  documents

AM.DatabaseContent.addImportDirective databaseContentImportDirective, (character) ->
  # Associate the template back to the (new) admin.
  unless admin = RA.User.documents.findOne(username: 'admin')
    console.warn "Admin user hasn't been created yet. Restart server to update template authors."

    # Delete ID to skip importing for now.
    delete character._id

    return

  character.user = _id: admin._id
