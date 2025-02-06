AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.About extends FM.Dialog
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.About'
  @register @id()
  
  @createInterfaceData: ->
    contentComponentId: @id()
    left: 60
    top: 74
    width: 200
    
  onRendered: ->
    # Listen to click events on the parent dialog area.
    @$('.pixelartacademy-pixeltosh-programs-pinball-interface-about').closest('.dialog-area').on 'click', => @closeDialog()
