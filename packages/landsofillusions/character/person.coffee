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

  constructor: (@_id) ->
    @instance = LOI.Character.getInstance @_id
    @action = new ReactiveField null

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

  # Person methods

  setAction: (action) ->
    # Just record the action so it's ready for upcoming transitions.
    @action action

  transitionToAction: (action) ->
    # Make sure we have a new action to begin with.
    actionData = (action) =>
      return unless action

      type: action.type
      time: action.time.getTime()
      characterId: action.character._id
      timelineId: action.timelineId
      locationId: action.locationId
      contextId: action.contextId
      memoryId: action.memory?._id
      content: action.content

    return if EJSON.equals actionData(@action()), actionData(action)

    # If we had a previous action, transition out of it.
    oldAction = @action()
    oldAction.end @ if oldAction

    @action action
    
    if action
      action.start @
      
    else
      # No action means the person left the location, so we create a dummy move action that is ending.
      action = new LOI.Memory.Actions.Leave
      action.start @
