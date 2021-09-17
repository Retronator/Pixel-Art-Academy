LOI = LandsOfIllusions

# A wrapper around the Character document that persists between document updates.
class LOI.Character.Instance
  constructor: (@id, @_document) ->
    # Store ID with the usual underscore notation for use in #each and general ease.
    @_id = @id

    # Providing the document field is optional and is used with code-driven character. 
    # If we don't have it, we need to load character document from the database.
    unless @_document
      # Subscribe to get all the data for the character.
      @_documentSubscription = LOI.Character.forId.subscribe @id

    @avatar = new LOI.Character.Avatar => @document avatar: true
    @behavior = new LOI.Character.Behavior @

  destroy: ->
    @_documentSubscription?.stop()

  document: (fields) ->
    return @_document() if @_document

    options = {}
    options.fields = fields if fields

    LOI.Character.documents.findOne @id, options
    
  ready: ->
    conditions = [
      @document()?
      @avatar.ready()
    ]

    console.log "Character instance ready?", @id, conditions if LOI.debug

    _.every conditions

  # Avatar pass-through methods

  name: -> @avatar.fullName()
  color: -> @avatar.color()
  colorObject: (relativeShade) -> @avatar.colorObject relativeShade
