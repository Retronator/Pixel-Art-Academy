AB = Artificial.Base
AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor extends AM.Component
  @id: -> throw new AE.NotImplementedException "You have to define the ID of the editor."
  template: -> 'LandsOfIllusions.Assets.Editor'
    
  @defaultInterfaceData: -> throw new AE.NotImplementedException "You have to define initial user interface layouts."
    
  @defaultShortcutsMapping: ->
    isMacOS = AM.ShortcutHelper.currentPlatformConvention is AM.ShortcutHelper.PlatformConventions.MacOS

    # Actions
    "#{LOI.Assets.Editor.Actions.New.id()}": commandOrControl: true, key: AC.Keys.n
    "#{LOI.Assets.Editor.Actions.Open.id()}": commandOrControl: true, key: AC.Keys.o
    "#{LOI.Assets.Editor.Actions.Import.id()}": commandOrControl: true, key: AC.Keys.i
    "#{LOI.Assets.Editor.Actions.Export.id()}": commandOrControl: true, key: AC.Keys.e
    "#{LOI.Assets.Editor.Actions.Close.id()}": commandOrControl: true, key: AC.Keys.c
    "#{LOI.Assets.Editor.Actions.Undo.id()}": [{commandOrControl: true, key: AC.Keys.z}, {key: AC.Keys.z}]
    "#{LOI.Assets.Editor.Actions.Redo.id()}": if isMacOS then [{command: true, shift: true, key: AC.Keys.z}, {key: AC.Keys.x}] else control: true, key: AC.Keys.y

    # Tools
    "#{LOI.Assets.Editor.Tools.Arrow.id()}": key: AC.Keys.escape

  onCreated: ->
    super arguments...

    $('html').addClass('landsofillusions-assets-editor')

    @localInterfaceData = new ReactiveField @constructor.defaultInterfaceData()
    
    Artificial.Mummification.PersistentStorage.persist
      storageKey: "#{@constructor.id()}.interface"
      field: @localInterfaceData
      tracker: @
      consentField: LOI.settings.persistEditorsInterface.allowed
    
    @interface = new FM.Interface @,
      load: =>
        # TODO: Load interface data from the server if user is logged in.
        @localInterfaceData()

      save: (address, value) =>
        localInterfaceData = @localInterfaceData()
        _.nestedProperty localInterfaceData, address, value
        @localInterfaceData localInterfaceData

        # TODO: Save interface data to the server as well.
  
      loaders:
        "#{LOI.Assets.Sprite.id()}": LOI.Assets.SpriteEditor.SpriteLoader
        "#{LOI.Assets.Sprite.Rot8.id()}": LOI.Assets.SpriteEditor.Rot8Loader
        "#{LOI.Assets.Sprite.Mip.id()}": LOI.Assets.SpriteEditor.MipLoader
        "#{LOI.Assets.Mesh.id()}": LOI.Assets.MeshEditor.MeshLoader
        "#{LOI.Assets.Audio.id()}": LOI.Assets.AudioEditor.AudioLoader

  onDestroyed: ->
    super arguments...

    $('html').removeClass('landsofillusions-assets-editor')
