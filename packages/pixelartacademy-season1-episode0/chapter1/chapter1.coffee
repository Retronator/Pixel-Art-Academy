LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Season1.Episode0.Chapter1 extends LOI.Adventure.Chapter
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1'

  @sections: -> [
    @Immigration
  ]

  inventory: ->
    @constructor._inventory @

  @_inventory: (chapter) ->
    C0 = PixelArtAcademy.Season1.Episode0.Chapter0
    hasBackpack = C0.Start.Backpack.state 'inInventory'
    backpackOpened = C0.Start.Backpack.state 'opened'

    [
      C0.Start.Backpack if hasBackpack
      C0.Start.Passport if hasBackpack and backpackOpened
      C0.Start.AcceptanceLetter if hasBackpack and backpackOpened
    ]
