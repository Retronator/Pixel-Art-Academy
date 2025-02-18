AEc = Artificial.Echo

class AEc.Sound
  constructor: (@url, @audioManager, @destination) ->
    @buffer = new ReactiveField null
    
    Tracker.nonreactive =>
      @_loadAutorun = Tracker.autorun (computation) =>
        return unless context = @audioManager.context()
        computation.stop()
        
        # Load the buffer.
        request = new XMLHttpRequest
        request.open 'GET', @url, true
        request.responseType = 'arraybuffer'
  
        request.onload = =>
          # Make sure the URL points to an audio MIME type.
          contentType = request.getResponseHeader 'content-type'
          return unless _.startsWith contentType, 'audio'
  
          context.decodeAudioData request.response, (buffer) =>
            # Update the buffer.
            @buffer buffer
  
        request.send()
      
  destroy: ->
    @buffer null
    @_loadAutorun.stop()
    
  play: (options) ->
    return unless context = @audioManager.context()
    return unless buffer = @buffer()
    
    source = new AudioBufferSourceNode context, {buffer}
   
    source.detune.value = options.detune if options?.detune
    
    destination = options?.destination or @destination
    
    if options?.volume
      gain = new GainNode context, gain: options.volume
      source.connect gain
      gain.connect destination
    
    else
      source.connect destination

    source.start()
    
    source
