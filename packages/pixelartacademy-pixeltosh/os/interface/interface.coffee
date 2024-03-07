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
      items: [
        caption: ''
        items: []
      ,
        caption: 'File'
        items: []
      ,
        caption: 'Edit'
        items: []
      ,
        caption: 'View'
        items: []
      ,
        caption: 'Special'
        items: []
      ]
    
    layouts =
      currentLayoutId: 'main'
      main:
        name: 'Main'
        applicationArea:
          type: FM.SplitView.id()
          fixed: true
          mainArea: menu
          dockSide: FM.SplitView.DockSide.Top
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
