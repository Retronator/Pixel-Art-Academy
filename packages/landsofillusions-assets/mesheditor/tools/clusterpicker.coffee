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

    raycaster = meshCanvas.renderer.cameraManager.getRaycaster meshCanvas.mouse().pixelCoordinate()
    scene = meshCanvas.sceneHelper().scene()

    intersectionsForward = raycaster.intersectObjects scene.children, true

    # Since we don't use double-sided materials, we need to reverse the ray and intersect again.
    raycaster.ray.origin.add raycaster.ray.direction.clone().multiplyScalar 10000
    raycaster.ray.direction.negate()

    intersectionsBackward = raycaster.intersectObjects scene.children, true

    intersections = intersectionsForward.concat intersectionsBackward
    return unless intersections.length

    # Filter intersetctions to clusters.
    clusters = []

    for intersection in intersections when intersection.object.parent instanceof LOI.Assets.Engine.Mesh.Object.Layer.Cluster
      clusters.push intersection.object.parent.clusterData

    # Get only one instance of each cluster (if it was picked multiple times).
    clusters = _.uniq clusters

    currentClusterHelper = @interface.getHelperForActiveFile LOI.Assets.MeshEditor.Helpers.CurrentCluster
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
