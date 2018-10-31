AE = Artificial.Everywhere
AEc = Artificial.Echo
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Engine.World.AudioManager
  constructor: (@world) ->
    @context = new (window.AudioContext or window.webkitAudioContext)
    @context.suspend()

    # Wait for user interaction before playing audio.
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
      enabled = @enabled()

      if @context.state is 'suspended' and enabled
        @start()

      else if @context.state is 'running' and not enabled
        @stop()

  waitForInteraction: ->
    @contextValid false
    
    $(document).on 'click.landsofillusions-engine-world-audiomanager', (event) =>
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
