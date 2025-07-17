AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PADB = PixelArtDatabase

class PAA.Pico8.Cartridge extends LOI.Adventure.Thing
  @fullName: -> null # Cartridges get named directly from the artwork by default.

  @gameSlug: -> throw new AE.NotImplementedException "A cartridge must provide the game slug."
  @projectClass: -> null # Override to provide the project class if this cartridge can be modified.

  constructor: ->
    super arguments...

    @game = new ComputedField =>
      return unless slug = @constructor.gameSlug()
      PAA.Pico8.Game.forSlug.subscribeContent @, slug

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
      @constructor.projectClass()?.state 'activeProjectId'
    ,
      true

    @imageUrl = new ReactiveField null

    @_imageUrlAutorun = Tracker.autorun =>
      return unless game = @game()

      if projectId = @projectId()
        game.getCartridgeImageUrlForProject(projectId).then (imageUrl) =>
          @imageUrl imageUrl

      else
        @imageUrl game.cartridge.url

  destroy: ->
    super arguments...

    @game.stop()
    @artwork.stop()
    @projectId.stop()
    @_imageUrlAutorun.stop()
  
  startParameter: ->
    # Override what string should be passed on start as a stat(6) parameter.
    ""

  fullName: ->
    @artwork()?.title

  imageUrl: ->
    return unless game = @game()

    game.cartridge.url

  shareUrl: ->
    return unless game = @game()

    AB.Router.createUrl PAA.Pico8.Pages.Pico8.componentName(),
      gameSlug: game.slug
      projectId: @projectId()
    ,
      absolute: true
