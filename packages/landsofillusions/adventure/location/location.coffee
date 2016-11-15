AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Location extends LOI.Adventure.Thing
  # Static location properties and methods

  # Urls of scripts used at this location.
  @scriptUrls: -> []

  # The semantic version of this location's scripts, so we can know when we need to 
  # recompile them. You can use the -wip suffix to force constant reloads and recompiles.
  @wipSuffix = 'wip'
  @version: ->
    "0.0.1-#{@wipSuffix}"

  @versionUrl: (url) ->
    version = @version()

    # If we're in WIP mode, add a random url version.
    version = Random.id() if _.endsWith version, @wipSuffix

    # Return the url with version added.
    "#{url}?#{version}"

  # The maximum height of location's illustration. By default there is no illustration (height 0).
  @illustrationHeight: -> 0
  illustrationHeight: -> @constructor.illustrationHeight()

  @initialize: ->
    super

    # On the server, compile the scripts.
    if Meteor.isServer and @scriptUrls
      for scriptUrl in @scriptUrls()
        [packageId, pathParts...] = scriptUrl.split '/'
        path = pathParts.join '/'
        text = LOI.packages[packageId].assets.getText path

        new LOI.Adventure.ScriptFile
          locationId: @id()
          text: text

  # Location instance

  constructor: (@options) ->
    super

    @director new LOI.Adventure.Director @

    console.log "Director made for location", @ if LOI.debug

    @things = new LOI.StateNode
      adventure: @options.adventure

    # Subscribe to translations of exit locations' avatars so we get their names.
    @exitsTranslationSubscriptions = new ComputedField =>
      exits = @state()?.exits
      return {} unless exits
      
      subscriptions = {}
      for directionKey, locationId of exits
        subscriptions[locationId] = AB.subscribeNamespace "#{locationId}.Avatar"

      subscriptions

    # Subscribe to this location's script translations.
    translationNamespace = @constructor.id()
    @_scriptTranslationSubscription = AB.subscribeNamespace "#{translationNamespace}.Script"

    # Create the scripts.
    @scripts= {}

    if @constructor.scriptUrls
      scriptFiles = for scriptUrl in @constructor.scriptUrls()
        file = new LOI.Adventure.ScriptFile
          url: @constructor.versionUrl "/packages/#{scriptUrl}"
          location: @
          adventure: @options.adventure

        file.promise

      Promise.all(scriptFiles).then (scriptFiles) =>
        for scriptFile in scriptFiles
          # Add the loaded and translated script nodes to this location.
          _.extend @scripts, scriptFile.scripts

        # Now that all the scripts are loaded, trigger update of script states.
        @state @state()

        @onScriptsLoaded()

    # Propagate state updates.
    @_stateUpdateAutorun = Tracker.autorun =>
      state = @state()
      return unless state

      console.log "Location", @, "has received a new state", state, "and we are sending it to the scripts", @scripts if LOI.debug

      # Update things.
      @things.updateState state.things

      # Update scripts.
      createdScriptStates = false

      for scriptId, script of @scripts
        # Find the state of the script in location, or make it if it doesn't exist yet.
        scriptState = state.scripts[scriptId]

        unless scriptState
          scriptState = {}
          state.scripts[scriptId] = scriptState
          createdScriptStates = true

        # Update the state.
        script.state scriptState

      if createdScriptStates
        console.log "Updating the state of location has introduced new scripts." if LOI.debug
        Tracker.nonreactive => @options.adventure.gameState.updated()

  destroy: ->
    super

    @exitsTranslationSubscriptions.stop()
    @_scriptTranslationSubscription.stop()
    @_stateUpdateAutorun.stop()

  initialState: ->
    scripts: {}
    things: {}

  ready: ->
    loaded = _.every _.flatten [
      super
      @state()
      subscription.ready() for subscription in @exitsTranslationSubscriptions()
      @_scriptTranslationSubscription.ready()
    ]

    console.log "Loaded location", @constructor.id() if loaded and LOI.debug

    loaded

  onScriptsLoaded: -> # Override to create location's script logic. Use @scriptNodes to get access to script nodes.
