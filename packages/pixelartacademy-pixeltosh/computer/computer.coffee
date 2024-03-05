AB = Artificial.Base
AM = Artificial.Mirage
AC = Artificial.Control
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Computer extends LOI.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Computer'
  @register @id()

  @version: -> '0.1.0'
  
  constructor: (@os) ->
    super arguments...
