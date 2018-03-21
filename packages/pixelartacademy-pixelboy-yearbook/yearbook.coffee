AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Yearbook extends PAA.PixelBoy.App
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Yearbook'
  @url: -> 'yearbook'

  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Yearbook"
  @description: ->
    "
      Learn about your classmates at the Academy.
    "

  @initialize()

  constructor: ->
    super

    @setFixedPixelBoySize 384, 274

    @front = new ReactiveField null
    @middle = new ReactiveField null

    @showFront = new ReactiveField true

  onCreated: ->
    super

    @front new @constructor.Front @
    @middle new @constructor.Middle @
