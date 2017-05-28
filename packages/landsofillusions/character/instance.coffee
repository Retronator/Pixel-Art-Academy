AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

# A wrapper around the Character document that persists between document updates.
class LOI.Character.Instance
  constructor: (@id) ->
    # Subscribe to get all the data for the character.
    @_documentSubscription = LOI.Character.forId.subscribe @id

    @document = new ComputedField =>
      LOI.Character.documents.findOne @id

    @avatar = new LOI.Character.Avatar @

    # Create the behavior hierarchy.
    @behavior = AM.Hierarchy.create
      load: => @document()?.behavior
      save: (address, value) =>
        LOI.Character.updateBehavior @id, address, value

  destroy: ->
    @_documentSubscription.stop()
