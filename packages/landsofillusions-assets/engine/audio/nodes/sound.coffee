LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio.Sound extends LOI.Assets.Engine.Audio.Node
  @type: -> 'LandsOfIllusions.Assets.Engine.Audio.Sound'
  @nodeName: -> 'Sound'

  @initialize()

  @outputs: -> [
    name: 'buffer'
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
    valueType: LOI.Assets.Engine.Audio.ValueTypes.Buffer
  ]

  @parameters: -> [
    name: 'url'
    pattern: String
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
    valueType: LOI.Assets.Engine.Audio.ValueTypes.String
  ]

  constructor: ->
    super arguments...

    @url = null
    @buffer = new ReactiveField null

    # Create and destroy the buffer.
    @autorun =>
      return unless audioManager = @audioManager()

      url = @parametersData()?.url

      # Nothing to do if the buffer is already loading from the correct URL.
      return if url is @url

      @url = url

      if @url
        # Load the buffer.
        @buffer null

        request = new XMLHttpRequest
        request.open 'GET', url, true
        request.responseType = 'arraybuffer'

        request.onload = =>
          # Make sure the URL points to an audio MIME type.
          contentType = request.getResponseHeader 'content-type'
          return unless _.startsWith contentType, 'audio'

          audioManager.context.decodeAudioData request.response, (buffer) =>
            # Make sure the url is still the same as at the start of the request.
            return unless @parametersData()?.url is url

            # Update the buffer.
            @buffer buffer

        request.send()

      else
        # We release the current buffer.
        @buffer null

  getReactiveValue: (output) ->
    return super arguments... unless output is 'buffer'

    @buffer
