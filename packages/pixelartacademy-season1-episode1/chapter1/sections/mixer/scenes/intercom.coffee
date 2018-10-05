LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.Intercom extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Mixer.Intercom'

  @location: ->
    # Intercom is present everywhere, but activates only on HQ locations.
    null

  @initialize()

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/sections/mixer/scenes/intercom.script'

  constructor: ->
    super
    
    @_playAutorun = Tracker.autorun (computation) =>
      # See if we've already played the message.
      if @state 'announcementDone'
        computation.stop()
        return

      # Wait until the player is in the HQ.
      return unless LOI.adventure.currentRegionId() is Retronator.HQ.id()
      
      # Prevent from playing twice, but retry if no script is playing.
      scriptQueue = LOI.adventure.director.foregroundScriptQueue
      @_scriptPlaying = false unless scriptQueue.currentScriptNode() or scriptQueue.queuedScriptNodes().length
      return if @_scriptPlaying

      # Make sure the script has loaded.
      return unless @listeners[0].scriptsReady()

      # Play the script and mark that it's playing to prevent starting twice.
      @_scriptPlaying = true
      @listeners[0].startScript()

  # Script

  initializeScript: ->
    scene = @options.parent

    @setThings @options.listener.avatars
    
    @setCallbacks
      AnnouncementDone: (complete) =>
        # Mark that we've played the announcement.
        scene.state 'announcementDone', true

        complete()

  # Listener

  @avatars: ->
    shelley: HQ.Actors.Shelley
