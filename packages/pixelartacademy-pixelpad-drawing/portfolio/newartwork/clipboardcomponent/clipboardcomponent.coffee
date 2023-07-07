AB = Artificial.Base
AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.PixelPad.Apps.Drawing.Portfolio.NewArtwork.ClipboardComponent extends AM.Component
  @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.NewArtwork.ClipboardComponent'
  @initializeDataComponent()
  
  @ArtworkTypes =
    Sprite: 'Sprite'
    Bitmap: 'Bitmap'
  
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
  
    @type = new ReactiveField null
    @maxSize = new ComputedField =>
      type = @type()
      if type then PAA.Practice.Artworks.maxSizes[type] else Number.POSITIVE_INFINITY
    
    @sizeType = new ReactiveField @constructor.SizeTypes.Fixed
    
    @typeError = new ReactiveField false
    @widthError = new ReactiveField false
    @heightError = new ReactiveField false
    @sizeOutOfRangeError = new ReactiveField false
  
  validateWidth: (value) -> @widthError @validateDimension value
  validateHeight: (value) -> @heightError @validateDimension value
  validateDimension: (value) ->
    maxSize = @maxSize()
    @sizeOutOfRangeError true if value > maxSize

    _.isNaN(value) or 0 <= value > maxSize
  
  errorClasses: ->
    errorClasses = for field in ['type', 'width', 'height'] when @["#{field}Error"]()
      "error-#{field}"
      
    errorClasses.join ' '
  
  palettes: ->
    LOI.Assets.Palette.documents.find(name: $in: @paletteNames).fetch()

  events: ->
    super(arguments...).concat
      'change .property.type input': @onChangeType
      'input .property.size .width input': @onInputWidth
      'input .property.size .height input': @onInputHeight
      'change .property.size .width input': @onChangeWidth
      'change .property.size .height input': @onChangeHeight
      'change .palette': @onChangePalette
      'submit .newartwork-form': @onSubmitNewArtworkForm
  
  onChangeType: (event) ->
    @typeError false
    @type @$('.newartwork-form')[0].type.value

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
  
  onChangePalette: (event) ->
    $target = $(event.target)
    value = $target.val()
    return unless value is 'lospec'
    
    lospecUrl = prompt "Enter Lospec URL for the desired palette"
    return unless lospecUrl
    
    lospecSlug = lospecUrl.substring lospecUrl.lastIndexOf('/') + 1
    
    LOI.Assets.Palette.importFromLospec lospecSlug, (error, paletteId) =>
      return console.error error if error

      # Wait till the new palette is loaded.
      Tracker.autorun (computation) =>
        return unless LOI.Assets.Palette.findOne paletteId
        
        # Give the dropdown a chance to refresh.
        Tracker.afterFlush =>
          $target.val paletteId
    
  onSubmitNewArtworkForm: (event) ->
    event.preventDefault()
  
    data = new FormData event.target
    
    artworkInfo =
      assetClassName: data.get 'type'
      title: data.get 'title'
      paletteId: data.get 'palette'
      
    @typeError true unless artworkInfo.assetClassName
    
    if @sizeType() is @constructor.SizeTypes.Fixed
      artworkInfo.size =
        width: parseInt data.get 'width'
        height: parseInt data.get 'height'
  
      @validateWidth artworkInfo.size.width
      @validateHeight artworkInfo.size.height
      
    return if @errorClasses()
    
    PAA.Practice.Artworks.insert LOI.characterId(), artworkInfo, (error, artworkId) =>
      return console.error error if error
      
      # Add artwork to the drawing app.
      artworks = PAA.PixelPad.Apps.Drawing.state('artworks') or []
      artworks.push {artworkId}
      PAA.PixelPad.Apps.Drawing.state 'artworks', artworks
      
      # Wait for the artwork to be available on the client.
      Tracker.autorun (computation) =>
        return unless PADB.Artwork.documents.findOne artworkId
        computation.stop()

        # Navigate to the artwork.
        AB.Router.setParameter 'parameter3', artworkId
  
  class @SizeType extends @DataInputComponent
    @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.NewArtwork.ClipboardComponent.SizeType'
    
    constructor: ->
      super arguments...
      
      @type = AM.DataInputComponent.Types.Select
      @propertyName = 'sizeType'
    
    options: ->
      {name, value} for name, value of PAA.PixelPad.Apps.Drawing.Portfolio.NewArtwork.ClipboardComponent.SizeTypes
