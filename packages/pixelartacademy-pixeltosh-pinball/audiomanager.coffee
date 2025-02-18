AE = Artificial.Everywhere
AEc = Artificial.Echo
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.AudioManager
  @maxVolume = 0.3
  
  constructor: (@pinball) ->
    @partCollisionSounds = {}
    @partCollisionHits = {}
    @partCollisionTimeouts = {}
    @partCollisionVolumes = {}
    
    @_loadSoundsAutorun = Tracker.autorun (computation) =>
      return unless context = LOI.adventure.audioManager.context()
      audioOutputNode = AEc.Node.Mixer.getOutputNodeForName 'location', context
    
      @startSound = new AEc.Sound '/pixelartacademy/pixeltosh/programs/pinball/start.wav', LOI.adventure.audioManager, audioOutputNode

      @partCollisionSounds[Pinball.Parts.Walls.id()] = new AEc.Sound '/pixelartacademy/pixeltosh/programs/pinball/parts/wall.wav', LOI.adventure.audioManager, audioOutputNode
      @partCollisionSounds[Pinball.Parts.SpinningTarget.id()] = new AEc.Sound '/pixelartacademy/pixeltosh/programs/pinball/parts/spinningtarget.wav', LOI.adventure.audioManager, audioOutputNode
      @partCollisionSounds[Pinball.Parts.Gate.id()] = new AEc.Sound '/pixelartacademy/pixeltosh/programs/pinball/parts/gate.wav', LOI.adventure.audioManager, audioOutputNode
      @partCollisionSounds[Pinball.Parts.Plunger.id()] = new AEc.Sound '/pixelartacademy/pixeltosh/programs/pinball/parts/plunger.wav', LOI.adventure.audioManager, audioOutputNode
      @partCollisionSounds[Pinball.Parts.Flipper.id()] = new AEc.Sound '/pixelartacademy/pixeltosh/programs/pinball/parts/flipper.wav', LOI.adventure.audioManager, audioOutputNode
      
      @partCollisionVolumes[Pinball.Parts.Walls.id()] = 0.5
      
      @ballTroughSound = new AEc.Sound '/pixelartacademy/pixeltosh/programs/pinball/parts/balltrough.wav', LOI.adventure.audioManager, audioOutputNode
      @gobbleHoleSound = new AEc.Sound '/pixelartacademy/pixeltosh/programs/pinball/parts/gobblehole.wav', LOI.adventure.audioManager, audioOutputNode
      @flipperActivateSound = new AEc.Sound '/pixelartacademy/pixeltosh/programs/pinball/parts/flipper-activate.wav', LOI.adventure.audioManager, audioOutputNode
      @flipperDeactivateSound = new AEc.Sound '/pixelartacademy/pixeltosh/programs/pinball/parts/flipper-deactivate.wav', LOI.adventure.audioManager, audioOutputNode
      @plungerActivateSound = new AEc.Sound '/pixelartacademy/pixeltosh/programs/pinball/parts/plunger-activate.wav', LOI.adventure.audioManager, audioOutputNode
      @bumperPassiveSound = new AEc.Sound '/pixelartacademy/pixeltosh/programs/pinball/parts/bumper-passive.wav', LOI.adventure.audioManager, audioOutputNode
      @bumperActiveSound = new AEc.Sound '/pixelartacademy/pixeltosh/programs/pinball/parts/bumper-active.wav', LOI.adventure.audioManager, audioOutputNode
      
      computation.stop()
      @initialized = true

  destroy: ->
    @_loadSoundsAutorun.stop()
    
    @startSound.destroy()
    sound.destroy() for partId, sound of @partCollisionSounds
    @ballTroughSound.destroy()
    @gobbleHoleSound.destroy()
    @flipperActivateSound.destroy()
    @flipperDeactivateSound.destroy()
    @plungerActivateSound.destroy()
    @bumperPassiveSound.destroy()
    @bumperActiveSound.destroy()
    
  start: ->
    @startSound?.play
      volume: @constructor.maxVolume * 0.75
    
  flipperActivate: ->
    @flipperActivateSound?.play
      volume: @constructor.maxVolume * 0.75
      
  flipperDeactivate: ->
    @flipperDeactivateSound?.play
      volume: @constructor.maxVolume * 0.5
  
  plungerStart: ->
    @_plungerSoundInstance = @plungerActivateSound?.play
      volume: @constructor.maxVolume
    
  plungerEnd: ->
    @_plungerSoundInstance?.stop()
    @_plungerSoundInstance = null
    
  spinningTargetRotation: ->
    @partCollisionSounds[Pinball.Parts.SpinningTarget.id()].play
      volume: @constructor.maxVolume
  
  gobbleHole: ->
    @gobbleHoleSound?.play
      volume: @constructor.maxVolume
    
  ballTrough: ->
    @ballTroughSound?.play
      volume: @constructor.maxVolume
      
  bumper: (active) ->
    sound = if active then @bumperActiveSound else @bumperPassiveSound
    
    sound?.play
      volume: @constructor.maxVolume * 0.75
  
  fixedUpdate: (elapsed) ->
    return unless @initialized
    
    physicsManager = @pinball.physicsManager()
    
    for partId of @partCollisionHits
      @partCollisionHits[partId] = false
      @partCollisionTimeouts[partId] ?= 0
      @partCollisionTimeouts[partId] -= 1 if @partCollisionTimeouts[partId]
    
    dispatcher = physicsManager.dynamicsWorld.getDispatcher()
    manifoldsCount = dispatcher.getNumManifolds()
    
    for manifoldIndex in [0...manifoldsCount]
      contactManifold = dispatcher.getManifoldByIndexInternal manifoldIndex
      continue unless contactsCount = contactManifold.getNumContacts()
      
      entity1 = physicsManager.getEntityForRigidBody contactManifold.getBody0()
      entity2 = physicsManager.getEntityForRigidBody contactManifold.getBody1()
      
      if entity1 instanceof Pinball.Ball
        ball = entity1
        target = entity2
        
      else if entity2 instanceof Pinball.Ball
        ball = entity2
        target = entity1
        
      else
        continue
        
      targetId = target?.id?()
      targetId = Pinball.Parts.Walls.id() unless @partCollisionSounds[targetId]
      continue if @partCollisionTimeouts[targetId]
      
      for contactIndex in [0...contactsCount]
        contactPoint = contactManifold.getContactPoint(contactIndex)
        impulse = contactPoint.getAppliedImpulse()
        force = impulse / elapsed
        
        switch targetId
          when Pinball.Parts.SpinningTarget.id(), Pinball.Parts.Gate.id()
            @partCollisionHits[targetId] = true
            @partCollisionTimeouts[targetId] = 100
          
          when Pinball.Parts.Walls.id(), Pinball.Parts.Plunger.id(), Pinball.Parts.Flipper.id()
            if force > 10
              @partCollisionHits[targetId] = true
              @partCollisionTimeouts[targetId] = 100
    
    for partId, hit of @partCollisionHits when hit
      @partCollisionSounds[partId].play
        volume: @constructor.maxVolume * (@partCollisionVolumes[partId] or 1)
