AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Pico8 extends PAA.PixelBoy.App
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Pico8'
  @url: -> 'pico8'

  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "PICO-8"
  @description: ->
    "
      It's Lexaloffle's fantasy console!
    "

  @storeName: -> "PICO-8 for PixelBoy"

  @storeDescription: -> "
    Retronator brings Lexallofle's fantasy console right to your fingertips with the app for PixelBoy.
    The bright magenta case complements the playfulness of PICO-8 games and makes sure the fantasy becomes a reality.
  "

  @initialize()

  constructor: ->
    super

    @resizable false

    @drawer = new ReactiveField null
    @cart = new ReactiveField null

  onCreated: ->
    super

    @drawer new @constructor.Drawer @

    @autorun (computation) =>
      if @cart()
        @setFixedPixelBoySize 320, 155

      else
        @setFixedPixelBoySize 380, 300
