PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

PixelArtSoftware = PAA.Challenges.Drawing.PixelArtSoftware

class LM.Design.Fundamentals.Content.Projects extends LM.Content
  @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects'
  @displayName: -> "Projects"
  @contents: -> [
    @Maze
    @Invasion
  ]
  @initialize()

  status: -> LM.Content.Status.Unlocked
  
  constructor: ->
    super arguments...
    
    @progress = new LM.Content.Progress.ContentProgress
      content: @
      weight: 2
      totalUnits: "artworks"
      totalRecursive: true
      
  class @Invasion extends LM.Content
    @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invasion'
    @displayName: -> "Invasion"
    @contents: -> [
      @Defender
      @Invader
      @DefenderProjectile
      @InvaderProjectile
      @DefenderProjectileExplosion
      @InvaderProjectileExplosion
      @Shield
    ]
    @initialize()
    
    @unlockInstructions: -> "Run the Invasion PICO-8 cartridge to unlock the Invasion project."
    
    constructor: ->
      super arguments...
      
      @progress = new LM.Content.Progress.ManualProgress
        content: @
        units: "sprites"
    
        completed: => LM.Design.Fundamentals.Goals.Invasion.getAdventureInstance().completed()

        requiredUnitsCount: 5

        requiredCompletedUnitsCount: =>
          drawingTaskClasses = [
            LM.Design.Fundamentals.Goals.Invasion.DrawDefender
            LM.Design.Fundamentals.Goals.Invasion.DrawDefenderProjectile
            LM.Design.Fundamentals.Goals.Invasion.DrawInvader
            LM.Design.Fundamentals.Goals.Invasion.DrawInvaderProjectile
          ]
          
          completedCount = 0

          for drawingTaskClass in drawingTaskClasses
            completedCount++ if drawingTaskClass.completed()
            
          completedCount
          
        unitsCount: 7

        completedUnitsCount: =>
          drawingTaskClasses = [
            LM.Design.Fundamentals.Goals.Invasion.DrawDefender
            LM.Design.Fundamentals.Goals.Invasion.DrawDefenderProjectile
            LM.Design.Fundamentals.Goals.Invasion.DrawDefenderProjectileExplosion
            LM.Design.Fundamentals.Goals.Invasion.DrawInvader
            LM.Design.Fundamentals.Goals.Invasion.DrawInvaderProjectile
            LM.Design.Fundamentals.Goals.Invasion.DrawInvaderProjectileExplosion
            LM.Design.Fundamentals.Goals.Invasion.DrawShield
          ]
          
          completedCount = 0

          for drawingTaskClass in drawingTaskClasses
            completedCount++ if drawingTaskClass.completed()
            
          completedCount
    
    status: -> if LM.Design.Fundamentals.Goals.Invasion.Run.completed() then LM.Content.Status.Unlocked else LM.Content.Status.Locked
    
    class @Defender extends LM.Content.AssetContent
      @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invasion.Defender'
      @projectClass = PAA.Pico8.Cartridges.Invasion.Project
      @assetClass = PAA.Pico8.Cartridges.Invasion.Defender
      
      @unlockInstructions: -> "Add the Defender game element in the Invasion design document to unlock the defender sprite."
      
      @initialize()
      
    class @Invader extends LM.Content.AssetContent
      @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invasion.Invader'
      @projectClass = PAA.Pico8.Cartridges.Invasion.Project
      @assetClass = PAA.Pico8.Cartridges.Invasion.Invader
      
      @unlockInstructions: -> "Add the Invader game element in the Invasion design document to unlock the defender sprite."
    
      @initialize()
      
    class @DefenderProjectile extends LM.Content.AssetContent
      @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invasion.DefenderProjectile'
      @projectClass = PAA.Pico8.Cartridges.Invasion.Project
      @assetClass = PAA.Pico8.Cartridges.Invasion.DefenderProjectile
      
      @unlockInstructions: -> "Add the Defender projectile game element in the Invasion design document to unlock the defender sprite."
      
      @initialize()
    
    class @InvaderProjectile extends LM.Content.AssetContent
      @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invasion.InvaderProjectile'
      @projectClass = PAA.Pico8.Cartridges.Invasion.Project
      @assetClass = PAA.Pico8.Cartridges.Invasion.InvaderProjectile
      
      @unlockInstructions: -> "Add the Invader projectile game element in the Invasion design document to unlock the defender sprite."

      @initialize()
    
    class @DefenderProjectileExplosion extends LM.Content.AssetContent
      @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invasion.DefenderProjectileExplosion'
      @projectClass = PAA.Pico8.Cartridges.Invasion.Project
      @assetClass = PAA.Pico8.Cartridges.Invasion.DefenderProjectileExplosion
      
      @unlockInstructions: -> "Finish drawing the defender projectile sprite to unlock the defender projectile explosion sprite."

      @initialize()
    
    class @InvaderProjectileExplosion extends LM.Content.AssetContent
      @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invasion.InvaderProjectileExplosion'
      @projectClass = PAA.Pico8.Cartridges.Invasion.Project
      @assetClass = PAA.Pico8.Cartridges.Invasion.InvaderProjectileExplosion
      
      @unlockInstructions: -> "Finish drawing the invader projectile sprite to unlock the defender projectile explosion sprite."
      
      @initialize()
    
    class @Shield extends LM.Content.AssetContent
      @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invasion.Shield'
      @projectClass = PAA.Pico8.Cartridges.Invasion.Project
      @assetClass = PAA.Pico8.Cartridges.Invasion.Shield
      
      @unlockInstructions: -> "Add the Shield game element in the Invasion design document to unlock the shield sprite."
      
      @initialize()
      
  class @Maze extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Maze'
    @displayName: -> "Maze"
    @initialize()
