AE = Artificial.Everywhere
RS = Retronator.Store
CatalogKeys = RS.Items.CatalogKeys

class RS.Items.Bundles.PixelArtAcademyKickstarterAlphaAccess extends RS.Items.Bundles.PixelArtAcademyKickstarterTier
  @type: 'Retronator.Store.Items.Bundles.PixelArtAcademyKickstarterAlphaAccess'
  @registerType @type, @
  
  @price: 40

  @create: ->
    super
      catalogKey: CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.AlphaAccess
      rewardId: 4291885
      
      name: "Pixel Art Academy Kickstarter tier - GAME ALPHA!"
      description: "Get access to the alpha version and be part of the Foundation Year 2016, before the game publicly starts with Freshmen Year 2017. You will be able to create your own character and portrait, plus the character will appear in a special Class of 2016 Photo, an epic pixel artwork of the main campus quad with all your Foundation Year classmates. The portrait (and your name) will also appear in the Retropolis Academy of Art Yearbook as one of its first students. I will also send you 50 backer updates introducing new features in the alpha version."

      price: @price

      items: [
        CatalogKeys.PixelArtAcademy.PlayerAccess
        CatalogKeys.PixelArtAcademy.AlphaAccess
        CatalogKeys.PixelArtAcademy.FoundationYear
        CatalogKeys.PixelArtAcademy.FreshmanYear
        CatalogKeys.PixelArtAcademy.SophomoreYear
        CatalogKeys.PixelArtAcademy.JuniorYear
        CatalogKeys.PixelArtAcademy.SeniorYear
        CatalogKeys.PixelArtAcademy.Kickstarter.CyanKeycard
        CatalogKeys.PixelArtAcademy.Kickstarter.RetropolisAcademyOfArtYearbook
        CatalogKeys.PixelArtAcademy.Kickstarter.ClassOf2016Artwork
        CatalogKeys.LandsOfIllusions.Character.Avatar.AvatarEditor
      ]
