AB = Artificial.Base
AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Systems.Music extends PAA.PixelPad.System
  # tapeId: the ID of the tape that is currently playing (or ready to be played)
  # sideIndex: the index of the active side the tape
  # trackIndex: the index of the active track on the active side
  # currentTime: lazily-updated number of seconds that the active track's playback is on
  # playing: boolean whether the music should be playing
  @id: -> 'PixelArtAcademy.PixelPad.Systems.Music'

  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Music"
  @description: ->
    "
      The music system for playing tapes collected during gameplay.
    "

  @initialize()
 
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      openDoor: AEc.ValueTypes.Trigger
      closeDoor: AEc.ValueTypes.Trigger
      insertTape: AEc.ValueTypes.Trigger
      removeTape: AEc.ValueTypes.Trigger
      playing: AEc.ValueTypes.Boolean
      seeking: AEc.ValueTypes.Boolean
  
  onCreated: ->
    super arguments...
    
    @app = @ancestorComponentOfType AB.App
    @app.addComponent @
    
    # Subscribe to the tape from both the content (local tapes) and server (extra tapes).
    @autorun (computation) =>
      return unless tapeId = @state 'tapeId'
      PAA.Music.Tape.forId.subscribeContent @, tapeId
      PAA.Music.Tape.forId.subscribe @, tapeId

    @tape = new ComputedField =>
      return unless tapeId = @state 'tapeId'
      PAA.Music.Tape.documents.findOne tapeId
    
    # Current time tracks the current song's progress in seconds. We use lazy updates to minimize state reactivity.
    @currentTime = @state.field 'currentTime', lazyUpdates: true
    
    @sides = new ComputedField => @tape()?.getSidesWithTapeProgress()
    
    # Tape progress tracks the dimensionless progress along this side of the tape.
    @tapeProgress = new ReactiveField 0
    
    @_currentTrack = null
    
    # Create track based on current indices.
    @autorun (computation) =>
      @_destroyCurrentTrack()
      Meteor.clearTimeout @_musicStartTimeout

      return unless LOI.adventure.music.enabled()
      return unless tape = @tape()
      return unless sides = @sides()
      
      sideIndex = @state 'sideIndex'
      trackIndex = @state 'trackIndex'
      
      return unless sideIndex?
      return unless trackIndex?
      
      Tracker.nonreactive =>
        trackInfo = tape.sides[sideIndex].tracks[trackIndex]
        
        @_currentTrack = new PAA.Music.Track LOI.adventure.audioManager, trackInfo.title, tape.artist, trackInfo.url

        currentTime = @currentTime()
        @_currentTrack.setCurrentTime currentTime if currentTime

        @_startTime = sides[sideIndex].tracks[trackIndex].startTime
        
        if @state 'playing'
          # If the song was already playing and it's not at the start, we must fade into it after the starting delay.
          if currentTime
            @_musicStartTimeout = Meteor.setTimeout =>
              LOI.adventure.music.startPlayback @_currentTrack, PAA.Music.FadeDurations.PrePlayingMusicOnLoadFadeIn
            ,
              PAA.Music.StartTimeoutDuration * 1000
            
          else
            LOI.adventure.music.startPlayback @_currentTrack, 0, PAA.Music.FadeDurations.DynamicSoundtrackToMusicAppFadeOut

  onDestroyed: ->
    super arguments...
    
    @app.removeComponent @
    
    @_currentTrack?.destroy()
    
    Meteor.clearTimeout @_musicStartTimeout

    # Disable any ongoing audio.
    @audio.playing false
    @audio.seeking false
    
  _destroyCurrentTrack: ->
    @_currentTrack?.destroy()
    @_currentTrack = null
  
  setTape: (tape) ->
    @_destroyCurrentTrack()

    Tracker.nonreactive =>
      if tape
        @state 'tapeId', tape._id
        @state 'sideIndex', 0
        @state 'trackIndex', 0
        @state 'currentTime', 0
        @tapeProgress 0
        
      else
        @stop()
        @state 'tapeId', null
    
  setTrack: (sideIndex, trackIndex) ->
    Tracker.nonreactive =>
      @state 'currentTime', 0

      # If the track is already set, just reset the time.
      if sideIndex is @state('sideIndex') and trackIndex is @state('trackIndex')
        @_currentTrack?.setCurrentTime 0
        return
      
      @_destroyCurrentTrack()
    
      @state 'sideIndex', sideIndex
      @state 'trackIndex', trackIndex
    
  play: ->
    Tracker.nonreactive =>
      return if @state 'playing'
      
      LOI.adventure.music.startPlayback @_currentTrack, 0, PAA.Music.FadeDurations.DynamicSoundtrackToMusicAppFadeOut if @_currentTrack
      @state 'playing', true
    
  stop: ->
    Tracker.nonreactive =>
      LOI.adventure.music.stopPlayback() if @_currentTrack and LOI.adventure.music.isPlayingPlayback @_currentTrack
      @state 'playing', false
      
  nextTrack: ->
    Tracker.nonreactive =>
      # Go to the next track if possible.
      sides = @sides()
      sideIndex = @state 'sideIndex'
      trackIndex = @state 'trackIndex'
      
      trackIndex++
      
      if sides[sideIndex].tracks[trackIndex]
        @setTrack sideIndex, trackIndex
      
      else
        # Go to the next side if possible.
        sideIndex++
        
        if sides[sideIndex]
          @setTrack sideIndex, 0
          
        else
          # We reached the end of the tape, stop playing.
          @stop()
    
  rewindOrPreviousTrack: ->
    Tracker.nonreactive =>
      # Rewind if possible.
      currentTime = @state 'currentTime'
      @state 'currentTime', 0
      @_currentTrack.setCurrentTime 0
      return if currentTime > 1
      
      # Go to the previous track if possible.
      sides = @sides()
      sideIndex = @state 'sideIndex'
      trackIndex = @state 'trackIndex'
      
      trackIndex--
      
      if sides[sideIndex].tracks[trackIndex]
        @setTrack sideIndex, trackIndex
      
      else
        # Go to the previous side if possible.
        sideIndex--
        
        if sides[sideIndex]
          @setTrack sideIndex, sides[sideIndex].tracks.length - 1
    
  update: (appTime) ->
    return unless @_currentTrack
    return unless @state 'playing'
    
    if @_currentTrack.ended()
      @nextTrack()
      
    else
      currentTime = @_currentTrack.currentTime()
      @currentTime currentTime

      tapeProgressDuration = @_startTime + currentTime
      @tapeProgress PAA.Music.Tape.durationToTapeProgress tapeProgressDuration
