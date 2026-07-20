AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.About extends FM.Dialog
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.About'
  @register @id()
  
  @createInterfaceData: ->
    contentComponentId: @id()
    left: 60
    top: 74
    width: 200
    
  onRendered: ->
    # Listen to click events on the parent dialog area.
    @$('.pixelartacademy-pixeltosh-programs-chess-interface-about').closest('.dialog-area').on 'click', => @closeDialog()
