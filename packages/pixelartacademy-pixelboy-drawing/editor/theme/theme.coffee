AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing.Editor.Theme extends LOI.Adventure.Thing
  @styleClass: -> throw new AE.NotImplementedException "Theme must provide a style class name."
    
  constructor: (@editor) ->
    super
