LOI = LandsOfIllusions
C2 = PixelArtAcademy.Season1.Episode0.Chapter2
HQ = Retronator.HQ
RS = Retronator.Store

class C2.Shopping extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter2.Shopping'

  @scenes: -> [
  ]

  @initialize()

  active: ->
    @requireFinishedSections C2.Intro

  @finished: ->
    # You have to be signed in to complete the shopping section.
    return false unless Meteor.userId()
    
    # Shopping section ends when the user gains player access.
    Retronator.user()?.hasItem RS.Items.CatalogKeys.PixelArtAcademy.PlayerAccess
