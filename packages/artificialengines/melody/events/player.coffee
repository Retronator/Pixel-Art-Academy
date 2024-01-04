AMe = Artificial.Melody

class AMe.Event.Player extends AMe.Event
  constructor: ->
    super arguments...
    
    @time ?= 0
    @sourceOffset ?= 0
    
    # Load the audio buffer.
    @audioBuffer = new ReactiveField null

    # Create and destroy the buffer.
    @_bufferAutorun = Tracker.autorun (computation) =>
      return unless context = @audioManager.context()
      computation.stop()
      
      console.log "Loading Player event buffer", @audioUrl if AMe.debug

      request = new XMLHttpRequest
      request.open 'GET', @audioUrl, true
      request.responseType = 'arraybuffer'

      request.onload = =>
        # Make sure the URL points to an audio MIME type.
        contentType = request.getResponseHeader 'content-type'
        return unless _.startsWith contentType, 'audio'

        context.decodeAudioData request.response, (buffer) =>
          # Update the buffer.
          @audioBuffer buffer
          
          console.log "Loaded Player event buffer", @audioUrl, buffer if AMe.debug
      
      request.send()
    
  destroy: ->
    super arguments...
    
    @_bufferAutorun.stop()
    @audioBuffer null
  
  ready: -> @audioBuffer()
  
  schedule: (sectionStartTime, output) ->
    context = @audioManager.context()
    buffer = @audioBuffer()
    
    source = new AudioBufferSourceNode context, {buffer}
    
    if @volume
      gain = new GainNode context, gain: @volume
      source.connect gain
      gain.connect output
      
    else
      source.connect output
    
    whenToStart = sectionStartTime + @time
    
    if @duration?
      source.start whenToStart, @sourceOffset, @duration
    
    else
      source.start whenToStart, @sourceOffset
      
    console.log "Scheduled source node at", context.currentTime, "for time", whenToStart, "offset", @sourceOffset, "duration", @duration, @audioUrl if AMe.debug
    
    new AMe.EventHandle @, =>
      source.stop()
