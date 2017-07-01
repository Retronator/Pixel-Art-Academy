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

    # Create the behavior hierarchy.
    behaviorDataField = AM.Hierarchy.create
      templateClass: LOI.Character.Part.Template
      type: LOI.Character.Part.Types.Outfit.options.type
      load: => @document()?.behavior
      save: (address, value) =>
        LOI.Character.updateBehavior @id, address, value

    @behavior = LOI.Character.Part.Types.Behavior.create
      dataLocation: new AM.Hierarchy.Location
        rootField: behaviorDataField

  destroy: ->
    @_documentSubscription.stop()
