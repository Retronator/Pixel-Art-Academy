AM = Artificial.Mummification
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.TemplatePart
  constructor: (@id) ->
    # Store ID with the usual underscore notation for use in #each and general ease.
    @_id = @id

    document = @document type: true

    # Create the template hierarchy.
    templateDataField = AM.Hierarchy.create
      templateClass: LOI.Character.Part.Template
      type: document.type
      load: new ComputedField =>
        template:
          id: @id
      ,
        EJSON.equals

      save: (address, value) =>
        # Since this is just a dummy wrapper, there's nothing to do when template tries to be replaced here.

    partClass = LOI.Character.Part.getClassForType document.type
    
    @part = partClass.create
      dataLocation: new AM.Hierarchy.Location
        rootField: templateDataField

  document: (fields) ->
    options = {}
    options.fields = fields if fields

    LOI.Character.Part.Template.documents.findOne @id, options

  name: ->
    document = @document name: true
      
    translated = AB.translate document.name
    if translated.language then translated.text else null
