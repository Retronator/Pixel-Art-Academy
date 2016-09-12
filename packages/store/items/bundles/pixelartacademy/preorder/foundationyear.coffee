AE = Artificial.Everywhere
RS = Retronator.Store
CatalogKeys = RS.Items.CatalogKeys

class RS.Items.Bundles.PixelArtAcademyPreOrderFoundationYearUpgrade extends RS.Items.Bundles.PixelArtAcademyPreorderUpgrade
  @type: 'Retronator.Store.Items.Bundles.PixelArtAcademyPreOrderFoundationYearUpgrade'
  @register @type, @

  @eligiblePrerequisiteItems: [
    CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.BasicGame
    CatalogKeys.Bundles.PixelArtAcademy.PreOrder.BasicGame
    CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.FullGame
    CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.EarlyFullGame
    CatalogKeys.Bundles.PixelArtAcademy.PreOrder.FullGame
  ]

  @create: ->
    super
      catalogKey: CatalogKeys.Bundles.PixelArtAcademy.PreOrder.FoundationYearUpgrade
      
      name: "ADD ON: Foundation Year (alpha access) with Retropolis Nightlife Pass"
      description: "Only available as a pre-order, get the Retropolis Nightlife Pass together with access to the alpha version in 2016."

      price: 20

      items: [
        CatalogKeys.PixelArtAcademy.FoundationYear
        CatalogKeys.PixelArtAcademy.AlphaAccess
        CatalogKeys.Retropolis.NightlifePass
      ]
