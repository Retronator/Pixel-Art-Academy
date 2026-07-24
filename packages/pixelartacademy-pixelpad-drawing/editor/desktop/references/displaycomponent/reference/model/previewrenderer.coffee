PAA = PixelArtAcademy

# Preview renderer that renders and caches model reference previews in a web worker.
class PAA.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent.Reference.Model.PreviewRenderer
  @workerUrl: '/packages/retronator_pixelartacademy-pixelpad-drawing/editor/desktop/references/displaycomponent/reference/model/previewrenderer-worker-bundle.js'

  @initialize: ->
    return if @_initialized
    @_initialized = true

    @_nextRequestId = 1
    @_requests = {}
    @_previews = {}

    @_worker = new Worker @workerUrl
    @_worker.addEventListener 'message', (event) => @_onWorkerMessage event
    @_worker.addEventListener 'error', (event) => console.error 'Model reference preview renderer failed.', event

  @render: (configuration, callback) ->
    @initialize()

    configurationKey = @getConfigurationKey configuration
    
    @_previews[configurationKey] ?=
      requestCount: 0
      
    preview = @_previews[configurationKey]
    preview.requestCount++
    
    # Keep the cached image around when the same configuration gets requested again soon after release.
    clearTimeout preview.releaseTimeout

    # Reuse the image if this exact model presentation has already been rendered.
    if preview.imageDataUrl
      callback preview.imageDataUrl
      return configurationKey

    # Multiple components can ask for the same image before the first render finishes.
    if existingRequest = _.find @_requests, (request) => request.configurationKey is configurationKey
      existingRequest.callbacks.push callback
      return configurationKey

    @_nextRequestId++
    
    @_requests[@_nextRequestId] =
      configurationKey: configurationKey
      callbacks: [callback]

    @_worker.postMessage
      requestId: @_nextRequestId
      configuration: configuration
    
    # Return the configuration key used for releasing the render.
    configurationKey
    
  @getConfigurationKey: (configuration) ->
    EJSON.stringify configuration

  @release: (configurationKey) ->
    return unless @_initialized
    return unless preview = @_previews[configurationKey]

    preview.requestCount--
    return if preview.requestCount

    # Give fast reactive changes a chance to reuse the cached image before clearing it.
    preview.releaseTimeout = setTimeout =>
      delete @_previews[configurationKey]
    ,
      1000

  @_onWorkerMessage: (event) ->
    {requestId, imageDataUrl, error} = event.data
    
    request = @_requests[requestId]
    delete @_requests[requestId]
    
    # The preview might have been released before rendering finished.
    return unless preview = @_previews[request.configurationKey]

    if error
      console.error 'Could not render model reference preview.', error, request

    else
      preview.imageDataUrl = imageDataUrl
      
    callback imageDataUrl for callback in request.callbacks
