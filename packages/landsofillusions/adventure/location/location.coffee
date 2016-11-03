AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Location extends LOI.Adventure.Thing
  # Static location properties and methods

  # A map of all location constructors by url and ID.
  @_thingClassesByUrl = {}
  @_thingClassesByID = {}

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

    @exits = new ReactiveField {}

    @director = new LOI.Adventure.Director @
    @actors = new ReactiveField []

    # Subscribe to translations of exit locations so we get their names.
    # TODO: Find a way to just subscribe to location names, not whole location namespaces (probably overkill).
    @exitsTranslationSubscribtions = new ComputedField =>
      subscriptions = {}
      for directionKey, locationId of @exits()
        subscriptions[locationId] = AB.subscribeNamespace locationId

      subscriptions

    # Subscribe to this location's script translations.
    translationNamespace = @constructor.id()
    @_translationSubscribtionScript = AB.subscribeNamespace "#{translationNamespace}.Script"

    # Create the scripts.
    @scripts= {}

    if @constructor.scriptUrls
      scriptFiles = for scriptUrl in @constructor.scriptUrls()
        file = new LOI.Adventure.ScriptFile
          url: @constructor.versionUrl "/packages/#{scriptUrl}"
          location: @
          adventure: @adventure

        file.promise

      Promise.all(scriptFiles).then (scriptFiles) =>
        for scriptFile in scriptFiles
          # Add the loaded and translated script nodes to this location.
          _.extend @scripts, scriptFile.scripts

        # Now that all the scripts are loaded, trigger update of script states.
        @state @state()

        @onScriptsLoaded()

    # Send state updates to scripts.
    @_stateUpdateAutorun = Tracker.autorun =>
      state = @state()
      return unless state

      console.log "Location has received a new state", state, "and we are sending it to the scripts", @scripts if LOI.debug

      createdStates = false

      for scriptId, script of @scripts
        # Find the state of the script in location, or make it if it doesn't exist yet.
        scriptState = state.scripts[scriptId]

        unless scriptState
          scriptState = {}
          state.scripts[scriptId] = scriptState
          createdStates = true

        # Update the state.
        script.state scriptState

      if createdStates
        console.log "Updating the state of location has introduced new scripts." if LOI.debug
        Tracker.nonreactive => @options.adventure.gameState.updated()

  destroy: ->
    super

    @exitsTranslationSubscribtions.stop()
    @_translationSubscribtionScript.stop()
    @_stateUpdateAutorun.stop()

  initialState: ->
    scripts: {}

  onScriptsLoaded: -> # Override to create location's script logic. Use @scriptNodes to get access to script nodes.

  addExit: (directionKey, locationId) ->
    exits = @exits()
    exits[directionKey] = locationId
    @exits exits

  addActor: (actor) ->
    actor.director @director
    @actors @actors().concat actor

    # Allow chaining syntax.
    actor
