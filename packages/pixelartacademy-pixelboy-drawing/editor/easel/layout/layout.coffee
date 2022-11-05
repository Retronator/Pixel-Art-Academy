AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

class PAA.PixelBoy.Apps.Drawing.Editor.Easel.Layout extends FM.View
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Easel.Layout'
  @register @id()
  
  @template: -> @constructor.id()
  
  onCreated: ->
    super arguments...

    @easel = @interface.ancestorComponentOfType PAA.PixelBoy.Apps.Drawing.Editor.Easel
    
    frameBottom = 49 # rem
    @movableStandMinimumBottom = 16 # rem
    movableStandMinimumOffset = frameBottom + @movableStandMinimumBottom
    layoutMaximumOffset = 45 # rem
    
    @pixelBoyHeight = new ComputedField =>
      @easel.drawing.getMaximumPixelBoySize(fullscreen: true).height
      
    @layoutAdjustedMaximumOffset = new ComputedField =>
      # Proportionally adjust how much we offset the layout based on how much over safe area height we are.
      safeAreaHeight = LOI.adventure.interface.display.safeAreaHeight()
      maxOverlayHeight = safeAreaHeight * 1.5
      currentHeight = @pixelBoyHeight()
      
      layoutMaximumOffset * ((currentHeight - safeAreaHeight) / (maxOverlayHeight - safeAreaHeight))
   
    @assetSize = new ComputedField =>
      return unless displayedAsset = @easel.displayedAsset()
      return unless displayedAsset.clipboardComponent.isCreated()
      return unless clipboardAssetSize = displayedAsset.clipboardComponent.assetSize()
    
      width = clipboardAssetSize.contentWidth + 2 * clipboardAssetSize.borderWidth
      height = clipboardAssetSize.contentHeight + 2 * clipboardAssetSize.borderWidth
      
      { width, height }
      
    @frameOffset = new ComputedField =>
      return unless assetSize = @assetSize()
      pixelBoyHeight = @pixelBoyHeight()
  
      totalOffset = (pixelBoyHeight - assetSize.height) / 2
  
      layoutBottom = 0
      movableStandBottom = @movableStandMinimumBottom
      
      if totalOffset < movableStandMinimumOffset
        assetBottom = movableStandMinimumOffset
        
      else
        assetBottom = totalOffset
        
        # Raise layout to the max.
        remainingOffset = totalOffset - movableStandMinimumOffset
  
        layoutAdjustedMaximumOffset = @layoutAdjustedMaximumOffset()
        
        if remainingOffset <= layoutAdjustedMaximumOffset
          layoutBottom = remainingOffset
          assetBottom = totalOffset
          
        else
          layoutBottom = layoutAdjustedMaximumOffset
          remainingOffset -= layoutAdjustedMaximumOffset
          
          # Raise movable stand to achieve total offset.
          movableStandBottom += remainingOffset
          
      assetTop = pixelBoyHeight - assetBottom - assetSize.height
  
      { layoutBottom, movableStandBottom, assetTop }
      
  displayMode: ->
    @easel.displayMode()

  colorFillEnabled: ->
    @easel.toolIsAvailable PAA.Practice.Software.Tools.ToolKeys.ColorFill
  
  colorFillData: ->
    layoutData = @data()
    layoutData.child "colorFill"
  
  toolboxData:  ->
    layoutData = @data()
    layoutData.child "toolbox"
    
  action: ->
    toolId = @currentData()
    @interface.getOperator toolId

  actionClass: ->
    action = @currentData()
  
    _.kebabCase action.displayName()

  actionEnabledClass: ->
    enabled = true
    action = @currentData()
  
    if action.enabled
      enabled = _.propertyValue action, 'enabled'
  
    'enabled' if enabled
  
  actionTooltip: ->
    action = @currentData()
    name = action.displayName()
    shortcut = action.currentShortcut()
    return name unless shortcut
  
    shortcut = shortcut[0] if _.isArray shortcut
    shortcut = AM.ShortcutHelper.getShortcutString shortcut
  
    "#{name} (#{shortcut})"
  
  assetPlaceholderStyle: ->
    return unless assetSize = @assetSize()

    left: "#{-assetSize.width / 2}rem"
    width: "#{assetSize.width}rem"
    height: "#{assetSize.height}rem"
  
  layoutStyle: ->
    return unless frameOffset = @frameOffset()
    bottom: "#{frameOffset.layoutBottom}rem"
  
  movableStandStyle: ->
    return unless frameOffset = @frameOffset()
  
    bottom = if @_canvasHeld() then frameOffset.movableStandBottom else @movableStandMinimumBottom
    
    bottom: "#{bottom}rem"
  
  movableStandTopStyle: ->
    return unless assetSize = @assetSize()
    
    bottom = if @_canvasHeld() then assetSize.height - 3 else 190
    
    bottom: "#{bottom}rem"
    
  _canvasHeld: ->
    normalDisplayMode = @easel.displayMode() is PAA.PixelBoy.Apps.Drawing.Editor.Easel.DisplayModes.Normal
    @easel.active() and normalDisplayMode

  events: ->
    super(arguments...).concat
      'click .action-button': @onClickActionButton

  onClickActionButton: (event) ->
    action = @currentData()
    return if action.enabled and not action.enabled()
  
    action.execute @
