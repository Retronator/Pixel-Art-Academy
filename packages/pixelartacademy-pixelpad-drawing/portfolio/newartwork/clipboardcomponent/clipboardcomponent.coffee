AB = Artificial.Base
AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.PixelPad.Apps.Drawing.Portfolio.NewArtwork.ClipboardComponent extends AM.Component
  @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.NewArtwork.ClipboardComponent'
  @initializeDataComponent()
  
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
      LOI.Assets.Palette.forName.subscribeContent @, paletteName
  
    @sizeType = new ReactiveField @constructor.SizeTypes.Fixed
    
    @widthError = new ReactiveField false
    @heightError = new ReactiveField false
    @sizeOutOfRangeError = new ReactiveField false
    
    @properties = new ReactiveField []
    
    @extras = new ComputedField =>
      properties = @properties()
      
      extras = for property, index in properties
        _id: Random.id()
        index: index
        type: property.type
        value: property.value
  
      # Add an extra for the new property.
      extras.push _id: Random.id(), index: extras.length
      
      extras
      
    @blankExtras = new ComputedField =>
      properties = @properties()
      return if properties.length > 4
      
      [properties.length...5]

  updatePropertyAtIndex: (index, type, value) ->
    properties = @properties()
    property = {type, value}
    
    if properties[index]
      properties[index] = property

    else
      properties.push property
      
    # Enforce mutually exclusive properties.
    if type is @constructor.Extra.Types.RestrictedColors
      _.remove properties, (property) =>
        property.type is @constructor.Extra.Types.ColorPalette
      
    else if type is @constructor.Extra.Types.ColorPalette
      _.remove properties, (property) =>
        property.type is @constructor.Extra.Types.RestrictedColors
    
    @properties properties
  
  removePropertyAtIndex: (index) ->
    properties = @properties()
    properties.splice index, 1
    @properties properties
  
  validateWidth: (value) -> @widthError @validateDimension value
  validateHeight: (value) -> @heightError @validateDimension value
  validateDimension: (value) ->
    maxSize = @maxSize()
    @sizeOutOfRangeError true if value > maxSize

    _.isNaN(value) or 0 <= value > maxSize
  
  errorClasses: ->
    errorClasses = for field in ['width', 'height'] when @["#{field}Error"]()
      "error-#{field}"
      
    errorClasses.join ' '
    
  maxSize: -> PAA.Practice.Artworks.maxSize
  
  events: ->
    super(arguments...).concat
      'input .property.size .width input': @onInputWidth
      'input .property.size .height input': @onInputHeight
      'change .property.size .width input': @onChangeWidth
      'change .property.size .height input': @onChangeHeight
      'change .palette': @onChangePalette
      'submit .newartwork-form': @onSubmitNewArtworkForm

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
      title: data.get 'title'
    
    if @sizeType() is @constructor.SizeTypes.Fixed
      artworkInfo.size =
        width: parseInt data.get 'width'
        height: parseInt data.get 'height'
  
      @validateWidth artworkInfo.size.width
      @validateHeight artworkInfo.size.height

    return if @errorClasses()

    # Add properties.
    paletteColors = []
    paletteId = null
    properties = {}
    
    getPaletteId = (name) -> LOI.Assets.Palette.documents.findOne({name})._id
    
    for property in @properties()
      if property.type is @constructor.Extra.Types.ColorPalette
        paletteColors.push getPaletteId property.value
        
      else if property.type is @constructor.Extra.Types.RestrictedColors
        paletteId = getPaletteId property.value
        
      else
        properties[_.camelCase property.type] = property.value
        
    properties.paletteIds = paletteColors if paletteColors.length > 0
    artworkInfo.properties = properties if _.keys(properties).length > 0
    artworkInfo.paletteId = paletteId if paletteId?
    
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
        AB.Router.changeParameter 'parameter3', artworkId
  
  class @SizeType extends @DataInputComponent
    @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.NewArtwork.ClipboardComponent.SizeType'
    
    constructor: ->
      super arguments...
      
      @type = AM.DataInputComponent.Types.Select
      @propertyName = 'sizeType'
    
    options: ->
      {name, value} for name, value of PAA.PixelPad.Apps.Drawing.Portfolio.NewArtwork.ClipboardComponent.SizeTypes
      
  class @Extra extends AM.Component
    @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.NewArtwork.ClipboardComponent.Extra'
  
    @Types =
      RestrictedColors: 'RestrictedColors'
      ColorPalette: 'ColorPalette'
      PixelArtScaling: 'PixelArtScaling'
      PixelArtGrading: 'PixelArtGrading'
    
    @TypeNames =
      RestrictedColors: 'Restricted colors'
      ColorPalette: 'Color palette'
      PixelArtScaling: 'Pixel art scaling'
      PixelArtGrading: 'Pixel art grading'
      
    @MultiselectionTypes = [
      @Types.ColorPalette
    ]
    
    onCreated: ->
      super arguments...
      
      @clipboardComponent = @parentComponent()
      
    updateType: (newType) ->
      index = @data().index
      lastType = @data().type
      
      # Remove property when deselected.
      if not newType
        @clipboardComponent.removePropertyAtIndex index
      
      # Select defaults when changing the type.
      else if newType isnt lastType
        switch newType
          when @constructor.Types.PixelArtScaling, @constructor.Types.PixelArtGrading then value = true
          when @constructor.Types.ColorPalette, @constructor.Types.RestrictedColors then value = @clipboardComponent.paletteNames[0]
  
        @clipboardComponent.updatePropertyAtIndex index, newType, value
      
    updateValue: (newValue) ->
      index = @data().index
      type = @data().type
      
      if newValue
        @clipboardComponent.updatePropertyAtIndex index, type, newValue
        
      else
        # Remove the property.
        @clipboardComponent.removePropertyAtIndex index
  
    class @Type extends AM.DataInputComponent
      @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.NewArtwork.ClipboardComponent.Extra.Type'
      
      constructor: ->
        super arguments...
        
        @type = AM.DataInputComponent.Types.Select
        @extraComponent = @ancestorComponentOfType @constructor
  
      onCreated: ->
        super arguments...
  
        @extraComponent = @parentComponent()
      
      options: ->
        options = [name: '', value: null]
        
        Extra = PAA.PixelPad.Apps.Drawing.Portfolio.NewArtwork.ClipboardComponent.Extra
        
        for value, name of Extra.TypeNames
          # Add the option if it's the currently active one, if it's a multi-selection one, or if it's not yet selected.
          active = @data().type is value
          
          multiSelection = value in Extra.MultiselectionTypes
          
          properties = @extraComponent.clipboardComponent.properties()
          existingProperty = _.find properties, (property) -> property.type is value
    
          options.push name: name, value: value if active or multiSelection or not existingProperty
    
        options
        
      load: ->
        @data().type
        
      save: (value) ->
        @extraComponent.updateType value
  
    class @Value extends AM.DataInputComponent
      onCreated: ->
        super arguments...
  
        @extraComponent = @parentComponent()
        
      load: ->
        @data().value

      save: (value) ->
        @extraComponent.updateValue value
        
    class @PixelArtScaling extends @Value
      @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.NewArtwork.ClipboardComponent.Extra.PixelArtScaling'
      
      constructor: ->
        super arguments...
        
        @type = AM.DataInputComponent.Types.Checkbox
        
    class @PixelArtGrading extends @Value
      @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.NewArtwork.ClipboardComponent.Extra.PixelArtGrading'
      
      constructor: ->
        super arguments...
        
        @type = AM.DataInputComponent.Types.Checkbox
    
    class @Palette extends @Value
      @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.NewArtwork.ClipboardComponent.Extra.Palette'
      
      constructor: ->
        super arguments...
        
        @type = AM.DataInputComponent.Types.Select
        
      options: ->
        options = [name: '', value: null]

        for paletteName in @extraComponent.clipboardComponent.paletteNames
          options.push {name: paletteName, value: paletteName}
          
        options
