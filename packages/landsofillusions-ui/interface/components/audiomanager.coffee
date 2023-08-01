AE = Artificial.Everywhere
AEc = Artificial.Echo
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Interface.Components.AudioManager
  constructor: ->
    # Wait for user interaction before creating audio context.
    @context = new ReactiveField null
    
    $(document).one 'click', (event) =>
      @context new AudioContext

    # Let others reactively know if audio is currently enabled.
    @enabled = new ComputedField =>
      return false unless @context()

      switch LOI.settings.audio.enabled.value()
        when LOI.Settings.Audio.Enabled.On
          true

        when LOI.Settings.Audio.Enabled.Off
          false

        when LOI.Settings.Audio.Enabled.Fullscreen
          AM.Window.isFullscreen()

    # Start and stop context based on enabled state.
    @_startStopAutorun = Tracker.autorun (computation) =>
      return unless @context()
      enabled = @enabled()

      if @context.state is 'suspended' and enabled
        @_start()

      else if @context.state is 'running' and not enabled
        @_stop()
        
  destroy: ->
    @_startStopAutorun.stop()

  _start: ->
    return unless @context.state is 'suspended'
    return if @_resuming
    
    @_resuming = true
    await @context.resume()
    @_resuming = false

  _stop: ->
    return unless @context.state is 'running'
    return if @_suspending
    
    @_suspending = true
    await @context.suspend()
    @_suspending = false
