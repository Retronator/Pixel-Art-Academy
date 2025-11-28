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
    
    @directive: -> "Start the Invasion Design Document"
    
    @instructions: -> """
      In the Pixeltosh app, open the Invasion drive and open the Invasion Design Document file.
    """
    
    @interests: -> ['game design']
    
    @requiredInterests: -> ['shape language']
    
    @initialize()
    
    @completedConditions: ->
      # Require an entity to be added to the design.
      return unless activeProjectId = PAA.Pico8.Cartridges.Invasion.Project.state 'activeProjectId'
      return unless project = PAA.Practice.Project.documents.findOne activeProjectId
      project.design.entities?.length
      
  class @Run extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.Run"
    @goal: -> Goal
    
    @directive: -> "Run the Invasion game cartridge"
    
    @instructions: -> """
      In the PICO-8 app, run the first build of Invasion.
      Notice the first art asset in the game and imagine how you want it to look.
    """
    
    @interests: -> ['pico-8', 'gaming']
    
    @predecessors: -> [Goal.Start]
    
    @initialize()
    
    @completedConditions: ->
      # Require the cartridge to have run.
      PAA.Pico8.Cartridges.Invasion.state 'cartridgeRan'
      
    reset: ->
      super arguments...
      
      PAA.Pico8.Cartridges.Invasion.state 'cartridgeRan', false
      
  class @Draw extends PAA.Learning.Task.Automatic
    @assetId: -> throw new AE.NotImplementedException "Draw task has to specify which asset needs to be drawn."
    @goal: -> Goal

    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @completedConditions: ->
      return unless projectId = PAA.Pico8.Cartridges.Invasion.Project.state 'activeProjectId'
      return unless project = PAA.Practice.Project.documents.findOne projectId
      return unless asset = _.find project.assets, (asset) => asset.id is @assetId()
      return unless bitmap = LOI.Assets.Bitmap.documents.findOne asset.bitmapId

      # We know the player has changed the bitmap if the history position is not zero.
      return unless bitmap.historyPosition

      true
  
  class @DrawDefender extends @Draw
    @id: -> "#{Goal.id()}.DrawDefender"
    @assetId: -> PAA.Pico8.Cartridges.Invasion.Defender.id()
    
    @directive: -> "Draw the defender sprite"
    
    @instructions: -> """
      After adding the Defender entity in the Invasion Design Document, go to the Drawing app and complete the sprite for the player unit.
    """

    @predecessors: -> [Goal.Run]
    
    @groupNumber: -> -1
    
    @initialize()
  
  class @DrawProjectile extends @Draw
    @onActive: ->
      super arguments...
      
      # Make sure we get a fresh start on the levels completed. We do this in this step
      # instead of the next since completedConditions can otherwise run before onActive.
      PAA.Pico8.Cartridges.Invasion.state 'highestLevelCompleted', null
      
  class @DrawDefenderProjectile extends @DrawProjectile
    @id: -> "#{Goal.id()}.DrawDefenderProjectile"
    @assetId: -> PAA.Pico8.Cartridges.Invasion.DefenderProjectile.id()
    
    @directive: -> "Draw the defender projectile sprite"
    
    @instructions: -> """
      After adding the Defender projectile entity in the Invasion Design Document,
      go to the Drawing app and complete the sprite for the projectiles you can shoot.
      Optionally, change the explosion as well.
    """
    
    @predecessors: -> [Goal.DrawDefender]
    
    @groupNumber: -> -1
    
    @initialize()
  
  class @DrawInvader extends @Draw
    @id: -> "#{Goal.id()}.DrawInvader"
    @assetId: -> PAA.Pico8.Cartridges.Invasion.Invader.id()
    
    @directive: -> "Draw the invader sprite"
    
    @instructions: -> """
      After adding the Invader entity in the Invasion Design Document,
      go to the Drawing app and complete the sprite for the enemy units.
    """
    
    @predecessors: -> [Goal.Run]
    
    @groupNumber: -> 1
    
    @initialize()
  
  class @DrawInvaderProjectile extends @DrawProjectile
    @id: -> "#{Goal.id()}.DrawInvaderProjectile"
    @assetId: -> PAA.Pico8.Cartridges.Invasion.InvaderProjectile.id()
    
    @directive: -> "Draw the invader projectile sprite"
    
    @instructions: -> """
      After adding the Invader projectile entity in the Invasion Design Document,
      go to the Drawing app and complete the sprite for enemy projectiles.
      Optionally, change the explosion as well.
    """
    
    @predecessors: -> [Goal.DrawInvader]
    
    @groupNumber: -> 1
    
    @initialize()

  class @Play extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.Play"
    @goal: -> Goal
    
    @directive: -> "Stop the invasion"
    
    @instructions: -> """
      With the defender and invaders shooting at each other, run Invasion on PICO-8 and complete one level of the game by destroying all the invaders.
    """
    
    @predecessors: -> [Goal.DrawDefenderProjectile, Goal.DrawInvaderProjectile]
    
    @initialize()
    
    @completedConditions: ->
      # Require the player to complete level 1.
      PAA.Pico8.Cartridges.Invasion.state('highestLevelCompleted') >= 1
  
    reset: ->
      super arguments...
      
      PAA.Pico8.Cartridges.Invasion.state 'highestLevelCompleted', null
      
  @tasks: -> [
    @Start
    @Run
    @DrawDefender
    @DrawDefenderProjectile
    @DrawInvader
    @DrawInvaderProjectile
    @Play
  ]

  @finalTasks: -> [
    @Play
  ]

  @initialize()
