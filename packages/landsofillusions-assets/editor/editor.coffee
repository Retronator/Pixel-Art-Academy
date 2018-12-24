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

  onDestroyed: ->
    super arguments...

    $('html').removeClass('landsofillusions-assets-editor')
