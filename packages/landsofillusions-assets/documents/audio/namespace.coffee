AE = Artificial.Everywhere
AEc = Artificial.Echo
LOI = LandsOfIllusions

class LOI.Assets.Audio.Namespace
  constructor: (@id, @options = {}) ->
    @options.unloadDelay ?= 0
    
    # Create variables.
    @variables = {}
    
    for name, valueTypeOrVariableOptions of @options.variables
      @variables[name] = new AEc.Variable "#{@id}.#{name}", valueTypeOrVariableOptions
      
    @loadedCount = 0

  load: (audioManager) ->
    # Don't load documents in a sub-namespace since they will already be handled from the top namespace.
    return if @options.subNamespace
    
    @loadedCount++
    return if @loadedCount > 1
    
    Meteor.clearTimeout @_unloadTimeout
    @_stop()
  
    # Subscribe to audio assets in the namespace.
    path = @id.toLowerCase().replaceAll('.', '/')
    
    @_subscriptionAutorun = Tracker.autorun (computation) =>
      return unless audioManager.enabled()
      
      LOI.Assets.Audio.forNamespace.subscribe path
      LOI.Assets.Audio.forNamespace.subscribeContent path
    
    # Create engine audio assets.
    @engineAudioAssets = {}
    
    @engineAudioDictionary = new AE.ReactiveDictionary =>
      audioAssets = {}
      audioAssets[audioAsset._id] = audioAsset for audioAsset in LOI.Assets.Audio.forNamespace.query(path).fetch()
      audioAssets
    ,
      added: (audioId, audioData) =>
        @engineAudioAssets[audioId] = Tracker.nonreactive =>
          nodesDataProvider = new ReactiveField audioData.nodes
          new AEc.Audio audioId, audioManager.context(), nodesDataProvider
      
      updated: (audioId, audioData) =>
        @engineAudioAssets[audioId].nodesDataProvider audioData.nodes
      
      removed: (audioId, audio) =>
        @engineAudioAssets[audioId].destroy()
        delete @engineAudioAssets[audioId]
      
  unload: ->
    return if @options.subNamespace
    
    @loadedCount--
    return if @loadedCount > 0
    
    @_unloadTimeout = Meteor.setTimeout =>
      @_stop()
    ,
      @options.unloadDelay * 1000
    
  _stop: ->
    @_subscriptionAutorun?.stop()
    @engineAudioDictionary?.stop()
