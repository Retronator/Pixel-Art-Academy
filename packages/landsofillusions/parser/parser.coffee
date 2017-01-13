AB = Artificial.Babel
LOI = LandsOfIllusions

Nodes = null

class LOI.Parser
  constructor: (@options) ->
    # Nodes are not yet available when parser is defined, so we need to access them here.
    Nodes = LOI.Adventure.Script.Nodes

    # Set Vocabulary shorthand.
    @Vocabulary = LOI.Parser.Vocabulary

    # Make a new vocabulary instance.
    @vocabulary = new @Vocabulary
    
    # Create global listeners.
    @globalListeners = [
      new @constructor.NavigationListener
    ]

  destroy: ->
    @vocabulary.destroy()

  ready: ->
    @vocabulary.ready()

  parse: (command) ->
    # Create a rich command object.
    command = new LOI.Parser.Command command

    # Report this command to analytics. Use command text as action and location ID as label.
    eventCategory = 'Adventure Command'
    eventAction = command.normalizedCommand
    eventLabel = LOI.adventure.currentLocationId()

    ga 'send', 'event', eventCategory, eventAction, eventLabel
    
    # Gather all available listeners.
    listeners = _.flattenDeep [
      @globalListeners
      thing.listeners for thing in @_availableThings()
    ]

    # Get all possible likely actions from all the listeners.
    likelyActions = for listener in listeners
      # Create the command response object.
      commandResponse = new @constructor.CommandResponse
        command: command
        parser: @

      # Ask the listener to set its response.
      listener.onCommand commandResponse

      # Process the response and command so that it creates possible candidate
      commandResponse.generateActions()

    # Pull all actions into one array.
    likelyActions = _.flatten likelyActions

    # Filter only certain action that can definitely be executed.
    certainActions = _.filter likelyActions, (likelyAction) =>
      likelyAction.likelihood is 1
    
    if certainActions.length is 1
      # Great! We have exactly one certain action. Simply execute it.
      certainActions[0].phraseAction.action()
      return
      
    else if certainActions.length > 1
      # We have multiple possibilities what to do. Let the user interface ask the user what to do.
      console.log "User should choose between", certainActions
      return

    # We only have uncertain possibilities.
    @chooseLikelyAction likelyActions
    
  _availableThings: ->
    location = LOI.adventure.currentLocation()
    _.flatten [location.thingInstances.values(), LOI.adventure.inventory.values()]

  # Creates a node that performs the action of the likely command
  _createCallbackNode: (phraseAction) ->
    new Nodes.Callback
      callback: (complete) =>
        # First complete the callback so that it doesn't get handled again while action is running.
        complete()

        # Start the chosen action.
        phraseAction.action()

  # Creates a node sequence that outputs the likely command to narrative and performs its action.
  _createCommandNodeSequence: (likelyAction) ->
    new Nodes.CommandLine
      replaceLastCommand: true
      line: _.capitalize likelyAction.phraseAction.idealForm likelyAction.translatedPhrase
      next: @_createCallbackNode likelyAction.phraseAction
