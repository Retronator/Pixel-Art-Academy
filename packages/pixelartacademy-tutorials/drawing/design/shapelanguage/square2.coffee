AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

CartridgeTypes = PAA.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent.Reference.SceneObject.Cartridge.Types

class PAA.Tutorials.Drawing.Design.ShapeLanguage.Square2 extends PAA.Tutorials.Drawing.Design.ShapeLanguage.AssetWithReferences
  @displayName: -> "Square 2"

  @description: -> """
    The square shape language can be used to design strong or serious characters.
  """

  @fixedDimensions: -> width: 26, height: 28
  @backgroundColor: -> new THREE.Color '#6c6c6c'
  
  @referenceNames: -> [
    'thelegendofzeldalinksawakeningdx'
    'metalslug1stmission'
    'advancewars'
  ]
  
  @bitmapInfoTextsForReferences: -> [
    "The Legend of Zelda: Link's Awakening DX (Nintendo, 1998)"
    "Metal Slug 1st Mission (Ukiyotei, 1999)"
    "Advance Wars (Intelligent Systems, 2001)"
  ]
  
  @cartridgeTypesForReferences: -> [
    CartridgeTypes.GameBoy
    CartridgeTypes.NeoGeoPocket
    CartridgeTypes.GameBoyAdvance
  ]
  
  @rampsCountForReferences: -> [
    1,
    1,
    2
  ]
  
  @initialize()

  Asset = @

  class @Zelda extends PAA.Tutorials.Drawing.Instructions.Multiarea.UncompletedInstruction
    @id: -> "#{Asset.id()}.Zelda"
    @assetClass: -> Asset
    @referenceUrl: -> Asset.createReferenceUrl 'thelegendofzeldalinksawakeningdx'
    
    @message: -> """
      Darknuts from The Legend of Zelda series are knights in heavy armor.
      The square appearance reinforces them as formidable, mid-game opponents.
    """
    
    @initialize()
  
  class @MetalSlug extends PAA.Tutorials.Drawing.Instructions.Multiarea.UncompletedInstruction
    @id: -> "#{Asset.id()}.MetalSlug"
    @assetClass: -> Asset
    @referenceUrl: -> Asset.createReferenceUrl 'metalslug1stmission'
    
    @message: -> """
      Marco Rossi from the Metal Slug series, like many action game protagonists,
      draws on his muscular, rectangular physique, cementing him as the primary hero of the game.
    """
    
    @initialize()
    
  class @AdvanceWars extends PAA.Tutorials.Drawing.Instructions.Multiarea.UncompletedInstruction
    @id: -> "#{Asset.id()}.AdvanceWars"
    @assetClass: -> Asset
    @referenceUrl: -> Asset.createReferenceUrl 'advancewars'
    
    @message: -> """
      The Medium Tank in Advance Wars is the blockiest of all units,
      signaling its superior defense against most other units.
    """
    
    @initialize()
