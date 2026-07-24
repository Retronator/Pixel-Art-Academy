ReferenceModelHelpers =
  configureRenderer: (THREE, renderer) ->
    renderer.toneMapping = THREE.ACESFilmicToneMapping

  applyRendererDisplayOptions: (renderer, displayOptions = {}) ->
    renderer.toneMappingExposure = 2 ** (displayOptions.exposureValue or 0)

  createCamera: (THREE, cameraData, aspectRatio) ->
    zNear = cameraData?.zNear or 0.01
    zFar = cameraData?.zFar or 100

    if cameraData?.fieldOfView
      camera = new THREE.PerspectiveCamera cameraData.fieldOfView, aspectRatio, zNear, zFar

    else if frustum = cameraData?.frustum
      camera = new THREE.OrthographicCamera(
        frustum.left or -frustum.width / 2
        frustum.right or frustum.width / 2
        frustum.top or frustum.height / 2
        frustum.bottom or -frustum.height / 2
        zNear
        zFar
      )

    else
      return null

    @updateCameraAspectRatio camera, aspectRatio
    @applyCameraProperties camera, @getCameraProperties cameraData

    camera

  updateCameraAspectRatio: (camera, aspectRatio) ->
    camera.aspect = aspectRatio
    camera.updateProjectionMatrix()

  getCameraProperties: (cameraData = {}) ->
    azimuthalAngle: cameraData.azimuthalAngle ? 0
    polarAngle: cameraData.polarAngle ? 0
    radialDistance: cameraData.radialDistance ? 1

  applyCameraProperties: (camera, properties) ->
    camera.position.setFromSphericalCoords properties.radialDistance, properties.polarAngle, properties.azimuthalAngle
    camera.rotation.set -Math.PI / 2 + properties.polarAngle, properties.azimuthalAngle, 0, 'YXZ'

  getMeshVisibilityProperties: (meshVisibility = {}) ->
    amountVisible: meshVisibility.amountVisible ? 1
    sizePreference: meshVisibility.sizePreference ? 0

  applyMeshVisibility: (THREE, scene, meshVisibility, meshVisibilityProperties) ->
    return unless meshVisibility

    meshVisibilityProperties ?= @getMeshVisibilityProperties meshVisibility

    # Collect meshes with their original priority and size-based ordering.
    orderedMeshes = []
    meshSizeVector = new THREE.Vector3

    scene.traverse (object) =>
      return unless object.isMesh

      object.geometry.computeBoundingBox()
      object.geometry.boundingBox.getSize meshSizeVector

      sizeMeasurementAxes = meshVisibility.sizeMeasurementAxes or {x: true, y: true, z: true}
      meshSize = 1
      meshSize *= meshSizeVector[coordinate] for coordinate, include of sizeMeasurementAxes when include

      orderedMeshes.push
        mesh: object
        size: meshSize
        priorityOrder: orderedMeshes.length + 1

    orderedMeshes.sort (a, b) => b.size - a.size

    sizeWeight = meshVisibilityProperties.sizePreference
    priorityWeight = 1 - sizeWeight

    for orderedMesh, meshIndex in orderedMeshes
      orderedMesh.sizeOrder = meshIndex + 1
      orderedMesh.weightedOrder = orderedMesh.priorityOrder * priorityWeight + orderedMesh.sizeOrder * sizeWeight

    orderedMeshes.sort (a, b) => a.weightedOrder - b.weightedOrder

    visibleCount = 1 + (orderedMeshes.length - 1) * meshVisibilityProperties.amountVisible

    for orderedMesh, meshIndex in orderedMeshes
      orderedMesh.mesh.visible = meshIndex < visibleCount

  applyMeshMorphing: (scene, meshMorphingProperties = {}) ->
    scene.traverse (object) ->
      return unless object.isMesh

      for morphKey, morphInfluenceIndex of object.morphTargetDictionary or {} when meshMorphingProperties[morphKey]?
        object.morphTargetInfluences[morphInfluenceIndex] = meshMorphingProperties[morphKey]

      # Explicit return to avoid result collection.
      return

  configureEnvironmentTexture: (THREE, texture) ->
    texture.mapping = THREE.EquirectangularReflectionMapping
    texture.magFilter = THREE.LinearFilter

  applyEnvironment: (scene, environmentTexture, environment) ->
    scene.environment = environmentTexture
    return unless environmentRotation = environment?.rotation

    scene.environmentRotation.set(
      environmentRotation.x or 0
      environmentRotation.y or 0
      environmentRotation.z or 0
      environmentRotation.order
    )

  applyBackground: (THREE, scene, environmentTexture, background) ->
    return unless background

    if background.color
      scene.background = new THREE.Color background.color

    else if background.environment
      scene.background = environmentTexture

PixelArtAcademy?.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent.Reference.Model.Helpers = ReferenceModelHelpers
