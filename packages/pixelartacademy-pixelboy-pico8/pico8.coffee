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
    super arguments...

    @resizable false

    @drawer = new ReactiveField null
    @device = new ReactiveField null

    @cartridge = new ReactiveField null

  onCreated: ->
    super arguments...

    @drawer new @constructor.Drawer @
    @device new PAA.Pico8.Device.Handheld
      # Relay input/output calls to the cartridge.
      onInputOutput: (address, value) =>
        @cartridge().onInputOutput? address, value

    @autorun (computation) =>
      if @cartridge()
        @setFixedPixelBoySize 320, 157

      else
        @setFixedPixelBoySize 380, 300

    @autorun (computation) =>
      return unless cartridge = @cartridge()

      device = @device()
      device.loadGame cartridge.game(), cartridge.projectId()

      Meteor.setTimeout =>
        device.start()
      ,
        1500

  onBackButton: ->
    drawer = @drawer()

    if @cartridge()
      @device().stop()

      Meteor.setTimeout =>
        @cartridge null
        drawer.deselectCartridge()
      ,
        500

    else if drawer.selectedCartridge()
      drawer.selectedCartridge null

    else
      return

    # Inform that we've handled the back button.
    true

  cartridgeActiveClass: ->
    'cartridge-active' if @cartridge()
