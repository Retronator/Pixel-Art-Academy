AB = Artificial.Base
AM = Artificial.Mirage
AC = Artificial.Control
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

class PAA.Pixeltosh.OS.Interface extends FM.Interface
  @menuId = _.snakeCase 'PixelArtAcademy.Pixeltosh.OS.Interface.Menu'
  
  constructor: (parent) ->
    localInterfaceDataField = new ReactiveField null
    
    super parent,
      load: =>
        localInterfaceDataField()
      save: (address, value) =>
        localInterfaceData = localInterfaceDataField()
        _.nestedProperty localInterfaceData, address, value
        localInterfaceDataField localInterfaceData

    active = true
    
    activeToolId = LOI.Assets.Editor.Tools.Arrow.id()
  
    components = {}
    
    menu =
      id: @constructor.menuId
      type: FM.Menu.id()
      left: 0
      top: 0
      right: 0
      height: 0
      order: 0
      alwaysOnTop: true
      items: []
      
    cursor =
      id: Random.id()
      type: PAA.Pixeltosh.OS.Interface.Cursor.id()
      
    layouts =
      currentLayoutId: 'main'
      main:
        name: 'Main'
        windows:
          "#{menu.id}": menu
        overlays:
          "#{cursor.id}": cursor
        
    shortcuts =
      currentMappingId: 'default'
      default:
        mapping: {}
        
    localInterfaceDataField {active, activeToolId, components, layouts, shortcuts}
