AB = Artificial.Base
AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.PixelPad.Apps.Drawing.Portfolio.Forms.Extras extends AM.Component
  @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.Forms.Extras'
  @initializeDataComponent()
  
  constructor: (@options) ->
    super arguments...
    
    @properties = new ReactiveField @options.initialProperties or []

    @restrictedColorsError = new ReactiveField false
  
  onCreated: ->
    super arguments...
    
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
  
  validateRestrictedColors: ->
    properties = @properties()
    @restrictedColorsError not _.find properties, (property) => property.type is @constructor.Extra.Types.RestrictedColors
    
  class @Extra extends AM.Component
    @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.Forms.Extras.Extra'
  
    @Types =
      RestrictedColors: 'RestrictedColors'
      ColorPalette: 'ColorPalette'
      PixelArtScaling: 'PixelArtScaling'
      PixelArtEvaluation: 'PixelArtEvaluation'
      CanvasBorder: 'CanvasBorder'
    
    @TypeNames =
      RestrictedColors: 'Restricted colors'
      ColorPalette: 'Color palette'
      PixelArtScaling: 'Pixel art scaling'
      PixelArtEvaluation: 'Pixel art evaluation'
      CanvasBorder: 'Canvas border'
      
    @MultiselectionTypes = [
      @Types.ColorPalette
    ]
    
    onCreated: ->
      super arguments...
      
      @extras = @parentComponent()
      
    updateType: (newType) ->
      index = @data().index
      lastType = @data().type
      
      # Remove property when deselected.
      if not newType
        @extras.removePropertyAtIndex index
      
      # Select defaults when changing the type.
      else if newType isnt lastType
        switch newType
          when @constructor.Types.ColorPalette then value = LOI.Assets.Palette.SystemPaletteNames.Black
          when @constructor.Types.RestrictedColors then value = LOI.Assets.Palette.SystemPaletteNames.Black
          when @constructor.Types.PixelArtScaling then value = true
          when @constructor.Types.PixelArtEvaluation then value = true
          when @constructor.Types.CanvasBorder then value = true
  
        @extras.updatePropertyAtIndex index, newType, value
      
        @extras.validateRestrictedColors() if newType is @constructor.Types.RestrictedColors
    
    updateValue: (newValue) ->
      index = @data().index
      type = @data().type
      
      if newValue
        @extras.updatePropertyAtIndex index, type, newValue
        
      else
        # Remove the property.
        @extras.removePropertyAtIndex index

    events: ->
      super(arguments...).concat
        'click .color-palette': @onClickColorPalette
    
    onClickColorPalette: (event) ->
      extra = @currentData()
      drawing = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing
      
      selectedPalette = await drawing.showPaletteSelection extra.value
      
      @updateValue selectedPalette.name if selectedPalette
  
    class @Type extends AM.DataInputComponent
      @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.Forms.Extras.Extra.Type'
      
      constructor: ->
        super arguments...
        
        @type = AM.DataInputComponent.Types.Select
  
      onCreated: ->
        super arguments...
  
        @extraComponent = @parentComponent()
      
      options: ->
        options = [name: '', value: null]
        
        Extra = PAA.PixelPad.Apps.Drawing.Portfolio.Forms.Extras.Extra
        
        for type, name of Extra.TypeNames
          if allowedTypes = @extraComponent.extras.options.allowedTypes
            continue unless type in allowedTypes
          
          # Add the option if it's the currently active one, if it's a multi-selection one, or if it's not yet selected.
          active = @data().type is type
          
          multiSelection = type in Extra.MultiselectionTypes
          
          properties = @extraComponent.extras.properties()
          existingProperty = _.find properties, (property) -> property.type is type
    
          options.push {name: name, value: type} if active or multiSelection or not existingProperty
    
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
      @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.Forms.Extras.Extra.PixelArtScaling'
      
      constructor: ->
        super arguments...
        
        @type = AM.DataInputComponent.Types.Checkbox
        
    class @PixelArtEvaluation extends @Value
      @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.Forms.Extras.Extra.PixelArtEvaluation'
      
      constructor: ->
        super arguments...
        
        @type = AM.DataInputComponent.Types.Checkbox
    
    class @CanvasBorder extends @Value
      @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.Forms.Extras.Extra.CanvasBorder'
      
      constructor: ->
        super arguments...
        
        @type = AM.DataInputComponent.Types.Checkbox
    
    class @Palette extends @Value
      @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.Forms.Extras.Extra.Palette'
      
      constructor: ->
        super arguments...
        
        @type = AM.DataInputComponent.Types.Select
        
      options: ->
        options = [
          name: '', value: null
        ]
        
        palettes = LOI.Assets.Palette.documents.fetch
          category: $exists: true
        ,
          sort: name: 1
        
        for palette in palettes
          options.push {name: palette.name, value: palette.name}
          
        options
