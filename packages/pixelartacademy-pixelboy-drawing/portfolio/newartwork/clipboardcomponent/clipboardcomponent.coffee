AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.PixelBoy.Apps.Drawing.Portfolio.NewArtwork.ClipboardComponent extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.Apps.Drawing.Portfolio.NewArtwork.ClipboardComponent'
  @initializeDataComponent()
  
  @ArtworkTypes =
    Sprite: 'Sprite'
    Canvas: 'Canvas'
  
  @SizeTypes =
    Freeform: 'Freeform'
    Fixed: 'Fixed'

  onCreated: ->
    super arguments...
    
    @paletteNames = [
      LOI.Assets.Palette.SystemPaletteNames.pico8
      LOI.Assets.Palette.SystemPaletteNames.zxSpectrum
      LOI.Assets.Palette.SystemPaletteNames.black
    ]
    
    for paletteName in @paletteNames
      LOI.Assets.Palette.forName.subscribe @, paletteName
    
    @sizeType = new ReactiveField @constructor.SizeTypes.Fixed
    
  palettes: ->
    LOI.Assets.Palette.documents.find(name: $in: @paletteNames).fetch()

  events: ->
    super(arguments...).concat
      'click .submit-button': @onClickSubmitButton

  onClickSubmitButton: (event) ->
    event.preventDefault()
    
    # TODO: Create artwork.
  
  class @SizeType extends @DataInputComponent
    @register 'PixelArtAcademy.PixelBoy.Apps.Drawing.Portfolio.NewArtwork.ClipboardComponent.SizeType'
    
    constructor: ->
      super arguments...
      
      @type = AM.DataInputComponent.Types.Select
      @propertyName = 'sizeType'
    
    options: ->
      {name, value} for name, value of PAA.PixelBoy.Apps.Drawing.Portfolio.NewArtwork.ClipboardComponent.SizeTypes
