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

    @avatar = new LOI.Character.Avatar @
    @behavior = new LOI.Character.Behavior @

  destroy: ->
    @_documentSubscription.stop()

  # Avatar pass-through methods

  fullName: -> @avatar.fullName()
  shortName: -> @avatar.shortName()
  nameAutoCorrectStyle: -> @avatar.nameAutoCorrectStyle()
  description: -> @avatar.description()
  color: -> @avatar.color()
  dialogTextTransform: -> @avatar.dialogTextTransform()
  dialogDeliveryType: -> @avatar.dialogDeliveryType()
