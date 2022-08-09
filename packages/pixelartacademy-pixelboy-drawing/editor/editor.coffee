AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

class PAA.PixelBoy.Apps.Drawing.Editor extends LOI.Adventure.Thing
  @styleClass: -> throw new AE.NotImplementedException "Editor must provide a style class name."

  constructor: (@drawing) ->
    super arguments...

    @theme = new ReactiveField null
  
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
      if asset instanceof PAA.Practice.Project.Asset.Sprite or asset instanceof PAA.PixelBoy.Apps.Drawing.Portfolio.ArtworkAsset then asset else null
  
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
        "#{LOI.Assets.Asset.id()}": PAA.PixelBoy.Apps.Drawing.Editor.AssetLoader

    # Handle changes when drawing is active.
    @autorun (computation) =>
      return unless @interface.isCreated()
      return unless fileData = @interface.getActiveFileData()
      
      drawingActive = @drawingActive()
      
      Tracker.nonreactive =>
        # Activate the interface only when drawing is active.
        @interface.active drawingActive
        
        # Enable the pixel grid when in the editor.
        fileData.child('pixelGrid').set 'enabled', drawingActive
      
  defaultInterfaceData: -> throw new AE.NotImplementedException "Editor must provide default interface data."

  active: ->
    @manuallyActivated() or AB.Router.getParameter('parameter4') is 'edit'

  focusedMode: ->
    @theme()?.focusedMode?()

  onBackButton: ->
    return unless @manuallyActivated()
    @manuallyActivated false

    # Inform that we've handled the back button.
    true
