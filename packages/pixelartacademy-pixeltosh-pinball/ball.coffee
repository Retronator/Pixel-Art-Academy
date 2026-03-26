LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Ball
  @States =
    Live: 'Live'
    Captive: 'Captive'
    Dead: 'Dead'
    
  constructor: (@pinball, @ballSpawner) ->
    spawnerRenderObject = @ballSpawner.avatar.getRenderObject()
    spawnerPhysicsObject = @ballSpawner.avatar.getPhysicsObject()
    
    @physicsObject = new Pinball.Part.Avatar.PhysicsObject @, spawnerPhysicsObject
    @physicsObject.reset()

    @renderObject = new Pinball.Part.Avatar.RenderObject @, spawnerRenderObject
    @renderObject.updateFromPhysicsObject @physicsObject
    
    @state = new ReactiveField @constructor.States.Live
    
    Tracker.autorun (computation) =>
      return unless @physicsObject.ready()
      computation.stop()
      
      @physicsObject.body.setActivationState Ammo.btCollisionObject.ActivationStates.DisableDeactivation
  
  destroy: ->
    @renderObject.destroy()
    @physicsObject.destroy()
  
  getRenderObject: -> @renderObject
  getPhysicsObject: -> @physicsObject
  
  bitmap: -> @ballSpawner.bitmap()
  texture: -> @ballSpawner.texture()
  shape: -> @ballSpawner.shape()
  position: -> @ballSpawner.position()
  rotationQuaternion: -> @ballSpawner.rotationQuaternion()
  physicsProperties: -> @ballSpawner.physicsProperties()
  shapeProperties: -> @ballSpawner.shapeProperties()
  
  constants: -> _.extend {}, @ballSpawner.constants(),
    mass: 0.086 # kg
    
  die: ->
    @state @constructor.States.Dead
