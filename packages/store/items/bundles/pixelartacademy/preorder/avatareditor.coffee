AE = Artificial.Everywhere
RS = Retronator.Store
CatalogKeys = RS.Items.CatalogKeys

class RS.Items.Bundles.PixelArtAcademyPreOrderAvatarEditorUpgrade extends RS.Items.Bundles.PixelArtAcademyPreorderUpgrade
  @type: 'Retronator.Store.Items.Bundles.PixelArtAcademyPreOrderAvatarEditorUpgrade'
  @register @type, @

  @eligiblePrerequisiteItems: [
    CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.BasicGame
    CatalogKeys.Bundles.PixelArtAcademy.PreOrder.BasicGame
  ]

  @create: ->
    super
      catalogKey: CatalogKeys.Bundles.PixelArtAcademy.PreOrder.AvatarEditorUpgrade
      
      name: "ADD ON: Avatar editor upgrade with Retropolis Day Pass"
      description: "Only available as a pre-order, get a Retropolis Day Pass together with the character editor. This is a good way to get the full game features if you only have the basic game."

      price: 10

      items: [
        CatalogKeys.LandsOfIllusions.Character.Avatar.AvatarEditor
        CatalogKeys.Retropolis.DayPass
      ]
