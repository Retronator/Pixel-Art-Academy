AB = Artificial.Babel
LOI = LandsOfIllusions

class LOI.Adventure.Listener
  # Namespace for listener scripts.
  @Scripts: {}

  @scriptUrls: -> [] # Override to provide a list of script URLs to load.

  @initialize: ->
    # On the server, compile the scripts.
    if Meteor.isServer
      for scriptUrl in @scriptUrls()
        [packageId, pathParts...] = scriptUrl.split '/'
        path = pathParts.join '/'
        text = LOI.packages[packageId].assets.getText path

        new LOI.Adventure.ScriptFile
          text: text

  constructor: (@options = {}) ->
    # Subscribe to this listener's script translations.
    translationNamespace = @id?() or @options.parent?.id()

    if translationNamespace
      @_scriptTranslationSubscription = AB.subscribeNamespace "#{translationNamespace}.Script"

    else
      console.warn "Listener", @, "doesn't have a translation namespace." if LOI.debug

    # Handles for custom autorun routines.
    @_autorunHandles = []

    # Create the scripts.
    @scripts = {}
    @scriptsReady = new ReactiveField false

    scriptUrls = @constructor.scriptUrls()

    if scriptUrls.length
      scriptFilePromises = for scriptUrl in scriptUrls
        url = "/packages/#{scriptUrl}"

        if @options.parent.versionedUrl
          url = @options.parent.versionedUrl url

        else
          console.warn "Scripts are beeing used without versioning. Url:", url

        scriptFile = new LOI.Adventure.ScriptFile
          url: url
          listener: @

        # Return the generated script file promise.
        scriptFile.promise

      Promise.all(scriptFilePromises).then (scriptFiles) =>
        for scriptFile in scriptFiles
          # Add the loaded and translated script nodes to this location.
          _.extend @scripts, scriptFile.scripts

        @onScriptsLoaded()

        @scriptsReady true

    else
      @scriptsReady true

  destroy: ->
    @exitsTranslationSubscriptions.stop()
    @_scriptTranslationSubscription.stop()
    handle.stop() for handle in @_autorunHandles

  autorun: (handler) ->
    handle = Tracker.autorun handler
    @_autorunHandles.push handle

    handle

  ready: ->
    @scriptsReady()

  onScriptsLoaded: -> # Override to start reactive logic. Use @scripts to get access to script objects.

  onCommand: (commandResponse) -> # Override to listen to commands.
