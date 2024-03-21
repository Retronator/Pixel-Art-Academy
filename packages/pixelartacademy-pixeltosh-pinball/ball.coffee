LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Ball
  @States =
    Live: 'Live'
    Dead: 'Dead'
    
  constructor: (@pinball, @ballSpawner) ->
    spawnerRenderObject = @ballSpawner.avatar.getRenderObject()
    spawnerPhysicsObject = @ballSpawner.avatar.getPhysicsObject()
    
    @physicsObject = new Pinball.Part.Avatar.PhysicsObject @, spawnerPhysicsObject.properties, spawnerPhysicsObject.shape, spawnerPhysicsObject
    @physicsObject.reset()

    @renderObject = new Pinball.Part.Avatar.RenderObject @, spawnerRenderObject.properties, spawnerRenderObject.shape, spawnerRenderObject.bitmap, spawnerRenderObject
    @renderObject.updateFromPhysicsObject @physicsObject
    
    @state = new ReactiveField @constructor.States.Live
  
  getRenderObject: -> @renderObject
  getPhysicsObject: -> @physicsObject
  
  destroy: ->
    @renderObject.destroy()
    @physicsObject.destroy()
    
  die: ->
    @state @constructor.States.Dead
