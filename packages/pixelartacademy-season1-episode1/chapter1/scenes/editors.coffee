LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.Editors extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Editors'

  @location: -> PAA.PixelBoy.Apps.Drawing.Editors

  @initialize()

  constructor: ->
    super

  things: -> [
    PAA.PixelBoy.Apps.Drawing.Editor.Desktop # TODO: if C1.PostPixelBoy.ArtStudio.Listener.Script.state 'ReceiveDesktopEditor'
  ]
