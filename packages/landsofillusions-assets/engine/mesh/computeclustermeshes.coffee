LOI = LandsOfIllusions

Delaunator = require 'delaunator'

LOI.Assets.Engine.Mesh.computeClusterMeshes = (clusters) ->
  console.log "Computing cluster meshes", clusters if LOI.Assets.Engine.Mesh.debug

  getX = (point) => point.vertexPlane.x
  getY = (point) => point.vertexPlane.y

  for cluster in clusters
    delaunay = Delaunator.from cluster.points, getX, getY
    cluster.indices = delaunay.triangles

  console.log "Computed cluster meshes", clusters if LOI.Assets.Engine.Mesh.debug
