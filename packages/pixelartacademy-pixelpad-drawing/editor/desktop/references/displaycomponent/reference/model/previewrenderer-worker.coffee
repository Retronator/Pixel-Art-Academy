import * as THREE from 'three'
import {DRACOLoader} from 'three/addons/loaders/DRACOLoader.js'
import {GLTFLoader} from 'three/addons/loaders/GLTFLoader.js'
import {HDRLoader} from 'three/addons/loaders/HDRLoader.js'

# Run make after changing this source. The bundle must remain self-contained so packaged Electron clients do not need
# a server endpoint for Three.js modules. All model reference previews share this worker, canvas, and WebGL context.
canvas = new OffscreenCanvas 1, 1
renderer = new THREE.WebGLRenderer
  canvas: canvas
  antialias: true

ReferenceModelHelpers.configureRenderer THREE, renderer

dracoLoader = new DRACOLoader
dracoLoader.setDecoderPath '/artificial/everywhere/three/draco/'

gltfLoader = new GLTFLoader
gltfLoader.setDRACOLoader dracoLoader

hdrLoader = new HDRLoader

renderQueue = Promise.resolve()

self.addEventListener 'message', (event) ->
  {requestId, configuration} = event.data
  previousRenderQueue = renderQueue

  # Serialize requests because every preview deliberately uses the same renderer and canvas.
  renderQueue = do ->
    await previousRenderQueue

    try
      imageDataUrl = await render configuration
      self.postMessage {requestId, imageDataUrl}

    catch error
      self.postMessage
        requestId: requestId
        error: error.stack or error.message or "#{error}"

render = (configuration) ->
  {displayOptions} = configuration
  scene = new THREE.Scene

  [loadedData, environmentTexture] = await Promise.all [
    gltfLoader.loadAsync configuration.imageUrl
    loadEnvironment displayOptions.environment
  ]

  modelScene = loadedData.scene
  scene.add modelScene

  ReferenceModelHelpers.applyMeshVisibility THREE, scene, displayOptions.meshVisibility
  ReferenceModelHelpers.applyMeshMorphing scene, displayOptions.meshMorphing
  ReferenceModelHelpers.applyEnvironment scene, environmentTexture, displayOptions.environment
  ReferenceModelHelpers.applyBackground THREE, scene, environmentTexture, displayOptions.background

  camera = ReferenceModelHelpers.createCamera THREE, displayOptions.camera, configuration.width / configuration.height
  throw new Error 'Reference does not have a compatible camera.' unless camera

  renderer.setSize configuration.width, configuration.height, false
  ReferenceModelHelpers.applyRendererDisplayOptions renderer, displayOptions
  renderer.render scene, camera

  # OffscreenCanvas has no toDataURL. Convert its PNG blob inside the worker so the UI only receives an image URL.
  imageBlob = await canvas.convertToBlob type: 'image/png'
  imageDataUrl = new FileReaderSync().readAsDataURL imageBlob

  disposeScene modelScene
  environmentTexture?.dispose()
  renderer.renderLists.dispose()

  imageDataUrl

loadEnvironment = (environment) ->
  return null unless environment?.url

  texture = await hdrLoader.loadAsync environment.url
  ReferenceModelHelpers.configureEnvironmentTexture THREE, texture

  texture

disposeScene = (scene) ->
  scene.traverse (object) ->
    return unless object.isMesh

    object.geometry.dispose()

    materials = if Array.isArray(object.material) then object.material else [object.material]

    for material in materials
      for value in Object.values material
        if value?.isTexture
          value.source?.data?.close?()
          value.dispose()

      material.dispose()
