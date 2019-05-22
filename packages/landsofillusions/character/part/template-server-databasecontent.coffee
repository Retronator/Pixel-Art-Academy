AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions

PNG = require 'fast-png'

class LOI.Character.Part.Template extends LOI.Character.Part.Template
  @Meta
    name: @id()
    replaceParent: true

  @importDatabaseContent: (arrayBuffer) ->

  databaseContentPath: ->
    return unless @type and @name.translations

    path = @type.toLowerCase().replace /\./g, '/'

    if @name.translations
      name = _.toLower _.camelCase @name.translations.best.text

    else
      name = @_id

    "landsofillusions/character/part/template/#{path}/#{name}"

  exportDatabaseContent: ->
    previewImage = @getPreviewImage()
    imageData = AM.EmbeddedImageData.embed previewImage, @

    # Encode the PNG.
    arrayBuffer = PNG.encode imageData

    arrayBuffer: arrayBuffer
    path: "#{@databaseContentPath()}.template.png"
    lastEditTime: new Date()

  getPreviewImage: ->
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
    partClass = LOI.Character.Part.getClassForType @type

    part = partClass.create
      dataLocation: new AM.Hierarchy.Location
        rootField: templateDataField

    previewImage = part.getPreviewImage()

    part.destroy()
    templateDataField.destroy()

    previewImage

databaseContentImportDirective = 'LandsOfIllusions.Character.Part.Template.adminTemplates'

AM.DatabaseContent.addToExport ->
  documents = []

  # TODO: Fetch only admin templates.
  templates = LOI.Character.Part.Template.documents.fetch type: /^Avatar/

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
