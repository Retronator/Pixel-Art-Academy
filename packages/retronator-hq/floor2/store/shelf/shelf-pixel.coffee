AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

class HQ.Store.Shelf.Pixel extends HQ.Store.Shelf
  @id: -> 'Retronator.HQ.Store.Shelf.Pixel'
  @url: -> 'retronator/store/pixel'

  @register @id()

  @version: -> '0.0.1'

  @fullName: -> "Pixel computers shelf"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

  @description: ->
    "
      This shelf holds devices from Pixel, the Retropolis computer company.
    "

  @initialize()

  things: -> [
    PixelArtAcademy.PixelBoy
  ]
