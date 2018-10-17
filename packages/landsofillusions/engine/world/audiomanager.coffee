AE = Artificial.Everywhere
AEc = Artificial.Echo
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Engine.World.AudioManager
  constructor: (@world) ->
    @context = new (window.AudioContext or window.webkitAudioContext)
    @context.suspend()

    # Wait for user interaction before playing audio.
    @_interacted = new ReactiveField false
    @_unplayedUrls = []
    @waitForInteraction()

    # Let others reactively know if audio is currently enabled.
    @enabled = new ComputedField =>
      return false unless @_interacted()

      switch LOI.settings.audio.enabled.value()
        when LOI.Settings.Audio.Enabled.On
          true

        when LOI.Settings.Audio.Enabled.Off
          false

        when LOI.Settings.Audio.Enabled.Fullscreen
          AM.Window.isFullscreen()

    # Start and stop context based on enabled state.
    @world.autorun =>
      enabled = @enabled()

      if @context.state is 'suspended' and enabled
        @start()

      else if @context.state is 'running' and not enabled
        @stop()

  waitForInteraction: ->
    @_interacted false
    
    $(document).on 'click.landsofillusions-engine-world-audiomanager', (event) =>
      @_interacted true
      $(document).off '.landsofillusions-engine-world-audiomanager'

  start: ->
    return unless @context.state is 'suspended'
    return if @_resuming
    @_resuming = true

    @context.resume().then =>
      @_resuming = false

      @play url for url in @_unplayedUrls
      @_unplayedUrls = []

  stop: ->
    return unless @context.state is 'running'
    return if @_suspending
    @_suspending = true

    @context.suspend().then =>
      @_suspending = false

  play: (url) ->
    unless @_interacted()
      @_unplayedUrls.push url
      return

    audio = $("<audio src='#{url}' type='audio/mpeg'>")[0]
    soundEffect = @context.createMediaElementSource audio
    soundEffect.connect @context.destination

    audio.play()
