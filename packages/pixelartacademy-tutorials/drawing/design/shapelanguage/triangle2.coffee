AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Design.ShapeLanguage.Triangle2 extends PAA.Tutorials.Drawing.Design.ShapeLanguage.AssetWithReferences
  @displayName: -> "Triangle 2"

  @description: -> """
    The triangle shape language is popular with villains and active or powerful characters.
  """

  @fixedDimensions: -> width: 60, height: 62
  @backgroundColor: -> new THREE.Color '#febe96'
  
  @referenceNames: -> [
    'dragonwarrior'
    'pokemonredversion'
    'dayofthetentacle'
  ]
  
  @initialize()

  Asset = @

  class @DragonWarrior extends PAA.Tutorials.Drawing.Instructions.Multiarea.UncompletedInstruction
    @id: -> "#{Asset.id()}.DragonWarrior"
    @assetClass: -> Asset
    @referenceUrl: -> Asset.createReferenceUrl 'dragonwarrior'
    
    @message: -> """
      Dragons in Dragon Quest are powerful enemies, designed to instill fear in the player.
      Encountering them marks a difficulty spike where you go from fighting common mobs to legendary opponents.
    """
    
    @initialize()
  
  class @Pokemon extends PAA.Tutorials.Drawing.Instructions.Multiarea.UncompletedInstruction
    @id: -> "#{Asset.id()}.Pokemon"
    @assetClass: -> Asset
    @referenceUrl: -> Asset.createReferenceUrl 'pokemonredversion'
    
    @message: -> """
      Alakazam is said to have an IQ of 5000, making it the ultimate mind-over-matter Pokémon.
      Its triangular design communicates that it is intellectually sharp and makes it powerful without being physically strong.
    """
    
    @initialize()
    
  class @DayOfTheTentacle extends PAA.Tutorials.Drawing.Instructions.Multiarea.UncompletedInstruction
    @id: -> "#{Asset.id()}.DayOfTheTentacle"
    @assetClass: -> Asset
    @referenceUrl: -> Asset.createReferenceUrl 'dayofthetentacle'
    
    @message: -> """
      Even though the Purple Tentacle from Day of the Tentacle doesn't use the inverted triangle for its body,
      the downwards-pointed angry eyebrows unmistakably mark him as the villain.
    """
    
    @initialize()
