AE = Artificial.Everywhere
AEc = Artificial.Echo
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Engine.World.AudioManager
  constructor: (@world) ->
    # Wait for user interaction before creating audio context.
    @contextValid = new ReactiveField false
    @waitForInteraction()

    # Let others reactively know if audio is currently enabled.
    @enabled = new ComputedField =>
      return false unless @contextValid()

      switch LOI.settings.audio.enabled.value()
        when LOI.Settings.Audio.Enabled.On
          true

        when LOI.Settings.Audio.Enabled.Off
          false

        when LOI.Settings.Audio.Enabled.Fullscreen
          AM.Window.isFullscreen()

    # Start and stop context based on enabled state.
    @world.autorun =>
      return unless @contextValid()
      enabled = @enabled()

      if @context.state is 'suspended' and enabled
        @start()

      else if @context.state is 'running' and not enabled
        @stop()

    unless @world.options.isolatedAudio
      # Subscribe to audio assets based on location.
      @world.autorun =>
        return unless locationId = LOI.adventure.currentLocationId()
        LOI.Assets.Audio.forLocation.subscribe @world, locationId
  
      # Create engine audio assets.
      @engineAudioAssets = {}
  
      @engineAudioDictionary = new AE.ReactiveDictionary =>
        return {} unless locationId = LOI.adventure.currentLocationId()

        audioAssets = {}
        audioAssets[audioAsset._id] = audioAsset for audioAsset in LOI.Assets.Audio.forLocation.query(locationId).fetch()
        audioAssets
      ,
        added: (audioId, audioData) =>
          @engineAudioAssets[audioId] = new LOI.Assets.Engine.Audio
            world: @world
            audioData: new ReactiveField audioData
  
        updated: (audioId, audioData) =>
          @engineAudioAssets[audioId].options.audioData audioData
  
        removed: (audioId, audio) =>
          @engineAudioAssets[audioId].destroy()
          delete @engineAudioAssets[audioId]

  waitForInteraction: ->
    @contextValid false

    $(document).on 'click.landsofillusions-engine-world-audiomanager', (event) =>
      unless @context
        @context = new (window.AudioContext or window.webkitAudioContext)
        @context.suspend()

      @contextValid true

      $(document).off '.landsofillusions-engine-world-audiomanager'

  start: ->
    return unless @context.state is 'suspended'
    return if @_resuming
    @_resuming = true

    @context.resume().then =>
      @_resuming = false

  stop: ->
    return unless @context.state is 'running'
    return if @_suspending
    @_suspending = true

    @context.suspend().then =>
      @_suspending = false
