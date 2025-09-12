AE = Artificial.Everywhere
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent.Reference.Model.Loader
  @gltfLoader = new THREE.GLTFLoader

  dracoLoader = new THREE.DRACOLoader
  dracoLoader.setDecoderPath '/artificial/everywhere/three/draco/'
  @gltfLoader.setDRACOLoader dracoLoader

  @models = {}

  @load: (path, onLoadHandler) ->
    # See if we've already come across this path.
    if model = @models[path]
      # See if this model was already loaded.
      if model.loaded
        # Simply pass the loaded data to the handler.
        onLoadHandler model.data

      else
        # Add the handler to the waiting list.
        model.waitingOnLoadHandlers.push onLoadHandler

      return

    # We need to start loading this model.
    model = waitingOnLoadHandlers: [onLoadHandler]
    @models[path] = model

    @gltfLoader.load path, (loadedData) =>
      model = @models[path]
      model.data = loadedData
      model.loaded = true

      onLoadHandler model.data for onLoadHandler in model.waitingOnLoadHandlers
