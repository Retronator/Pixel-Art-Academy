AMe = Artificial.Melody

class AMe.Event.Player extends AMe.Event
  constructor: ->
    super arguments...
    
    @time ?= 0
    @sourceOffset ?= 0
    
    # Load the audio buffer.
    @section.composition.loadAudioBuffer @audioUrl
  
  schedule: (sectionStartTime, output) ->
    context = @section.composition.audioManager.context()
    buffer = @section.composition.getAudioBuffer @audioUrl
    
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
