AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Dialog extends FM.View
  @id: -> 'LandsOfIllusions.Assets.Editor.Dialog'
  @register @id()

  closeDialog: ->
    dialogData = @ancestorComponentOfType(FM.FloatingArea).data()
    @interface.closeDialog dialogData

  events: ->
    super(arguments...).concat
      'click .button': @onClickButton

  onClickButton: (event) ->
    button = @currentData()
    result = button.value

    dialog = @data()
    dialog.callback result

    @closeDialog()
