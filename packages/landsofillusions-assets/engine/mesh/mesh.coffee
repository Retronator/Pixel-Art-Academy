LOI = LandsOfIllusions

class LOI.Assets.Engine.Mesh extends THREE.Object3D
  @debug = true
  
  constructor: (@options) ->
    super arguments...

    @objects = new ReactiveField null

    # Add the mesh to the scene once it's ready.
    Tracker.autorun (computation) =>
      return unless scene = @options.sceneManager()?.scene()
      computation.stop()

      scene.add @

    # Generate objects.
    Tracker.autorun (computation) =>
      return unless meshData = @options.meshData()
      return unless objectsData = meshData.objects.getAllWithoutUpdates()
      
      meshObjects = for objectData in objectsData
        new @constructor.Object @, objectData

      @objects meshObjects

    # Update mesh children.
    Tracker.autorun (computation) =>
      # Clean up previous children.
      @remove @children[0] while @children.length

      objects = @objects()
      return unless objects?.length

      # Add new children.
      @add object for object in objects

      @options.sceneManager()?.scene.updated()
