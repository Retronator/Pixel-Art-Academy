AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

PNG = require 'fast-png'
util = require 'util'

class LOI.Character.Part.Template extends LOI.Character.Part.Template
  @Meta
    name: @id()
    replaceParent: true

  @importDatabaseContent: (arrayBuffer, documentInformation) ->
    if _.endsWith documentInformation.path, 'png'
      imageData = PNG.decode arrayBuffer
      AM.EmbeddedImageData.extract imageData

    else if _.endsWith documentInformation.path, 'txt'
      decoder = new util.TextDecoder
      content = decoder.decode arrayBuffer

      # The last line will have JSON content.
      lines = content.split '\n'
      EJSON.parse _.last lines

    else
      console.warn "Template to be imported isn't in a supported format.", documentInformation
      null

  databaseContentPath: ->
    return unless @type and @name.translations

    path = @type.toLowerCase().replace /\./g, '/'

    if @name.translations
      name = _.toLower _.camelCase @name.translations.best.text

    else
      name = @_id

    "landsofillusions/character/part/template/#{path}/#{name}"

  exportDatabaseContent: ->
    # Add last edit time if needed so that documents don't need unnecessary imports.
    @lastEditTime ?= new Date()

    if previewImage = @getPreviewImage()
      imageData = AM.EmbeddedImageData.embed previewImage, @

      # Encode the PNG.
      arrayBuffer = PNG.encode imageData
      extension = 'png'

    else if previewText = @getPreviewText()
      previewText += "\n\n#{EJSON.stringify @}"

      encoder = new util.TextEncoder
      arrayBuffer = encoder.encode previewText
      extension = 'txt'

    else
      console.warn "Template did not generate a preview image or text."
      return

    arrayBuffer: arrayBuffer
    path: "#{@databaseContentPath()}.template.#{extension}"
    lastEditTime: @lastEditTime

  getPreviewImage: ->
    return unless _.startsWith @type, 'Avatar'

    part = @_getPreviewPart()
    previewImage = part.getPreviewImage()

    part.destroy()
    part.options.dataLocation.options.rootField.destroy()

    previewImage

  _getPreviewPart: ->
    # Create the template hierarchy.
    templateDataField = AM.Hierarchy.create
      templateClass: LOI.Character.Part.Template
      type: @type
      load: new ComputedField =>
        template:
          id: @_id
      ,
        EJSON.equals

    # Create the part that uses this template.
    partClass = LOI.Character.Part.getClassForTemplateType @type

    partClass.create
      dataLocation: new AM.Hierarchy.Location
        rootField: templateDataField

  getPreviewText: ->
    return unless _.startsWith @type, 'Behavior'

    part = @_getPreviewPart()
    console.log "parttt", part
    previewText = part.getPreviewText()

    part.destroy()
    part.options.dataLocation.options.rootField.destroy()

    previewText

databaseContentImportDirective = 'LandsOfIllusions.Character.Part.Template.adminTemplates'

AM.DatabaseContent.addToExport ->
  documents = []

  # TODO: Fetch only admin templates.
  templates = LOI.Character.Part.Template.documents.fetch
    latestVersion: $exists: true

  # Strip authors from templates.
  for template in templates
    delete template.author
    delete template.authorName
    template._databaseContentImportDirective = databaseContentImportDirective

    name = AB.Translation.documents.findOne template.name._id
    description = AB.Translation.documents.findOne template.description._id

    path = template.databaseContentPath()

    # Note: Name and description might not be in the local database due to manual porting.
    name?._databaseContentPath = "#{path}.name"
    description?._databaseContentPath = "#{path}.description"

    documents.push template, name, description

  documents

AM.DatabaseContent.addImportDirective databaseContentImportDirective, (template) ->
  # Associate the template back to the (new) admin.
  unless admin = RA.User.documents.findOne(username: 'admin')
    console.warn "Admin user hasn't been created yet. Restart server to update template authors."

    # Delete ID to skip importing for now.
    delete template._id

    return

  template.author = _id: admin._id
  template.authorName = admin.publicName
