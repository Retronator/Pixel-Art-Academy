AE = Artificial.Everywhere
RS = Retronator.Store
CatalogKeys = RS.Items.CatalogKeys

class RS.Items.Bundles.PixelArtAcademyPreOrderAlphaAccessUpgrade extends RS.Items.Bundles.PixelArtAcademyPreorderUpgrade
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
      
      name: "ADD ON: Alpha access with Retropolis Nightlife Pass"
      description: "Only available as a pre-order, get the Retropolis Nightlife Pass together with alpha access."

      price: 20

      items: [
        CatalogKeys.PixelArtAcademy.AlphaAccess
        CatalogKeys.Retropolis.NightlifePass
      ]
