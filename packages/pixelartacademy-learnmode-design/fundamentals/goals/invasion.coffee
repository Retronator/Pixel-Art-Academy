LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Design.Fundamentals.Goals.Invasion extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Goals.Invasion'

  @displayName: -> "Invasion game"
  
  @chapter: -> LM.Design.Fundamentals

  Goal = @

  class @Start extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.Start"
    @goal: -> Goal
    
    @directive: -> "Start the Invasion design document"
    
    @instructions: -> """
      In the Pixeltosh app, open the Invasion drive and open the Invasion Design Document file.
    """
    
    @interests: -> ['game design']
    
    @requiredInterests: -> ['shape language']
    
    @initialize()
    
    @completedConditions: ->
      # Require the design to not be empty.
      activeProjectId = PAA.Pico8.Cartridges.Invasion.Project.state 'activeProjectId'
      project = PAA.Practice.Project.documents.findOne activeProjectId
      not EJSON.equals project.design, {}
      
  class @Run extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.Run"
    @goal: -> Goal
    
    @directive: -> "Run the Invasion game cartridge"
    
    @instructions: -> """
      In the PICO-8 app, run the first build of Invasion.
      Notice the first art asset in the game and imagine how you want it to look.
    """
    
    @interests: -> ['pico-8']
    
    @predecessors: -> [Goal.Start]
    
    @initialize()
    
    @completedConditions: ->
      # Require the cartridge to have run.
      PAA.Pico8.Cartridges.Invasion.state('cartridgeRan')
      
  class @Draw extends PAA.Learning.Task.Automatic
    @assetId: -> throw new AE.NotImplementedException "Draw task has to specify which asset needs to be drawn."
    @goal: -> Goal

    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @completedConditions: ->
      return unless projectId = PAA.Pico8.Cartridges.Invasion.Project.state 'activeProjectId'
      return unless project = PAA.Practice.Project.documents.findOne projectId
      return unless asset = _.find project.assets, (asset) -> asset.id is @assetId()
      return unless bitmap = LOI.Assets.Bitmap.documents.findOne asset.bitmapId

      # We know the player has changed the bitmap if the history position is not zero.
      return unless bitmap.historyPosition

      true
  
  class @DrawDefender extends @Draw
    @id: -> "#{Goal.id()}.DrawDefender"
    @assetId: -> PAA.Pico8.Cartridges.Invasion.Defender.id()
    
    @directive: -> "Draw the defender sprite"
    
    @instructions: -> """
      After adding the defender game element in the Invasion design document, go to the Drawing app and complete the sprite for the player unit.
    """

    @predecessors: -> [Goal.Play]
    
    @groupNumber: -> -1
    
    @initialize()
  
  class @DrawDefenderProjectile extends @Draw
    @id: -> "#{Goal.id()}.DrawDefenderProjectile"
    @assetId: -> PAA.Pico8.Cartridges.Invasion.DefenderProjectile.id()
    
    @directive: -> "Draw the defender projectile sprite"
    
    @instructions: -> """
      After adding the defender projectile game element in the Invasion design document, go to the Drawing app and complete the sprite for the projectiles you can shoot.
    """
    
    @predecessors: -> [Goal.DrawDefender]
    
    @groupNumber: -> -1
    
    @initialize()
  
  class @DrawDefenderProjectileExplosion extends @Draw
    @id: -> "#{Goal.id()}.DrawDefenderProjectileExplosion"
    @assetId: -> PAA.Pico8.Cartridges.Invasion.DefenderProjectileExplosion.id()
    
    @directive: -> "Draw the defender projectile explosion sprite"
    
    @instructions: -> """
      In the Drawing app, optionally change the sprite for the explosion that your projectiles make when hitting an invader or a shield.
    """
    
    @predecessors: -> [Goal.DrawDefenderProjectile]
    
    @groupNumber: -> -1
    
    @initialize()
  
  class @DrawInvader extends @Draw
    @id: -> "#{Goal.id()}.DrawInvader"
    @assetId: -> PAA.Pico8.Cartridges.Invasion.Invader.id()
    
    @directive: -> "Draw the invader sprite"
    
    @instructions: -> """
      After adding the invader game element in the Invasion design document, go to the Drawing app and complete the sprite for the enemy units.
    """
    
    @predecessors: -> [Goal.Play]
    
    @groupNumber: -> 1
    
    @initialize()
  
  class @DrawInvaderProjectile extends @Draw
    @id: -> "#{Goal.id()}.DrawInvaderProjectile"
    @assetId: -> PAA.Pico8.Cartridges.Invasion.InvaderProjectile.id()
    
    @directive: -> "Draw the invader projectile sprite"
    
    @instructions: -> """
      After adding the invader projectile game element in the Invasion design document, go to the Drawing app and complete the sprite for enemy projectiles.
    """
    
    @predecessors: -> [Goal.DrawInvader]
    
    @groupNumber: -> 1
    
    @initialize()
  
  class @DrawShield extends @Draw
    @id: -> "#{Goal.id()}.DrawShield"
    @assetId: -> PAA.Pico8.Cartridges.Invasion.Shield.id()
    
    @directive: -> "Draw the shield sprite"
    
    @instructions: -> """
      After optionally adding the shield game element in the Invasion design document, go to the Drawing app and complete the sprite for an obstacle to the projectiles.
    """
    
    @predecessors: -> [Goal.Play]
    
    @initialize()
    
  class @DrawInvaderProjectileExplosion extends @Draw
    @id: -> "#{Goal.id()}.DrawInvaderProjectileExplosion"
    @assetId: -> PAA.Pico8.Cartridges.Invasion.InvaderProjectileExplosion.id()
    
    @directive: -> "Draw the invader projectile explosion sprite"
    
    @instructions: -> """
      In the Drawing app, optionally change the sprite for the explosion that the enemy projectiles make when hitting your defender or a shield.
    """
    
    @predecessors: -> [Goal.DrawInvaderProjectile]
    
    @groupNumber: -> 1
    
    @initialize()
  
  class @Play extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.Play"
    @goal: -> Goal
    
    @directive: -> "Stop the invasion"
    
    @instructions: -> """
      With the defender and invaders in place, run Invasion on PICO-8 and complete one level of the game by destroying all the invaders.
    """
    
    @predecessors: -> [Goal.DrawDefenderProjectile, Goal.DrawInvaderProjectile]
    
    @initialize()
    
    @completedConditions: ->
      # Require the player to complete level 1.
      PAA.Pico8.Cartridges.Invasion.state('highestLevelCompleted') >= 1
  
  @tasks: -> [
    @Start
    @Run
    @DrawDefender
    @DrawDefenderProjectile
    @DrawDefenderProjectileExplosion
    @DrawInvader
    @DrawInvaderProjectile
    @DrawInvaderProjectileExplosion
    @DrawShield
    @Play
  ]

  @finalTasks: -> [
    @Play
  ]

  @initialize()
