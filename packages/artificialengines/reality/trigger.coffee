AR = Artificial.Reality

class AR.Trigger
  constructor: (@options) ->
    @collidingRigidBodies = []
    @_newCollidingRigidBodies = []
    
    @_contactCallback = new Ammo.ConcreteContactResultCallback
    
    @_contactCallback.addSingleResult = (manifoldPointPointer, collisionObjectWrapperPointer1, partId1, index1, collisionObjectWrapperPointer2, partId2, index2) =>
      manifoldPoint = Ammo.wrapPointer manifoldPointPointer, Ammo.btManifoldPoint
      distance = manifoldPoint.getDistance()
      return if distance > 0
      
      collisionObjectWrapper1 = Ammo.wrapPointer collisionObjectWrapperPointer1, Ammo.btCollisionObjectWrapper
      rigidBody1 = Ammo.castObject collisionObjectWrapper1.getCollisionObject(), Ammo.btRigidBody
      
      collisionObjectWrapper2 = Ammo.wrapPointer collisionObjectWrapperPointer2, Ammo.btCollisionObjectWrapper
      rigidBody2 = Ammo.castObject collisionObjectWrapper2.getCollisionObject(), Ammo.btRigidBody

      otherRigidBody = if rigidBody1 is @_collisionObject then rigidBody2 else rigidBody1
      
      unless otherRigidBody in @collidingRigidBodies
        @collidingRigidBodies.push otherRigidBody
        @options.onEnter? otherRigidBody
        
      @_newCollidingRigidBodies.push otherRigidBody
      @options.onColliding? otherRigidBody

  test: (collisionObject, collisionWorld) ->
    @_newCollidingRigidBodies = []
    @_collisionObject = collisionObject
    
    collisionWorld.contactTest collisionObject, @_contactCallback
    
    for rigidBody in @collidingRigidBodies when rigidBody not in @_newCollidingRigidBodies
      @options.onExit? rigidBody
    
    @collidingRigidBodies = @_newCollidingRigidBodies
