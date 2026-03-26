AB = Artificial.Base
AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

Extras = PAA.PixelPad.Apps.Drawing.Portfolio.Forms.Extras

class PAA.PixelPad.Apps.Drawing.Portfolio.NewArtwork.ClipboardComponent extends AM.Component
  @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.NewArtwork.ClipboardComponent'
  @initializeDataComponent()
  
  @SizeTypes =
    Freeform: 'Freeform'
    Fixed: 'Fixed'

  onCreated: ->
    super arguments...
    
    @autorun (computation) =>
      LOI.Assets.Palette.allCategorized.subscribeContent @
  
    @sizeType = new ReactiveField @constructor.SizeTypes.Fixed
    
    @widthError = new ReactiveField false
    @heightError = new ReactiveField false
    @sizeOutOfRangeError = new ReactiveField false
    
    @extras = new PAA.PixelPad.Apps.Drawing.Portfolio.Forms.Extras
      allowedTypes: [
        Extras.Extra.Types.CanvasBorder
        Extras.Extra.Types.RestrictedColors
        Extras.Extra.Types.PixelArtEvaluation
      ]
      initialProperties: [
        type: Extras.Extra.Types.CanvasBorder
        value: true
      ,
        type: Extras.Extra.Types.RestrictedColors
        value: LOI.Assets.Palette.SystemPaletteNames.Black
      ]
  
  validateWidth: (value) -> @widthError @validateDimension value
  validateHeight: (value) -> @heightError @validateDimension value
  validateDimension: (value) ->
    maxSize = @maxSize()
    @sizeOutOfRangeError true if value > maxSize

    _.isNaN(value) or 0 <= value > maxSize
  
  errorClasses: ->
    errorClasses = for field in ['width', 'height'] when @["#{field}Error"]()
      "error-#{field}"
      
    errorClasses.push 'error-size-out-of-range' if @sizeOutOfRangeError()
    errorClasses.push 'error-restricted-colors' if @extras.restrictedColorsError()
      
    errorClasses.join ' '
    
  maxSize: -> PAA.Practice.Artworks.maxSize
  
  events: ->
    super(arguments...).concat
      'input .property.size .width input': @onInputWidth
      'input .property.size .height input': @onInputHeight
      'change .property.size .width input': @onChangeWidth
      'change .property.size .height input': @onChangeHeight
      'submit .new-artwork-form': @onSubmitNewArtworkForm

  onInputWidth: (event) ->
    @widthError false
    @sizeOutOfRangeError false

  onInputHeight: (event) ->
    @heightError false
    @sizeOutOfRangeError false
  
  onChangeWidth: (event) ->
    @validateWidth $(event.target).val()

  onChangeHeight: (event) ->
    @validateHeight $(event.target).val()
    
  onSubmitNewArtworkForm: (event) ->
    event.preventDefault()
  
    data = new FormData event.target
    
    artworkInfo =
      title: data.get 'title'
    
    if @sizeType() is @constructor.SizeTypes.Fixed
      artworkInfo.size =
        width: parseInt data.get 'width'
        height: parseInt data.get 'height'
  
      @validateWidth artworkInfo.size.width
      @validateHeight artworkInfo.size.height
      
    @extras.validateRestrictedColors()

    return if @errorClasses()

    # Add properties.
    paletteColors = []
    paletteId = null
    properties =
      pixelArtScaling: true
    
    getPaletteId = (name) -> LOI.Assets.Palette.documents.findOne({name})._id
    
    for property in @extras.properties()
      if property.type is Extras.Extra.Types.ColorPalette
        paletteColors.push getPaletteId property.value
        
      else if property.type is Extras.Extra.Types.RestrictedColors
        paletteId = getPaletteId property.value
        
      else if property.type is Extras.Extra.Types.PixelArtEvaluation
        # Convert from a boolean to an editable pixel art evaluation.
        properties.pixelArtEvaluation = editable: true
        
      else
        properties[_.camelCase property.type] = property.value
        
    properties.paletteIds = paletteColors if paletteColors.length > 0
    artworkInfo.paletteId = paletteId if paletteId?
    artworkInfo.properties = properties
    
    artwork = PAA.Practice.Artworks.insert artworkInfo
    
    # Add artwork to the drawing app.
    artworks = PAA.PixelPad.Apps.Drawing.state('artworks') or []
    artworks.push artworkId: artwork._id
    PAA.PixelPad.Apps.Drawing.state 'artworks', artworks
    
    # Navigate to the artwork.
    AB.Router.changeParameter 'parameter3', artwork._id
  
  class @SizeType extends @DataInputComponent
    @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.NewArtwork.ClipboardComponent.SizeType'
    
    constructor: ->
      super arguments...
      
      @type = AM.DataInputComponent.Types.Select
      @propertyName = 'sizeType'
    
    options: ->
      {name, value} for name, value of PAA.PixelPad.Apps.Drawing.Portfolio.NewArtwork.ClipboardComponent.SizeTypes
