AE = Artificial.Everywhere
RS = Retronator.Store
CatalogKeys = RS.Items.CatalogKeys

class RS.Items.Bundles.PixelArtAcademyKickstarterFullGame extends RS.Items.Bundles.PixelArtAcademyKickstarterTier
  @type: 'Retronator.Store.Items.Bundles.PixelArtAcademyKickstarterFullGame'
  @registerType @type, @

  @price: 20

  @create: ->
    super
      catalogKey: CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.FullGame
      rewardId: 4291884
      
      name: "Pixel Art Academy Kickstarter tier - YOUR OWN CHARACTER!"
      description: "Start playing once the game launches with Freshman Year 2017. You will be able to create your own character and portrait by choosing and customizing individual parts. The portrait (and your name) will also appear in a special section of the Retropolis Academy of Art Yearbook. I will also send you 50 backer updates with news from the development."

      price: @price

      items: [
        CatalogKeys.PixelArtAcademy.PlayerAccess
        CatalogKeys.PixelArtAcademy.FreshmanYear
        CatalogKeys.PixelArtAcademy.SophomoreYear
        CatalogKeys.PixelArtAcademy.JuniorYear
        CatalogKeys.PixelArtAcademy.SeniorYear
        CatalogKeys.PixelArtAcademy.Kickstarter.YellowKeycard
        CatalogKeys.PixelArtAcademy.Kickstarter.RetropolisAcademyOfArtYearbook
        CatalogKeys.LandsOfIllusions.Character.Avatar.AvatarEditor
        #CatalogKeys.PixelArtAcademy.Steam.LearnMode.DefaultReleaseKey
      ]
