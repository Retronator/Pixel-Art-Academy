PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

PixelArtSoftware = PAA.Challenges.Drawing.PixelArtSoftware
InvasionDesignDocument = PAA.Pico8.Cartridges.Invasion.DesignDocument

class LM.Design.Fundamentals.Content.Projects extends LM.Content
  @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects'
  @displayName: -> "Projects"
  @contents: -> [
    @Invasion
    @Maze
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
      
      countCompletedAssets = (assetClasses) =>
        return 0 unless projectId = PAA.Pico8.Cartridges.Invasion.Project.state 'activeProjectId'
        return 0 unless project = PAA.Practice.Project.documents.findOne projectId
        
        completedCount = 0
        
        for assetClass in assetClasses
          assetId = assetClass.id()
          continue unless asset = _.find project.assets, (asset) => asset.id is assetId
          continue unless bitmap = LOI.Assets.Bitmap.documents.findOne asset.bitmapId
          
          # We know the player has changed the bitmap if the history position is not zero.
          completedCount++ if bitmap.historyPosition
        
        completedCount
      
      @progress = new LM.Content.Progress.ManualProgress
        content: @
        units: "sprites"
    
        completed: => @progress.requiredCompletedUnitsCount() is @progress.requiredUnitsCount()

        requiredUnitsCount: 4

        requiredCompletedUnitsCount: =>
          requiredAssetClasses = [
            PAA.Pico8.Cartridges.Invasion.Defender
            PAA.Pico8.Cartridges.Invasion.DefenderProjectile
            PAA.Pico8.Cartridges.Invasion.Invader
            PAA.Pico8.Cartridges.Invasion.InvaderProjectile
          ]
          
          countCompletedAssets requiredAssetClasses
          
        unitsCount: 7

        completedUnitsCount: =>
          allAssetClasses = [
            PAA.Pico8.Cartridges.Invasion.Defender
            PAA.Pico8.Cartridges.Invasion.DefenderProjectile
            PAA.Pico8.Cartridges.Invasion.DefenderProjectileExplosion
            PAA.Pico8.Cartridges.Invasion.Invader
            PAA.Pico8.Cartridges.Invasion.InvaderProjectile
            PAA.Pico8.Cartridges.Invasion.InvaderProjectileExplosion
            PAA.Pico8.Cartridges.Invasion.Shield
          ]
          
          countCompletedAssets allAssetClasses
    
    status: -> if LM.Design.Fundamentals.Goals.Invasion.Run.completed() then LM.Content.Status.Unlocked else LM.Content.Status.Locked
    
    class @AssetContent extends LM.Content.AssetContent
      @unlockingEntity = null # Override which entity unlocks the asset.
      
      status: ->
        return LM.Content.Status.Unavailable unless projectId = PAA.Pico8.Cartridges.Invasion.Project.state 'activeProjectId'
        return LM.Content.Status.Unavailable unless project = PAA.Practice.Project.documents.findOne projectId
        return LM.Content.Status.Unavailable unless entities = project.design.entities
        if @constructor.unlockingEntity in entities then LM.Content.Status.Unlocked else LM.Content.Status.Locked
        
    class @Defender extends @AssetContent
      @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invasion.Defender'
      @projectClass = PAA.Pico8.Cartridges.Invasion.Project
      @assetClass = PAA.Pico8.Cartridges.Invasion.Defender
      @unlockingEntity = InvasionDesignDocument.Options.Entities.Defender
      
      @unlockInstructions: -> "Add the Defender entity in the Invasion Design Document to unlock the defender sprite."
      
      @initialize()

    class @Invader extends @AssetContent
      @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invasion.Invader'
      @projectClass = PAA.Pico8.Cartridges.Invasion.Project
      @assetClass = PAA.Pico8.Cartridges.Invasion.Invader
      @unlockingEntity = InvasionDesignDocument.Options.Entities.Invader
      
      @unlockInstructions: -> "Add the Invader entity in the Invasion Design Document to unlock the invader sprite."
    
      @initialize()
    
    class @DefenderProjectile extends @AssetContent
      @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invasion.DefenderProjectile'
      @projectClass = PAA.Pico8.Cartridges.Invasion.Project
      @assetClass = PAA.Pico8.Cartridges.Invasion.DefenderProjectile
      @unlockingEntity = InvasionDesignDocument.Options.Entities.DefenderProjectile
      
      @unlockInstructions: -> "Add the Defender projectile entity in the Invasion Design Document to unlock the defender projectile sprite."
      
      @initialize()
    
    class @InvaderProjectile extends @AssetContent
      @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invasion.InvaderProjectile'
      @projectClass = PAA.Pico8.Cartridges.Invasion.Project
      @assetClass = PAA.Pico8.Cartridges.Invasion.InvaderProjectile
      @unlockingEntity = InvasionDesignDocument.Options.Entities.InvaderProjectile
      
      @unlockInstructions: -> "Add the Invader projectile entity in the Invasion Design Document to unlock the invader projectile sprite."

      @initialize()
    
    class @DefenderProjectileExplosion extends @AssetContent
      @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invasion.DefenderProjectileExplosion'
      @projectClass = PAA.Pico8.Cartridges.Invasion.Project
      @assetClass = PAA.Pico8.Cartridges.Invasion.DefenderProjectileExplosion
      @unlockingEntity = InvasionDesignDocument.Options.Entities.DefenderProjectile
      
      @unlockInstructions: -> "Add the Defender projectile entity in the Invasion Design Document to unlock the defender projectile explosion sprite."

      @initialize()
    
    class @InvaderProjectileExplosion extends @AssetContent
      @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invasion.InvaderProjectileExplosion'
      @projectClass = PAA.Pico8.Cartridges.Invasion.Project
      @assetClass = PAA.Pico8.Cartridges.Invasion.InvaderProjectileExplosion
      @unlockingEntity = InvasionDesignDocument.Options.Entities.InvaderProjectile
      
      @unlockInstructions: -> "Add the Invader projectile entity in the Invasion Design Document to unlock the invader projectile explosion sprite."
      
      @initialize()
    
    class @Shield extends @AssetContent
      @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invasion.Shield'
      @projectClass = PAA.Pico8.Cartridges.Invasion.Project
      @assetClass = PAA.Pico8.Cartridges.Invasion.Shield
      @unlockingEntity = InvasionDesignDocument.Options.Entities.Shield
      
      @unlockInstructions: -> "Add the Shield entity in the Invasion Design Document to unlock the shield sprite."
      
      @initialize()
  
  class @Maze extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Maze'
    @displayName: -> "Maze"
    @initialize()
