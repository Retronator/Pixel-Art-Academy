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
  
  @durationToTapeProgress: (duration) ->
    # Make it so that the progress is slowly slowing down and reaches 999 at around 60 minutes.
    duration ** 0.97 / 3
 
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
      PAA.Music.Tape.forId.subscribe @, tapeId
      #PAA.Music.Tape.forId.subscribeContent @, tapeId

    @tape = new ComputedField =>
      return unless tapeId = @state 'tapeId'
      PAA.Music.Tape.documents.findOne tapeId
    
    # Current time tracks the current song's progress in seconds. We use lazy updates to minimize state reactivity.
    @currentTime = @state.field 'currentTime', lazyUpdates: true
    
    @currentTrackInfo = new ComputedField =>
      return unless tape = @tape()
      tape?.sides[@state 'sideIndex']?.tracks[@state 'trackIndex']
      
    @sides = new ComputedField =>
      return unless tape = @tape()
      
      for side in tape.sides
        startTime = 0
        
        tracks = for info, trackIndex in side.tracks
          track =
            index: trackIndex
            info: info
            startTime: startTime
            
          startTime += track.info.duration
          
          track
          
        title: side.title
        tracks: tracks
    
    # Tape progress tracks the dimensionless progress along this side of the tape.
    @tapeProgress = new ReactiveField 0
    
    @_currentTrack = null
    
    # Create track based on current indices.
    @autorun (computation) =>
      @_currentTrack?.destroy()
      @_currentTrack = null

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
        
        @play() if @state 'playing'

  onDestroyed: ->
    super arguments...
    
    @app.removeComponent @
    
    @_currentTrack?.destroy()

    # Disable any ongoing audio.
    @audio.playing false
    @audio.seeking false
  
  setTape: (tape) ->
    @state 'tapeId', tape._id
    @state 'sideIndex', 0
    @state 'trackIndex', 0
    @state 'currentTime', 0
    
  setTrack: (sideIndex, trackIndex) ->
    @state 'sideIndex', sideIndex
    @state 'trackIndex', trackIndex
    @state 'currentTime', 0
    
  play: ->
    Tracker.nonreactive =>
      LOI.adventure.music.startPlayback @_currentTrack
      @state 'playing', true
    
  stop: ->
    Tracker.nonreactive =>
      LOI.adventure.music.stopPlayback @_currentTrack
      @state 'playing', false

  update: (appTime) ->
    return unless @_currentTrack
    return unless @state 'playing'
    
    if @_currentTrack.ended()
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
          @state 'playing', false
      
    else
      currentTime = @_currentTrack.currentTime()
      @currentTime currentTime

      tapeProgressDuration = @_startTime + currentTime
      @tapeProgress @constructor.durationToTapeProgress tapeProgressDuration
