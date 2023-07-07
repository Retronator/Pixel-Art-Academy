AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

class HQ.Store.Shelf.Pico8 extends HQ.Store.Shelf
  @id: -> 'Retronator.HQ.Store.Shelf.Pico8'
  @url: -> 'retronator/store/pico8'

  @register @id()

  @version: -> '0.0.1'

  @fullName: -> "PICO-8 shelf"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

  @description: ->
    "
      The shelf dedicated to PICO-8.
    "

  @initialize()

  things: -> [
    PixelArtAcademy.PixelPad.Apps.Pico8
    PixelArtAcademy.Pico8.DevKit
    PixelArtAcademy.Pico8.Fanzine
  ]

  canBuyFromShelf: -> LOI.characterId()
