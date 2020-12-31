AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Window extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.Editor.Window'
  @register @id()

  events: ->
    super(arguments...).concat
      'click .close-button': @onClickCloseButton

  onClickCloseButton: (event) ->
    floatingAreaData = @ancestorComponentOfType(FM.FloatingArea).data()
    interfaceComponent = @ancestorComponentOfType FM.Interface

    if @$('.landsofillusions-assets-editor-window').closest('.dialog-area').length
      # This is a dialog.
      interfaceComponent.closeDialog floatingAreaData

    else
      interfaceComponent.removeWindow floatingAreaData
