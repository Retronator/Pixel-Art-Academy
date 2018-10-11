AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

# A thing representation of a character, either a player character (agent) or a non-player character (actor).
class LOI.Character.Person extends LOI.Adventure.Thing
  # PERSON STATE (part of main game state, mapped by character ID)
  # alreadyMet: boolean whether the player had any interactions with this person
  # introduced: boolean whether the player introduced themselves to the person
  # lastHangout: info when player last hanged out with this person
  #   time: real-world time of the hangout in milliseconds
  #   gameTime: fractional time in game days
  # previousHangout: information about the hangout prior to last hangout
  #   time: real-world time of the hangout in milliseconds
  #   gameTime: fractional time in game days
  constructor: ->
    super

    @action = new ReactiveField null

  descriptiveName: ->
    text = "![_person_](talk to _person_)."
    
    if actionDescription = @action()?.activeDescription()
      text = "#{text} #{actionDescription}"

    LOI.Character.formatText text, 'person', @instance
    
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

  recentActions: -> throw AE.NotImplementedException "Person must provide recent actions."

  # The time after start of hangout that we're showing events since previous hangout.
  @preserveHangoutDuration = 10 * 60 * 1000 # 10 minutes

  # The maximum duration we're showing recent actions for.
  @recentActionsEarliestTimeMaxDuration = 30 * 24 * 60 * 60 * 1000 # 30 days

  recentActionsEarliestTime: ->
    lastHangout = @personState 'lastHangout'
    lastHangoutTime = lastHangout?.time or 0

    # Within 10 minutes of the last hangout we still show all events since previous hangout so that you can quickly
    # ask the person what's new again and get the same results (and that people don't just disappear immediately after
    # hanging out with them.
    time = Date.now()
    timeSinceLastHangout = time - lastHangoutTime

    if timeSinceLastHangout < @constructor.preserveHangoutDuration
      lastHangout = @personState 'previousHangout'
      lastHangoutTime = lastHangout?.time or 0

    # Take the last hangout time, but not earlier than 1 month.
    earliestTime = Math.max lastHangoutTime, Date.now() - @constructor.recentActionsEarliestTimeMaxDuration

    new Date earliestTime

  recordHangout: ->
    lastHangout = @personState('lastHangout')
    lastHangoutTime = lastHangout?.time or 0

    # If this hangout is happening more than 10 minutes after the last hangout, record it as an actual new hangout.
    time = Date.now()
    timeSinceLastHangout = time - lastHangoutTime

    if timeSinceLastHangout > @constructor.preserveHangoutDuration
      # Store last hangout as the previous hangout so that we can calculate updates since then.
      @personState 'previousHangout', _.cloneDeep lastHangout

    # Update last hangout to now.
    lastHangout =
      time: Date.now()
      gameTime: LOI.adventure.gameTime().getTime()

    @personState 'lastHangout', lastHangout

  # Listener

  onCommand: (commandResponse) ->
    person = @options.parent

    # Allow action to listen to commands.
    person.action()?.onCommand person, commandResponse
