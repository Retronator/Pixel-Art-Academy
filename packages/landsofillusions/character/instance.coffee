AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

# A wrapper around the Character document that persists between document updates.
class LOI.Character.Instance extends LOI.Adventure.Thing
  @id: -> 'LandsOfIllusions.Character'

  @fullName: -> "Character"
  @description: -> "It's your character."

  # We don't use the default listener.
  @listeners: -> []

  @initialize()

  constructor: (@_id) ->
    # Subscribe to get all the data for the character.
    @_documentSubscription = LOI.Character.forId.subscribe @_id

    @document = new ComputedField =>
      LOI.Character.documents.findOne @_id

    # We have a character avatar which handles all the aspects of (player) character creation,
    # and a thing avatar that carries some minor translation options.
    @avatar = new LOI.Character.Avatar @
    @thingAvatar = new LOI.Adventure.Thing.Avatar @

    @behavior = new LOI.Character.Behavior @

    # We let Thing construct itself last since it'll need the character avatar ready.
    super

  destroy: ->
    super

    @_documentSubscription.stop()
    
  createAvatar: ->
    # We send our own (character) avatar as the main avatar.
    @avatar

  # Avatar pass-through methods

  name: -> @avatar.fullName()
  color: -> @avatar.color()
  colorObject: (relativeShade) -> @avatar.colorObject relativeShade

  # We need these next ones for compatibility of passing the character instance as a thing into adventure engine.

  fullName: -> @avatar.fullName()
  shortName: -> @avatar.shortName()
  nameAutoCorrectStyle: -> @avatar.nameAutoCorrectStyle()
  description: -> @thingAvatar.description()
  dialogTextTransform: -> @avatar.dialogTextTransform()
  dialogueDeliveryType: -> @avatar.dialogueDeliveryType()
