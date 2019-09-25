LOI = LandsOfIllusions

class LOI.Assets.Engine.Mesh extends THREE.Object3D
  constructor: (@options) ->
    super arguments...

    @objects = new ReactiveField null

    @ready = new ComputedField =>
      return unless objects = @objects()

      for object in objects
        return unless object.ready()

      true

    # Add the mesh to the scene.
    Tracker.autorun (computation) =>
      return unless scene = @options.sceneManager.scene()
      computation.stop()

      scene.add @
      @options.sceneManager.addedSceneObjects()

    # Generate objects.
    @_generateObjectsAutorun = Tracker.autorun (computation) =>
      return unless meshData = @options.meshData()
      return unless objectsData = meshData.objects.getAllWithoutUpdates()
      
      engineObjects = for objectData in objectsData
        new @constructor.Object @, objectData

      @objects engineObjects

    # Update mesh children.
    @_updateChildrenAutorun = Tracker.autorun (computation) =>
      # Clean up previous children.
      @remove @children[0] while @children.length

      objects = @objects()
      return unless objects?.length

      # Add new children.
      @add object for object in objects

      @options.sceneManager.addedSceneObjects()

  destroy: ->
    @_generateObjectsAutorun.stop()
    @_updateChildrenAutorun.stop()
