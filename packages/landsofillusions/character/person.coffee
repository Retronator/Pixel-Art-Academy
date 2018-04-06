AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

# A wrapper around a character instance that represents a character from another player.
class LOI.Character.Person extends LOI.Adventure.Thing
  @id: -> 'LandsOfIllusions.Character.Person'

  @fullName: -> "Person"
  @description: -> "It's a person."

  # We don't use the default listener.
  @listeners: -> []

  @initialize()

  constructor: (@options) ->
    {@instance, @action} = @options

    # We let Thing construct itself last since it'll need the character avatar (via the instance) ready.
    super

  createAvatar: ->
    # We send our own (character) avatar as the main avatar.
    @instance.createAvatar()

  # Avatar pass-through methods

  name: -> @instance.avatar.fullName()
  color: -> @instance.avatar.color()
  colorObject: (relativeShade) -> @instance.avatar.colorObject relativeShade

  # We need these next ones for compatibility of passing the character instance as a thing into adventure engine.

  fullName: -> @instance.avatar.fullName()
  shortName: -> @instance.avatar.shortName()
  nameAutoCorrectStyle: -> @instance.avatar.nameAutoCorrectStyle()
  description: -> @instance.thingAvatar.description()
  dialogTextTransform: -> @instance.avatar.dialogTextTransform()
  dialogueDeliveryType: -> @instance.avatar.dialogueDeliveryType()
