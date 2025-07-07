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
      #@Invader
      #@DefenderProjectile
      #@InvaderProjectile
      #@Barricade
    ]
    @initialize()
    
    constructor: ->
      super arguments...
      
      @progress = new LM.Content.Progress.ContentProgress
        content: @
        units: "sprites"
    
    status: -> if LM.Intro.Tutorial.Goals.Snake.Play.completedConditions() then LM.Content.Status.Unlocked else LM.Content.Status.Locked
    
    class @Defender extends LM.Content.AssetContent
      @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invasion.Defender'
      
      @assetClass = PAA.Pico8.Cartridges.Invasion.Defender
      
      @initialize()
      
      status: -> LM.Content.Status.Unlocked
    
    class @Invader extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invasion.Invader'
      @displayName: -> "Invader"
      @initialize()
      
    class @DefenderProjectile extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invasion.DefenderProjectile'
      @displayName: -> "Defender projectile"
      @initialize()
    
    class @InvaderProjectile extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invasion.InvaderProjectile'
      @displayName: -> "Invader projectile"
      @initialize()
    
    class @Barricade extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invasion.Barricade'
      @displayName: -> "Barricade"
      @initialize()
      
  class @Maze extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Maze'
    @displayName: -> "Maze"
    @initialize()
