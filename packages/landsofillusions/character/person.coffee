AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

# A wrapper around a character instance that represents a character from another player.
class LOI.Character.Person extends LOI.Adventure.Thing
  @id: -> 'LandsOfIllusions.Character.Person'

  @fullName: -> "Person"
  @description: -> "It's a person."

  @translations: ->
    yourCharacter: "It's your character."

  @initialize()

  constructor: (@_id) ->
    @instance = LOI.Character.getInstance @_id
    @action = new ReactiveField null

    # We let Thing construct itself last since it'll need the character avatar (via the instance) ready.
    super

    @thingAvatar = new LOI.Adventure.Thing.Avatar @
    
    # Subscribe to the memory of the action the person is performing.
    @_actionSubscription = Tracker.autorun (computation) =>
      # See if this action even is inside a memory.
      return unless action = @action()
      return unless action.memory
      
      LOI.Memory.forId.subscribe action.memory._id

  createAvatar: ->
    # We send instance's avatar as the main avatar.
    @instance.avatar

  descriptiveName: ->
    text = "![_person_](talk to _person_)."
    
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

  description: ->
    if @_id is LOI.characterId()
      @translations().yourCharacter

    else
      @thingAvatar.description()

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
    # See if we need to do the transition.
    oldAction = @action()
    skipTransition = action?.shouldSkipTransition oldAction

    # Transition out of the old action.
    oldAction?.end @ unless skipTransition

    @action action
    
    if action
      # Transition into the new action.
      action.start @ unless skipTransition
      
    else
      # No action means the person left the location, so we start an ad-hoc leave action.
      action = new LOI.Memory.Actions.Leave
      action.start @
      
  recentActions: (earliestTime) ->
    LOI.Memory.Action.documents.fetch
      'character._id': @_id
      time: $gte: earliestTime

  # Listener

  onCommand: (commandResponse) ->
    person = @options.parent

    # Allow action to listen to commands.
    person.action()?.onCommand person, commandResponse
