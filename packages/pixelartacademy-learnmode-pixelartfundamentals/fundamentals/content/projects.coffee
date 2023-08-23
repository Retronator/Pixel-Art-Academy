PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

PixelArtSoftware = PAA.Challenges.Drawing.PixelArtSoftware

class LM.PixelArtFundamentals.Fundamentals.Content.Projects extends LM.Content.FutureContent
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects'
  @displayName: -> "Projects"
  @contents: -> [
    @Invaders
    @PixelSuiteIcons
    @PinballCreator
    @BlockBreaker
    @Chess
  ]
  @initialize()

  class @Invaders extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Invaders'
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
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Invaders.Invader'
      @displayName: -> "Invader"
      @initialize()
      
    class @Defender extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Invaders.Defender'
      @displayName: -> "Defender"
      @initialize()
    
    class @InvaderProjectile extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Invaders.InvaderProjectile'
      @displayName: -> "Invader projectile"
      @initialize()
    
    class @DefenderProjectile extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Invaders.DefenderProjectile'
      @displayName: -> "Defender projectile"
      @initialize()
    
    class @Barricade extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Invaders.Barricade'
      @displayName: -> "Barricade"
      @initialize()
    
    class @ScreenColorOverlay extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Invaders.ScreenColorOverlay'
      @displayName: -> "Screen color overlay"
      @initialize()
      
  class @PixelSuiteIcons extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.PixelSuiteIcons'
    @displayName: -> "PixelSuite icons"
    @initialize()
    
    @contents: -> [
      @Calculator
      @ContactCards
      @Calendar
    ]
    @initialize()
    
    class @Calculator extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.PixelSuiteIcons.Calculator'
      @displayName: -> "Calculator"
      @initialize()
    
    class @ContactCards extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.PixelSuiteIcons.ContactCards'
      @displayName: -> "Contact cards"
      @initialize()
    
    class @Calendar extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.PixelSuiteIcons.Calendar'
      @displayName: -> "Calendar"
      @initialize()
  
  class @PinballCreator extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.PinballCreator'
    @displayName: -> "Pinball creator"
    @initialize()
  
  class @BlockBreaker extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.BlockBreaker'
    @displayName: -> "Block breaker"
    @initialize()
  
  class @Chess extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Chess'
    @displayName: -> "Chess"
    @initialize()
