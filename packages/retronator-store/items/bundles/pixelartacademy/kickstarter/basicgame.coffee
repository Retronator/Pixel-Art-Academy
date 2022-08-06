AE = Artificial.Everywhere
RS = Retronator.Store
CatalogKeys = RS.Items.CatalogKeys

class RS.Items.Bundles.PixelArtAcademyKickstarterBasicGame extends RS.Items.Bundles.PixelArtAcademyKickstarterTier
  @type: 'Retronator.Store.Items.Bundles.PixelArtAcademyKickstarterBasicGame'
  @registerType @type, @

  @price: 10

  @create: ->
    super
      catalogKey: CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.BasicGame
      rewardId: 4199759

      name: "Pixel Art Academy Kickstarter tier - THE GAME!"
      description: "Select from one of the pre-made characters and play through storylines, build your library of knowledge, complete assignments and track your art progress once the game launches with Freshman Year 2017. As a Kickstarter backer, your name will be listed in a special section of the Retropolis Academy of Art Yearbook. I will also send you 50 backer updates (about one a week) with news from the development on the way to the release."

      price: @price

      items: [
        CatalogKeys.PixelArtAcademy.PlayerAccess
        CatalogKeys.PixelArtAcademy.FreshmanYear
        CatalogKeys.PixelArtAcademy.SophomoreYear
        CatalogKeys.PixelArtAcademy.JuniorYear
        CatalogKeys.PixelArtAcademy.SeniorYear
        CatalogKeys.PixelArtAcademy.Kickstarter.WhiteKeycard
        CatalogKeys.PixelArtAcademy.Kickstarter.RetropolisAcademyOfArtYearbook
      ]
