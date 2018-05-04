AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

# A wrapper around the Character document that persists between document updates.
class LOI.Character.Instance
  constructor: (@id) ->
    # Also store it with the usual underscore notation for use in #each and general ease.
    @_id = @id

    # Subscribe to get all the data for the character.
    @_documentSubscription = LOI.Character.forId.subscribe @id

    @document = new ComputedField =>
      LOI.Character.documents.findOne @id

    # We have a character avatar which handles all the aspects of (player) character creation,
    # and a thing avatar that carries some minor translation options.
    @avatar = new LOI.Character.Avatar @
    @behavior = new LOI.Character.Behavior @

  destroy: ->
    @_documentSubscription.stop()
    
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
