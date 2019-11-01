AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Actions.PersistEditorsInterface extends FM.Action
  @id: -> 'LandsOfIllusions.Assets.Editor.Actions.PersistEditorsInterface'
  @displayName: -> "Auto-save user interface"

  @initialize()

  active: ->
    LOI.settings.persistEditorsInterface.allowed()
    
  execute: ->
    if @active()
      LOI.settings.persistEditorsInterface.disallow()
      
    else
      consentFieldOptions = LOI.settings.persistEditorsInterface.options

      @interface.displayDialog
        contentComponentId: LOI.Assets.Editor.Dialog.id()
        contentComponentData:
          title: @displayName()
          message: consentFieldOptions.question
          moreInfo: consentFieldOptions.moreInfo
          buttons: [
            text: "Yes"
            value: true
          ,
            text: "No"
          ]
          callback: (allow) =>
            LOI.settings.persistEditorsInterface.allow allow is true
