AE = Artificial.Everywhere
AEc = Artificial.Echo
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Interface.Components.AudioManager
  constructor: (@interface) ->
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
    @interface.autorun =>
      return unless @contextValid()
      enabled = @enabled()

      if @context.state is 'suspended' and enabled
        @start()

      else if @context.state is 'running' and not enabled
        @stop()

  waitForInteraction: ->
    @contextValid false

    $(document).one 'click', (event) =>
      unless @context
        @context = new AudioContext
        @context.suspend()

      @contextValid true

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
