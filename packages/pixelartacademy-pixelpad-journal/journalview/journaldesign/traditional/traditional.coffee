AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Journal.JournalView.JournalDesign.Traditional extends PAA.PixelPad.Apps.Journal.JournalView.JournalDesign
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Journal.JournalView.JournalDesign.Traditional'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  size: ->
    width: 302
    height: 223

  writingAreaOptions: ->
    left: 20
    top: 20
    width: 120
    height: 180
    gap: 25
    pagesPerViewport: 2
