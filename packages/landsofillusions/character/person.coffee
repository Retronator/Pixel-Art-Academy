AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

# A wrapper around a character instance that represents a character from another player.
class LOI.Character.Person extends LOI.Adventure.Thing
  @id: -> 'LandsOfIllusions.Character.Person'

  @fullName: -> "Person"
  @description: -> "It's a person."

  @initialize()

  constructor: (@_id) ->
    @instance = LOI.Character.getInstance @_id
    @action = new ReactiveField null

    # We let Thing construct itself last since it'll need the character avatar (via the instance) ready.
    super

  createAvatar: ->
    # We send instance's avatar as the main avatar.
    @instance.avatar

  descriptiveName: ->
    text = "_person_."
    
    if actionDescription = @action()?.activeDescription()
      text = "#{text} #{actionDescription}"

    LOI.Character.formatText text, 'person', @instance

  # We pass avatar methods through to instance's avatar.
  fullName: -> @instance.avatar.fullName()
  shortName: -> @instance.avatar.shortName()
  nameAutoCorrectStyle: -> @instance.avatar.nameAutoCorrectStyle()
  dialogTextTransform: -> @instance.avatar.dialogTextTransform()
  dialogueDeliveryType: -> @instance.avatar.dialogueDeliveryType()

  # Person methods

  setAction: (action) ->
    # Just record the action so it's ready for upcoming transitions.
    @action action

  transitionToAction: (action) ->
    # Make sure we have a new action to begin with. We allow time to differ since the server will set a different time
    # than what will happen in the simulation. If everything else is the same, there's little need to report anything
    # to the player anyway.
    actionData = (action) =>
      return unless action

      type: action.type
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

  # Listener

  onCommand: (commandResponse) ->
    person = @options.parent

    # Allow action to listen to commands.
    person.action()?.onCommand person, commandResponse
