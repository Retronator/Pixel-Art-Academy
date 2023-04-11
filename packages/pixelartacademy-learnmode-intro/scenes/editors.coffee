LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Editors extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Editors'

  @location: -> PAA.PixelBoy.Apps.Drawing.Editors

  @initialize()

  constructor: ->
    super arguments...

  things: -> [
    PAA.PixelBoy.Apps.Drawing.Editor.Desktop
  ]
