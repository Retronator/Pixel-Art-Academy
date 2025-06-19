PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

PixelArtSoftware = PAA.Challenges.Drawing.PixelArtSoftware

class LM.Design.Fundamentals.Content.Projects extends LM.Content.FutureContent
  @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects'
  @displayName: -> "Projects"
  @contents: -> [
    @Maze
    @Invaders
  ]
  @initialize()

  class @Invaders extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invaders'
    @displayName: -> "Invaders"
    @contents: -> [
      @Invader
      @Defender
      @InvaderProjectile
      @DefenderProjectile
      @Barricade
      @ScreenColorOverlay
    ]
    @initialize()
    
    class @Invader extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invaders.Invader'
      @displayName: -> "Invader"
      @initialize()
      
    class @Defender extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invaders.Defender'
      @displayName: -> "Defender"
      @initialize()
    
    class @InvaderProjectile extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invaders.InvaderProjectile'
      @displayName: -> "Invader projectile"
      @initialize()
    
    class @DefenderProjectile extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invaders.DefenderProjectile'
      @displayName: -> "Defender projectile"
      @initialize()
    
    class @Barricade extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invaders.Barricade'
      @displayName: -> "Barricade"
      @initialize()
    
    class @ScreenColorOverlay extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Invaders.ScreenColorOverlay'
      @displayName: -> "Screen color overlay"
      @initialize()
      
  class @Maze extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Projects.Maze'
    @displayName: -> "Maze"
    @initialize()
