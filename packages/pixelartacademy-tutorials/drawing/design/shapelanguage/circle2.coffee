AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Design.ShapeLanguage.Circle2 extends PAA.Tutorials.Drawing.Design.ShapeLanguage.AssetWithReferences
  @displayName: -> "Circle 2"

  @description: -> """
    The circle shape language is often used to design protagonists and other friendly or cute characters.
  """

  @fixedDimensions: -> width: 29, height: 32
  @backgroundColor: -> new THREE.Color '#a6e2fe'
  
  @referenceNames: -> [
    'dragonwarrior'
    'kirbysdreamland2'
    'supermariobros2'
  ]
  
  @initialize()

  Asset = @

  class @DragonWarrior extends PAA.Tutorials.Drawing.Instructions.Multiarea.StepInstruction
    @assetClass: -> Asset
    @referenceUrl: -> Asset.createReferenceUrl 'dragonwarrior'

  class @DragonWarrior1 extends @DragonWarrior
    @id: -> "#{Asset.id()}.DragonWarrior1"
    @stepNumber: -> 1
    
    @message: -> """
      One of the most iconic characters in Dragon Quest (a.k.a. Dragon Warrior) is the Slime enemy,
      known for its cute appearance based on the circle shape language.
    """
    
    @initialize()
  
  class @DragonWarrior2 extends @DragonWarrior
    @id: -> "#{Asset.id()}.DragonWarrior2"
    @stepNumber: -> 2
    
    @message: -> """
      Dragon Quest creator Yuji Horii initially sketched it as a menacing, irregular pile of goo,
      but the artist Akira Toriyama (of Dragon Ball fame) transformed it into the iconic teardrop shape we know today.
    """
    
    @initialize()
  
  class @DragonWarrior3 extends @DragonWarrior
    @id: -> "#{Asset.id()}.DragonWarrior3"
    @stepNumber: -> 3
    
    @message: -> """
      The circular appearance and its smile successfully communicate that it is the weakest, practically harmless enemy.
    """
    
    @initialize()
  
  class @Kirby extends PAA.Tutorials.Drawing.Instructions.Multiarea.StepInstruction
    @assetClass: -> Asset
    @referenceUrl: -> Asset.createReferenceUrl 'kirbysdreamland2'
  
  class @Kirby1 extends @Kirby
    @id: -> "#{Asset.id()}.Kirby1"
    @stepNumber: -> 1
    
    @message: -> """
      Kirby's circular design started as a simple placeholder during development,
      but turned out to fit the game better than the previously planned design.
    """
    
    @initialize()
  
  class @Kirby2 extends @Kirby
    @id: -> "#{Asset.id()}.Kirby2"
    @stepNumber: -> 2
    
    @message: -> """
      The designer Masahiro Sakurai wanted to create "a cute main character who everyone will love".
    """
    
    @initialize()
  
  class @Kirby3 extends @Kirby
    @id: -> "#{Asset.id()}.Kirby3"
    @stepNumber: -> 3
    
    @message: -> """
      Satoru Iwata, then programmer on the game and later Nintendo president,
      added that they "gave Kirby a simple, circular design so anyone could draw him."
    """
    
    @initialize()

  class @Mario extends PAA.Tutorials.Drawing.Instructions.Multiarea.StepInstruction
    @assetClass: -> Asset
    @referenceUrl: -> Asset.createReferenceUrl 'supermariobros2'
  
  class @Mario1 extends @Mario
    @id: -> "#{Asset.id()}.Mario1"
    @stepNumber: -> 1
    
    @message: -> """
      Mario's friendly, cartoony design—achieved with the circle shape language—aligns closely with Nintendo's positioning of gaming as a family activity.
    """
    
    @initialize()

  class @Mario2 extends @Mario
    @id: -> "#{Asset.id()}.Mario2"
    @stepNumber: -> 2
    
    @message: -> """
      The character's designer, Shigeru Miyamoto, described,
      "I think one of the appeals of Mario is that he's such an easy character to understand.
      He's a good guy. He's the guy you want to be."
    """
    
    @initialize()

  class @Mario3 extends @Mario
    @id: -> "#{Asset.id()}.Mario3"
    @stepNumber: -> 3
    
    @message: -> """
      Observe how everything is drawn with curves, from big shapes like the head and the body down to small ones like hands, feet, and the nose.
    """
    
    @initialize()
