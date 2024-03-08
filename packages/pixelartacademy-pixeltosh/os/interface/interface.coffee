AB = Artificial.Base
AM = Artificial.Mirage
AC = Artificial.Control
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

class PAA.Pixeltosh.OS.Interface extends FM.Interface
  constructor: (parent) ->
    activeToolId = LOI.Assets.Editor.Tools.Arrow.id()
  
    components = {}
    
    menu =
      type: FM.Menu.id()
      left: 0
      top: 0
      right: 0
      height: 0
      order: 0
      items: []
    
    layouts =
      currentLayoutId: 'main'
      main:
        name: 'Main'
        windows: [
          menu
        ]
        overlays: [
          type: PAA.Pixeltosh.OS.Interface.Cursor.id()
        ]
        
    shortcuts =
      currentMappingId: 'default'
      default:
        mapping: {}
        
    localInterfaceDataField = new ReactiveField {activeToolId, components, layouts, shortcuts}
    
    super parent,
      load: =>
        localInterfaceDataField()
      
      save: (address, value) =>
        localInterfaceData = localInterfaceDataField()
        _.nestedProperty localInterfaceData, address, value
        localInterfaceDataField localInterfaceData
