AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

CartridgeTypes = PAA.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent.Reference.SceneObject.Cartridge.Types

class PAA.Tutorials.Drawing.Design.ShapeLanguage.BreakingTheRules extends PAA.Tutorials.Drawing.Design.ShapeLanguage.AssetWithReferences
  @displayName: -> "Breaking the rules"

  @description: -> """
    Using shapes with opposing meanings can be used to camouflage the character's nature and create interesting contrast.
  """

  @fixedDimensions: -> width: 44, height: 58
  @backgroundColor: -> new THREE.Color '#783ca6'
  
  @referenceNames: -> [
    'sonicthehedgehog'
    'samandmaxhittheroad'
    'monkeyisland2'
  ]
  
  @bitmapInfoTextsForReferences: -> [
    "Sonic the Hedgehog (Sega, 1991)"
    "Sam & Max Hit the Road (LucasArts, 1993)"
    "Monkey Island 2: LeChuck's Revenge (LucasArts, 1991)"
  ]
  
  @cartridgeTypesForReferences: -> [
    CartridgeTypes.Genesis
    CartridgeTypes.FloppyDisk
    CartridgeTypes.FloppyDisk
  ]
  
  @rampsCountForReferences: -> [
    4,
    1,
    4
  ]
  
  @initialize()

  Asset = @

  class @Eggman extends PAA.Tutorials.Drawing.Instructions.Multiarea.UncompletedInstruction
    @id: -> "#{Asset.id()}.Eggman"
    @assetClass: -> Asset
    @referenceUrl: -> Asset.createReferenceUrl 'sonicthehedgehog'
    
    @message: -> """
      Not every villain is triangular. Doctor "Eggman" Robotnik's use of circles makes him
      a comical antagonist who is more silly and self-important than menacing or terrifying.
    """
    
    @initialize()

  class @Max extends PAA.Tutorials.Drawing.Instructions.Multiarea.UncompletedInstruction
    @id: -> "#{Asset.id()}.Max"
    @assetClass: -> Asset
    @referenceUrl: -> Asset.createReferenceUrl 'samandmaxhittheroad'
    
    @message: -> """
      The only giveaway of Max's chaotic character on his cuddly, circular appearance is his sharp-toothed grin.
    """
    
    @initialize()

  class @Guybrush extends PAA.Tutorials.Drawing.Instructions.Multiarea.UncompletedInstruction
    @id: -> "#{Asset.id()}.Guybrush"
    @assetClass: -> Asset
    @referenceUrl: -> Asset.createReferenceUrl 'monkeyisland2'
    
    @message: -> """
      Guybrush Threepwood's stoic stance, squared off with a giant, dramatic pirate coat,
      shows how Guybrush thinks of himself as a real pirate in Monkey Island 2: LeChuck's Revenge.
      Yet underneath, he's still the doofus we know and love.
    """
    
    @initialize()
