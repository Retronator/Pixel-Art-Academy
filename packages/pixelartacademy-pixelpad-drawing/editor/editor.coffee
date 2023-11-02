AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
AC = Artificial.Control
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

class PAA.PixelPad.Apps.Drawing.Editor extends LOI.Adventure.Thing
  @styleClass: -> throw new AE.NotImplementedException "Editor must provide a style class name."

  constructor: (@drawing) ->
    super arguments...
  
    # Drawing becomes active when theme transition completes.
    # The theme should set this to true or false based on its needs.
    @drawingActive = new ReactiveField false

    # Allow to manually provide sprite data.
    @manualSpriteData = new ReactiveField null

    # Allow to manually activate the editor.
    @manuallyActivated = new ReactiveField false

  onCreated: ->
    super arguments...
  
    # We can only deal with assets that can return pixels.
    filterAsset = (asset) =>
      if asset instanceof PAA.Practice.Project.Asset.Bitmap or asset instanceof PAA.PixelPad.Apps.Drawing.Portfolio.ArtworkAsset then asset else null
  
    @activeAsset = new ComputedField => filterAsset @drawing.portfolio().activeAsset()?.asset
    @displayedAsset = new ComputedField => filterAsset @drawing.portfolio().displayedAsset()?.asset
  
    # We need an editor view with a dummy file that will load data straight from the drawing app.
    @_dummyEditorViewFiles = [
      id: 0
      documentClassId: LOI.Assets.Asset.id()
      active: true
    ]
    
    interfaceData = @defaultInterfaceData()
    interfaceData.activeFileId = 0
  
    @localInterfaceData = new ReactiveField interfaceData
    
    @interface = new FM.Interface @,
      load: =>
        @localInterfaceData()
  
      save: (address, value) =>
        localInterfaceData = @localInterfaceData()
        _.nestedProperty localInterfaceData, address, value
        @localInterfaceData localInterfaceData
        
      loaders:
        "#{LOI.Assets.Asset.id()}": PAA.PixelPad.Apps.Drawing.Editor.AssetLoader

    # Handle changes when drawing is active.
    @autorun (computation) =>
      return unless @interface.isCreated()
      return unless fileData = @interface.getActiveFileData()
      
      drawingActive = @drawingActive()
      paused = LOI.adventure.paused()
      
      Tracker.nonreactive =>
        # Activate the interface only when drawing is active and the adventure is not paused.
        @interface.active drawingActive and not paused
        
        # Enable the pixel grid when in the editor.
        fileData.child('pixelGrid').set 'enabled', drawingActive
       
    # Invert UI colors for assets with dark backgrounds.
    @autorun (computation) =>
      return unless @interface.isCreated()
      return unless fileData = @interface.getActiveFileData()
      
      invert = false
  
      if backgroundColor = @displayedAsset()?.backgroundColor?()
        invert = backgroundColor.r < 0.5 and backgroundColor.g < 0.5 and backgroundColor.b < 0.5
      
      Tracker.nonreactive => fileData.set 'invertUIColors', invert
      
    # Deactivate active tool when closing the editor and reactivate it when opening if it's still available.
    @autorun (computation) =>
      return unless @interface.isCreated()

      if @active()
        # The editor is opened.
        unless @interface.activeTool()
          # Make sure the last active tool is still allowed.
          if @_lastActiveTool in @interface.tools()
            # Reactivate the last tool.
            Tracker.nonreactive => @interface.activateTool @_lastActiveTool

      else
        # The editor is being closed.
        if activeTool = @interface.activeTool()
          # Remember which tool was used and deactivate it.
          @_lastActiveTool = activeTool
          Tracker.nonreactive => @interface.deactivateTool()
          
    # Set zoom levels based on display scale.
    @autorun (computation) =>
      return unless @interface.isCreated()

      zoomLevels = [100, 200, 300, 400, 600, 800, 1200, 1600]
      displayScale = LOI.adventure.interface.display.scale()

      if displayScale % 3 is 0
        zoomLevels = [100 / 3, 200 / 3, zoomLevels...]

      else
        zoomLevels = [50, zoomLevels...]

      # Extend zoom levels down to clipboard scale if necessary.
      if displayedAsset = @displayedAsset()
        if displayedAsset.clipboardComponent.isCreated()
          if clipboardAssetSize = displayedAsset.clipboardComponent.assetSize()
            minimumScale = clipboardAssetSize.scale * 100
            while Math.round(minimumScale) < Math.round(zoomLevels[0])
              zoomLevels.unshift zoomLevels[0] / 2
        
      zoomLevelsHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.ZoomLevels
      Tracker.nonreactive => zoomLevelsHelper zoomLevels
      
    # Select a default color if no color is set or the color is not available.
    @autorun (computation) =>
      return unless @interface.isCreated()
      return unless asset = @interface.getLoaderForActiveFile()?.asset()
      hasRestrictedPalette = asset.hasRestrictedPalette()
      
      paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint
  
      paletteColor = paintHelper.paletteColor()
     
      if materialIndex = paintHelper.materialIndex()
        # Find the indexed color of the material.
        paletteColor = asset.materials?[materialIndex]
        setColor = not paletteColor

      if paletteColor
        if paletteId = paintHelper.paletteId()
          # We have a specified palette. Wait until information about the palette is available.
          return unless palette = LOI.Assets.Palette.documents.findOne paletteId
        
        else
          # We have a restricted palette color. Wait until information about the palette is available.
          return unless palette = asset.getRestrictedPalette()

        # Only reset the color if the palette does not contain the current one.
        setColor = not (palette.ramps[paletteColor.ramp]?.shades[paletteColor.shade])

      else
        # We need to set the color if we're in restricted palette or we have no direct color.
        setColor = hasRestrictedPalette or not paintHelper.directColor()

      if setColor
        Tracker.nonreactive =>
          # For assets with restricted colors, set the first palette color.
          if hasRestrictedPalette
            paintHelper.setPaletteColor ramp: 0, shade: 0
            
          # Set a black direct color.
          else
            paintHelper.setDirectColor r: 0, g: 0, b: 0
  
  onRendered: ->
    super arguments...
    
    $(document).on 'keydown.pixelartacademy-pixelpad-apps-drawing-editor', (event) => @onKeyDown event
    
  onDestroyed: ->
    super arguments...
    
    $(document).off '.pixelartacademy-pixelpad-apps-drawing-editor'
    
  defaultInterfaceData: -> throw new AE.NotImplementedException "Editor must provide default interface data."
  
  getShortcuts: ->
    isMacOS = AM.ShortcutHelper.currentPlatformConvention is AM.ShortcutHelper.PlatformConventions.MacOS
  
    currentMappingId: 'default'
    default:
      name: "Default"
      mapping:
        "#{LOI.Assets.SpriteEditor.Tools.ColorFill.id()}": key: AC.Keys.g
        "#{LOI.Assets.SpriteEditor.Tools.ColorPicker.id()}": [{key: AC.Keys.i, holdKey: AC.Keys.alt}, {holdKey: AC.Keys.c}]
        "#{PAA.PixelBoy.Apps.Drawing.Editor.Tools.MoveCanvas.id()}": key: AC.Keys.h, holdKey: AC.Keys.space
      
        "#{LOI.Assets.Editor.Actions.Undo.id()}": commandOrControl: true, key: AC.Keys.z
        "#{LOI.Assets.Editor.Actions.Redo.id()}": if isMacOS then command: true, shift: true, key: AC.Keys.z else control: true, key: AC.Keys.y
        "#{LOI.Assets.SpriteEditor.Actions.ZoomIn.id()}": [{key: AC.Keys.equalSign, keyLabel: '+'}, {commandOrControl: true, key: AC.Keys.equalSign}, {key: AC.Keys.numPlus}]
        "#{LOI.Assets.SpriteEditor.Actions.ZoomOut.id()}": [{key: AC.Keys.dash}, {commandOrControl: true, key: AC.Keys.dash}, {key: AC.Keys.numMinus}]

  active: ->
    @manuallyActivated() or AB.Router.getParameter('parameter4') is 'edit'

  onBackButton: ->
    return unless @manuallyActivated()
    @manuallyActivated false

    # Inform that we've handled the back button.
    true
    
  onKeyDown: (event) ->
    # Prevent the alt key opening the menu in the desktop version.
    return unless Meteor.isDesktop
    return unless @drawingActive()
    
    event.preventDefault() if event.keyCode is AC.Keys.alt
