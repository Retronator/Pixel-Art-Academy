AE = Artificial.Everywhere
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

if Meteor.isClient
  _transform = new Ammo.btTransform

  _velocity = new THREE.Vector3
  _localVelocity = new THREE.Vector3
  _dragObjectDirectionalWeights = new THREE.Vector3

  _angularVelocity = new THREE.Vector3
  _localAngularVelocity = new THREE.Vector3
  _dragObjectAngularDirectionalWeights = new THREE.Vector3

  _worldMatrix = new THREE.Matrix4
  _worldQuaternion = new THREE.Quaternion
  _worldQuaternionInverse = new THREE.Quaternion
  _worldPosition = new THREE.Vector3

  _dragForce = new THREE.Vector3
  _dragForceBullet = new Ammo.btVector3
  _relativeForcePosition = new THREE.Vector3
  _relativeForcePositionBullet = new Ammo.btVector3

  _dragTorque = new THREE.Vector3
  _dragTorqueBullet = new Ammo.btVector3

class PAA.StillLifeStand.PhysicsManager extends PAA.StillLifeStand.PhysicsManager
  applyDrag: ->
    items = @items()

    for item in items
      physicsObject = item.avatar.getPhysicsObject()
      continue unless physicsObject.dragObjects?.length

      body = physicsObject.body

      _velocity.setFromBulletVector3 body.getLinearVelocity()
      speedSquared = _velocity.lengthSq()

      _angularVelocity.setFromBulletVector3 body.getAngularVelocity()
      angularSpeedSquared = _angularVelocity.lengthSq()

      continue unless speedSquared > @minSpeedSquaredToApplyDrag or angularSpeedSquared > @minSpeedSquaredToApplyDrag

      # Calculate transform to local space.
      physicsObject.motionState.getWorldTransform _transform

      _worldQuaternion.setFromBulletQuaternion _transform.getRotation()
      _worldQuaternionInverse.copy(_worldQuaternion).inverse()

      if speedSquared
        # Calculate velocity in local space.
        _worldMatrix.setFromBulletTransform _transform
        _worldPosition.setFromBulletVector3 _transform.getOrigin()

        _localVelocity.copy(_velocity).applyQuaternion _worldQuaternionInverse
        _dragObjectDirectionalWeights.set Math.abs(_localVelocity.x), Math.abs(_localVelocity.y), Math.abs(_localVelocity.z)
        _dragObjectDirectionalWeights.divideScalar _dragObjectDirectionalWeights.x + _dragObjectDirectionalWeights.y + _dragObjectDirectionalWeights.z

      if angularSpeedSquared
        # Calculate angular velocity in local space.
        _localAngularVelocity.copy(_angularVelocity).applyQuaternion _worldQuaternionInverse
        _dragObjectAngularDirectionalWeights.set Math.abs(_localAngularVelocity.x), Math.abs(_localAngularVelocity.y), Math.abs(_localAngularVelocity.z)
        _dragObjectAngularDirectionalWeights.divideScalar _dragObjectAngularDirectionalWeights.x + _dragObjectAngularDirectionalWeights.y + _dragObjectAngularDirectionalWeights.z

      # We use a drag multiplier to allow lighter objects represented
      # with bigger masses (for stability of the general simulation).
      dragMultiplier = item.avatar.properties.dragMultiplier or 1
      dragMass = physicsObject.mass / dragMultiplier

      for dragObject in physicsObject.dragObjects
        if speedSquared > @minSpeedSquaredToApplyDrag
          # Calculate weighted drag factor (corresponds to C * A below).
          linearDragFactor = dragObject.linearDragFactor.dot _dragObjectDirectionalWeights

          # Apply drag only up to terminal speed.
          terminalSpeedSquared = 2 * dragMass * 9.81 / (linearDragFactor * @surroundingGasDensity)
          speedSquared = Math.min speedSquared, terminalSpeedSquared

          #       1
          # F = - - * C * A * ρ * v²
          #       2
          dragForceMagnitude = 1 / 2 * linearDragFactor * @surroundingGasDensity * speedSquared

          _dragForce.copy(_velocity).normalize().multiplyScalar -dragForceMagnitude * dragMultiplier
          _dragForceBullet.setFromThreeVector3 _dragForce

          # Calculate where to apply the force in world space, relative to center of mass.
          _relativeForcePosition.copy(dragObject.position).applyMatrix4(_worldMatrix).sub(_worldPosition)
          _relativeForcePositionBullet.setFromThreeVector3 _relativeForcePosition

          body.applyForce _dragForceBullet, _relativeForcePositionBullet

        if angularSpeedSquared > @minSpeedSquaredToApplyDrag
          # Calculate weighted drag factor (corresponds to C * A * l³ below).
          angularDragFactor = dragObject.angularDragFactor.dot _dragObjectAngularDirectionalWeights

          # Apply drag only up to terminal speed.
          terminalAngularSpeedSquared = 2 * dragMass * 9.81 / (angularDragFactor * @surroundingGasDensity)
          angularSpeedSquared = Math.min angularSpeedSquared, terminalAngularSpeedSquared

          #       1
          # τ = - - * C * A * l³ * ρ * ω²
          #       4
          dragTorqueMagnitude = 1 / 4 * angularDragFactor * @surroundingGasDensity * angularSpeedSquared

          _dragTorque.copy(_angularVelocity).normalize().multiplyScalar -dragTorqueMagnitude * dragMultiplier
          _dragTorqueBullet.setFromThreeVector3 _dragTorque

          body.applyTorque _dragTorqueBullet
