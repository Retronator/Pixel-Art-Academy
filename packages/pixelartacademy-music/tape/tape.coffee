AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Music.Tape extends AM.Document
  @id: -> 'PixelArtAcademy.Music.Tape'
  # title: optional name of this tape
  # artist: the author's name
  # slug: auto-generated URL identifier of the tape
  # styleClass: class name added to the tape for styling purposes
  # gain: specify to adjust volume of the tape, 1 by default
  # sides: array with 1 or 2 sides
  #   title: optional name of this side of the tape
  #   tracks: an array of tracks on this side
  #     title: name of the track
  #     duration: length of the track in seconds
  #     url: location of the audio file to be played for this track
  @Meta
    name: @id()
    fields: =>
      slug: Document.GeneratedField 'self', ['title', 'artist', 'sides'], (tape) =>
        [tape._id, @createSlug tape]
      
  @enableDatabaseContent()
  
  @createSlug: (tape) ->
    parts = [tape.artist]
    
    if tape.title
      parts.push tape.title
    
    else
      parts.push side.title for side in tape.sides
    
    _.kebabCase parts.join ' '
  
  # Subscriptions
  
  @all = @subscription 'all'
  @forId = @subscription 'forId'
  
  @durationToTapeProgress: (duration) ->
    # Make it so that the progress is slowly slowing down and reaches 999 at around 60 minutes.
    duration ** 0.97 / 3
  
  getSidesWithTapeProgress: ->
    # Calculate start times and tape progress markers.
    for side in @sides
      startTime = 0
      
      title: side.title
      tracks: for track in side.tracks
        trackWithTapeProgress = _.extend {}, track,
          startTime: startTime
          tapeProgress: @constructor.durationToTapeProgress startTime
        
        startTime += Math.ceil track.duration

        trackWithTapeProgress
