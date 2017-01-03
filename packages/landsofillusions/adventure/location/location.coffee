AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Location extends LOI.Adventure.Thing
  # Static location properties and methods

  # Urls of scripts used at this location.
  @scriptUrls: -> []

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

    # Add a visited field unique to this location class.
    @visited = new ReactiveField false

  @initialState: ->
    scripts: {}
    things: {}

  # Location instance

  constructor: (@options) ->
    super

    @director new LOI.Adventure.Director @

    console.log "%cDirector made for location", 'background: LightSkyBlue', @ if LOI.debug

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
    @scripts = {}
    @scriptsReady = new ReactiveField false

    scriptUrls = @constructor.scriptUrls?()

    if scriptUrls?.length
      scriptFilePromises = for scriptUrl in scriptUrls
        scriptFile = new LOI.Adventure.ScriptFile
          url: @versionedUrl "/packages/#{scriptUrl}"
          location: @
          adventure: @options.adventure

        # Return the generated script file promise.
        scriptFile.promise

      Promise.all(scriptFilePromises).then (scriptFiles) =>
        for scriptFile in scriptFiles
          # Add the loaded and translated script nodes to this location.
          _.extend @scripts, scriptFile.scripts

        # Now that all the scripts are loaded, trigger update of script states.
        @state @state()

        @onScriptsLoaded()

        @scriptsReady true

    else
      @scriptsReady true

    # Propagate state updates.
    @_stateUpdateAutorun = Tracker.autorun =>
      state = @state()
      return unless state

      console.log "%cLocation", 'background: LightSkyBlue', @, "has received a new state", state, "and we are sending it to the scripts", @scripts if LOI.debug

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
        console.log "%cUpdating the state of location has introduced new scripts.", 'background: LightSkyBlue' if LOI.debug
        Tracker.nonreactive => @options.adventure.gameState.updated()

  destroy: ->
    super

    @exitsTranslationSubscriptions.stop()
    @_scriptTranslationSubscription.stop()
    @_stateUpdateAutorun.stop()

  ready: ->
    conditions = [
      super
      @things.ready()
      subscription.ready() for subscription in @exitsTranslationSubscriptions()
      @_scriptTranslationSubscription.ready()
      @scriptsReady()
    ]

    loaded = _.every _.flatten conditions

    console.log "%cLocation #{@constructor.id()} loaded?", 'background: LightSkyBlue', loaded, conditions if LOI.debug

    loaded

  onScriptsLoaded: -> # Override to create location's script logic. Use @scriptNodes to get access to script nodes.
