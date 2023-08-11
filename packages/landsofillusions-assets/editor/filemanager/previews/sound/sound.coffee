AE = Artificial.Everywhere
AM = Artificial.Mirage
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.FileManager.Previews.Sound extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.Editor.FileManager.Previews.Sound'
  @register @id()

  onCreated: ->
    super arguments...
    
    @fileManager = @ancestorComponentOfType LOI.Assets.Editor.FileManager
    
    @buffer = new ReactiveField null
    
    @audioContext = @fileManager.options.audioContext
    
    @source = new ReactiveField null
    
    @autorun (computation) =>
      return unless sound = @data()

      url = sound.name
      
      @buffer null

      request = new XMLHttpRequest
      request.open 'GET', url, true
      request.responseType = 'arraybuffer'

      request.onload = =>
        # Make sure the URL points to an audio MIME type.
        contentType = request.getResponseHeader 'content-type'
        return unless _.startsWith contentType, 'audio'
        
        @audioContext.decodeAudioData request.response, (buffer) =>
          # Make sure the url is still the same as at the start of the request.
          return unless @data()?.name is url

          # Update the buffer.
          @buffer buffer

      request.send()

  onRendered: ->
    super arguments...
    
    # DOM has been rendered, initialize.
    $canvas = @$('.canvas')
    canvas = $canvas[0]
    context = canvas.getContext '2d'
    
    # Draw the waveform.
    @autorun (computation) =>
      context.clearRect 0, 0, 100, 20
      
      return unless buffer = @buffer()
      
      context.strokeStyle = "#7c8ce0"
      context.lineWidth = 1
      context.beginPath()
      
      context.moveTo 0, 10.5
      
      channelData = buffer.getChannelData 0
      step = Math.floor channelData.length / 1000
      
      for sample, index in channelData by step
        context.lineTo 100 * index / channelData.length, 10 * (1 + sample)
      
      context.lineTo 100, 10.5
      context.stroke()
      
      canvas
      
  onDestroyed: ->
    super arguments...
    
    @_stopSource()
    
  _stopSource: ->
    if source = @source()
      source.stop()
      source.disconnect @audioContext.destination
      @source null

  events: ->
    super(arguments...).concat
      'click .play-button': @onClickPlayButton
      'click .stop-button': @onClickStopButton
  
  onClickPlayButton: (event) ->
    source = new AudioBufferSourceNode @audioContext,
      buffer: @buffer()

    source.connect @audioContext.destination
    source.onended = => @_stopSource()
    source.start()
    
    @source source
    
  onClickStopButton: ->
    @_stopSource()
