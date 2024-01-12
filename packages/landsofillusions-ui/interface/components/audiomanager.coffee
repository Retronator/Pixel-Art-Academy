AE = Artificial.Everywhere
AEc = Artificial.Echo
AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Interface.Components.AudioManager
  constructor: ->
    @context = new ReactiveField null
    @running = new ReactiveField false
    
    if AB.ApplicationEnvironment.isBrowser
      # In the browser, we need to wait for user interaction before creating audio context.
      $(document).one 'click', (event) =>
        @_createContext()
        
    else
      # Otherwise audio should be available from the start.
      @_createContext()

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
      return unless context = @context()
      enabled = @enabled()

      if context.state is 'suspended' and enabled
        @_start()

      else if context.state is 'running' and not enabled
        @_stop()
        
  destroy: ->
    @_startStopAutorun.stop()
    
  _createContext: ->
    @context new AudioContext
    @running true

  _start: ->
    return unless context = @context()
    return unless context.state is 'suspended'
    return if @_resuming
    
    @_resuming = true
    await context.resume()
    @_resuming = false
    
    @running true

  _stop: ->
    return unless context = @context()
    return unless context.state is 'running'
    return if @_suspending
    
    @_suspending = true
    await context.suspend()
    @_suspending = false
    
    @running false
