LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode0.Chapter1

class C1.Inventory extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Inventory'
  @location: -> LOI.Adventure.Inventory

  @initialize()

  things: ->
    hasBackpack = C1.Items.Backpack.state 'inInventory'
    backpackOpened = C1.Items.Backpack.state 'opened'

    hasSuitcase = C1.Items.Suitcase.state 'inInventory'

    [
      C1.Items.Backpack if hasBackpack
      C1.Items.Passport if hasBackpack and backpackOpened
      C1.Items.AcceptanceLetter if hasBackpack and backpackOpened
      C1.Items.Suitcase if hasSuitcase
    ]
