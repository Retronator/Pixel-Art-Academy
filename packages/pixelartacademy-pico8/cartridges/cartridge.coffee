AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PADB = PixelArtDatabase

class PAA.Pico8.Cartridges.Cartridge extends LOI.Adventure.Thing
  @fullName: -> null # Cartridges get named directly from the artwork by default.

  @gameSlug: -> throw new AE.NotImplementedException "A cartridge must provide the game slug."
  @projectClass: -> null # Override to provide the project class if this cartridge can be modified.

  constructor: ->
    super arguments...

    @game = new ComputedField =>
      return unless slug = @constructor.gameSlug()
      PAA.Pico8.Game.forSlug.subscribe @, slug

      PAA.Pico8.Game.documents.findOne {slug}
    ,
      true

    @artwork = new ComputedField =>
      return unless artworkId = @game()?.artwork?._id
      PADB.Artwork.forId.subscribe @, artworkId

      PADB.Artwork.documents.findOne artworkId
    ,
      true

    @projectId = new ComputedField =>
      @constructor.projectClass()?.readOnlyState 'activeProjectId'
    ,
      true

  destroy: ->
    super arguments...

    @game.stop()
    @artwork.stop()
    @projectId.stop()

  fullName: ->
    @artwork()?.title

  cartridgeImageUrl: ->
    return unless game = @game()

    if projectId = @projectId()
      # We need to create a modified cartridge PNG with the project's assets.
      Meteor.absoluteUrl "pico8/cartridge.png?gameId=#{game._id}&projectId=#{projectId}"

    else
      # We can use the cartridge PNG directly.
      game.cartridge.url

  shareUrl: ->
    return unless game = @game()

    AB.Router.createUrl PAA.Pico8.Pages.Pico8.componentName(),
      gameSlug: game.slug
      projectId: @projectId()
    ,
      absolute: true
