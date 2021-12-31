AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Solver
  @Types:
    Plane: 'plane'
    Polyhedron: 'polyhedron'
    Organic: 'organic'

  @LightmapAreaTypes:
    Cluster: 'Cluster'
    Layer: 'Layer'
    
  constructor: (@object) ->

  @lightmapAreaType: ->
    throw AE.NotImplementedException "Solver must define what area is used in the light map."

  update: (addedClusterIds, updatedClusterIds, removedClusterIds) ->
    throw AE.NotImplementedException "Solver must define the update function."

  recompute: ->
    # Force recomputation by signaling all clusters have been updated.
    @update [], _.keys(@clusters), []
