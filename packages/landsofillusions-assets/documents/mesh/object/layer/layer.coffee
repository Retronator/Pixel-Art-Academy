AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Layer
  constructor: (@layers, @index, data) ->
    @object = @layers.parent
    
    @_updatedDependency = new Tracker.Dependency
    
    for field in ['name', 'visible', 'order']
      @[field] = new LOI.Assets.Mesh.ValueField @, field, data[field]

    @visible.setDefaultValue true

    @clusters = new LOI.Assets.Mesh.MapField @, 'clusters', data.clusters, @constructor.Cluster
    @pictures = new LOI.Assets.Mesh.ArrayField @, 'pictures', data.pictures, @constructor.Picture

  getAddress: ->
    _.extend @object.getAddress(),
      layer: @index

  resolveAddress: (address) ->
    return @ unless address.picture?
  
    picture = @pictures.get address.picture
    picture.resolveAddress address
    
  toPlainObject: ->
    plainObject = {}

    @[field].save plainObject for field in ['name', 'visible', 'order', 'pictures', 'clusters']

    plainObject

  depend: ->
    @_updatedDependency.depend()

  contentUpdated: ->
    @_updatedDependency.changed()
    @layers.contentUpdated()

  isVisible: ->
    @object.isVisible() and (@visible() ? true)

  getPictureForCameraAngleIndex: (cameraAngleIndex) ->
    picture = @pictures.get cameraAngleIndex
    return picture if picture
    
    # Picture hasn't been created yet, so insert and retry.
    @pictures.insert {}, cameraAngleIndex
    @pictures.get cameraAngleIndex
    
  getPictureCluster: (clusterId) ->
    for picture in @pictures.getAll()
      if cluster = picture.clusters[clusterId]
        return cluster

  getClusterByName: (clusterName) ->
    for clusterId, cluster of @clusters.getAll()
      return cluster if cluster.properties()?.name is clusterName
      
    null

  newCluster: (clusterId, material) ->
    @clusters.insert clusterId, {material}

    # Register the material with material properties.
    @object.mesh.materialProperties.register material

  duplicateCluster: (clusterId, newClusterId) ->
    sourceCluster = @clusters.get clusterId
    
    # When duplicating, we create an identical cluster, except for geometry.
    @clusters.insert newClusterId,
      properties: _.clone sourceCluster.properties()
      material: _.clone sourceCluster.material()
      
  removeCluster: (clusterId) ->
    @clusters.remove clusterId

  getSpriteBoundsAndPixelsForCameraAngle: (cameraAngleIndex) ->
    picture = @getPictureForCameraAngleIndex cameraAngleIndex
    bounds = picture.bounds()
    pixels = picture.getSpritePixels()

    {bounds, pixels}
