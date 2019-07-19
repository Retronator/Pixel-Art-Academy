AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Tools.ClusterPicker extends LOI.Assets.MeshEditor.Tools.Tool
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Tools.ClusterPicker'
  @displayName: -> "Cluster picker"

  @initialize()

  onMouseDown: (event) ->
    super arguments...

    @pickCluster true

  onMouseMove: (event) ->
    super arguments...

    @pickCluster false

  pickCluster: (cycle) ->
    return unless @mouseState.leftButton

    meshCanvas = @editor()

    if meshCanvas.sourceImageEnabled()
      @_pickCluster2D cycle

    else
      @_pickCluster3D cycle

  _pickCluster2D: (cycle) ->
    meshCanvas = @editor()
    mesh = meshCanvas.meshData()
    cameraAngleIndex = meshCanvas.cameraAngleIndex()

    # Find clusters at the clicked coordinate.
    clusters = []
    pixelCoordinate = meshCanvas.mouse().pixelCoordinate()

    for object in mesh.objects.getAll()
      for layer in object.layers.getAll()
        picture = layer.getPictureForCameraAngleIndex cameraAngleIndex

        clusterId = picture.getClusterIdForPixel pixelCoordinate.x, pixelCoordinate.y
        clusters.push layer.clusters.get clusterId if clusterId

    @_pickFromClusters cycle, clusters

  _pickCluster3D: (cycle) ->
    meshCanvas = @editor()

    canvasCoordinate = meshCanvas.mouse().canvasCoordinate()
    raycaster = meshCanvas.renderer.cameraManager.getRaycaster x: canvasCoordinate.x - 0.5, y: canvasCoordinate.y - 0.5
    scene = meshCanvas.sceneHelper().scene()

    intersectionsForward = raycaster.intersectObjects scene.children, true

    # Since we don't use double-sided materials, we need to reverse the ray and intersect again.
    raycaster.ray.origin.add raycaster.ray.direction.clone().multiplyScalar 10000
    raycaster.ray.direction.negate()

    intersectionsBackward = raycaster.intersectObjects scene.children, true

    intersections = intersectionsForward.concat intersectionsBackward

    # Filter intersections to clusters.
    clusters = []

    for intersection in intersections when intersection.object.parent instanceof LOI.Assets.Engine.Mesh.Object.Layer.Cluster
      clusters.push intersection.object.parent.clusterData

    # Get only one instance of each cluster (if it was picked multiple times).
    clusters = _.uniq clusters

    @_pickFromClusters cycle, clusters

  _pickFromClusters: (cycle, clusters) ->
    currentClusterHelper = @interface.getHelperForActiveFile LOI.Assets.MeshEditor.Helpers.CurrentCluster

    unless clusters.length
      currentClusterHelper.setCluster null
      return

    currentCluster = currentClusterHelper.cluster()

    if cycle
      # Reset selection when picked clusters change.
      @_clusterIndex = 0 if _.xor(clusters, @_previousClusters).length

      # If we have more than one choice, move to the next one that isn't selected yet.
      if clusters.length > 1
        @_clusterIndex++ while clusters[@_clusterIndex % clusters.length] is currentCluster

    else
      # Always choose first cluster.
      @_clusterIndex = 0

    cluster = clusters[@_clusterIndex % clusters.length]
    @_previousClusters = clusters

    # Set the cluster as the current cluster.
    currentClusterHelper.setCluster cluster

    return unless cluster

    material = cluster.material()
    paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint

    if material.paletteColor
      paintHelper.setPaletteColor material.paletteColor

    else if material.directColor
      paintHelper.setDirectColor material.directColor

    else if material.materialIndex?
      paintHelper.setMaterialIndex material.materialIndex

    if material.normal
      paintHelper.setNormal material.normal

    # Change the active layer.
    paintHelper.setLayerIndex cluster.layer.index

    # Change the selected object.
    selectionHelper = @interface.getHelperForActiveFile LOI.Assets.MeshEditor.Helpers.Selection
    selectionHelper.setObjectIndex cluster.layer.object.index
