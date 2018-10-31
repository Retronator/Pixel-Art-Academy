LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio.Sound extends LOI.Assets.Engine.Audio.Node
  @type: -> 'LandsOfIllusions.Assets.Engine.Audio.Sound'
  @nodeName: -> 'Sound'

  @initialize()

  @outputs: -> [
    name: 'stereo'
  ]

  @parameters: -> [
    name: 'url'
    pattern: String
  ]

  constructor: ->
    super arguments...

    @_source = null
    @url = null

    @buffer = new ReactiveField null

    # Create and destroy the source.
    @source = new ComputedField =>
      # Audio context needs to be valid.
      return unless audioManager = @audioManager()

      if audioManager.contextValid()
        url = @parameters()?.url

        if @_source
          if url is @url
            # Nothing to do, the source is already created and playing the correct URL.
            return @_source

          else
            # Disconnect the current source before creating the new one.
            @_source.disconnect()

        @url = url

        if @url
          # Create the source.
          @_source = audioManager.context.createBufferSource();
          @buffer null

          request = new XMLHttpRequest
          request.open 'GET', url, true
          request.responseType = 'arraybuffer'

          request.onload = =>
            audioManager.context.decodeAudioData request.response, (buffer) =>
              @_source.buffer = buffer
              @_source.loop = true
              @_source.start()

              @buffer buffer
          'arraybuffer'

          request.send()

        else
          # We can't create a source without an URL.
          @_source = null
          @buffer null

        @_source

      else
        # Context is not yet valid or was invalidated so disconnect an existing source.
        if @_source
          @_source.disconnect()
          @_source = null

          @url = null
          @buffer null

        null
    ,
      (a, b) => a is b
    ,
      true

  destroy: ->
    super arguments...

    @_source?.disconnect()
    @source.stop()

  getSourceConnection: (outputName) ->
    source: @source()
    index: @getOutputIndex outputName
