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

    ga? 'send', 'event', eventCategory, eventAction, eventLabel
    
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

    # We only have uncertain possibilities.
    @chooseLikelyAction likelyActions
    
  _availableThings: ->
    LOI.adventure.currentThings()

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
      line: _.capitalize @_createIdealForm likelyAction
      next: @_createCallbackNode likelyAction.phraseAction

  _createIdealForm: (likelyAction) ->
    # See if phrase action provides a method to generate the ideal form.
    return likelyAction.phraseAction.idealForm likelyAction if likelyAction.phraseAction.idealForm?

    # Otherwise we use the default which is just all form parts joined in order.
    likelyAction.translatedForm.join ' '
