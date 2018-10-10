LOI = LandsOfIllusions

# A wrapper around the Character document that persists between document updates.
class LOI.Character.Instance
  constructor: (@id, @document) ->
    # Store ID with the usual underscore notation for use in #each and general ease.
    @_id = @id

    # Providing the document field is optional and is used with code-driven character. 
    # If we don't have it, we need to load character document from the database.
    unless @document
      # Subscribe to get all the data for the character.
      @_documentSubscription = LOI.Character.forId.subscribe @id
  
      @document = new ComputedField =>
        LOI.Character.documents.findOne @id

    @avatar = new LOI.Character.Avatar @
    @behavior = new LOI.Character.Behavior @

  destroy: ->
    @_documentSubscription?.stop()
    
  ready: ->
    conditions = [
      @document()?
      @avatar.ready()
    ]
    
    _.every conditions

  # Avatar pass-through methods

  name: -> @avatar.fullName()
  color: -> @avatar.color()
  colorObject: (relativeShade) -> @avatar.colorObject relativeShade
