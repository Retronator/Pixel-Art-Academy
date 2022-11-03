LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.Editors extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Editors'

  @location: -> PAA.PixelBoy.Apps.Drawing.Editors

  @initialize()

  constructor: ->
    super arguments...

  things: -> [
    PAA.PixelBoy.Apps.Drawing.Editor.Desktop if C1.PostPixelBoy.PixelArt.Listener.Script.state 'ReceiveDesktopEditor'
    PAA.PixelBoy.Apps.Drawing.Editor.Easel if HQ.ArtStudio.Alexandra.Listener.Script.state 'ReceiveEaselEditor'
  ]
