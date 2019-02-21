AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Solver
  @Types:
    Plane: 'plane'
    Polyhedron: 'polyhedron'
    Organic: 'organic'
    
  constructor: (@object) ->

  update: (addedClusterIds, updatedClusterIds, removedClusterIds) ->
    throw AE.NotImplementedException "Solver must define the update function."
