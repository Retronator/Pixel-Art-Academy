AC = Artificial.Control
AM = Artificial.Mirage
FM = FataMorgana

class FM.Dialog extends FM.View
  closeDialog: ->
    dialogData = @ancestorComponentOfType(FM.FloatingArea).data()
    @interface.closeDialog dialogData
