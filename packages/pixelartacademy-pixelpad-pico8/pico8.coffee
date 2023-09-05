AB = Artificial.Babel
AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Pico8 extends PAA.PixelPad.App
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Pico8'
  @url: -> 'pico8'

  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "PICO-8"
  @description: ->
    "
      It's Lexaloffle's fantasy console!
    "

  @storeName: -> "PICO-8 for PixelPad"

  @storeDescription: -> "
    Retronator brings Lexallofle's fantasy console right to your fingertips with the app for PixelPad.
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
    
    # Create the PICO-8 device once audio context is available, so we can route it through the location mixer.
    @autorun (computation) =>
      return unless audioContext = LOI.adventure.interface.audioManager.context()
      computation.stop()
      
      audioOutputNode = AEc.Node.Mixer.getOutputNodeForName 'location', audioContext
      
      @device new PAA.Pico8.Device.Handheld
        audioContext: audioContext
        audioOutputNode: audioOutputNode
        
        # Relay input/output calls to the cartridge.
        onInputOutput: (address, value) =>
          @cartridge().onInputOutput? address, value
        
        # Enable interface when the cartridge is in the device.
        enabled: => @cartridge()

    @autorun (computation) =>
      if @cartridge()
        @setFixedPixelPadSize 320, 157

      else
        @setFixedPixelPadSize 380, 300

    @autorun (computation) =>
      return unless cartridge = @cartridge()

      device = @device()
      
      # Load the game non-reactively so that changing of the project ID won't
      # cause a restart (instead we're forcing the player to go out and back in).
      Tracker.nonreactive => device.loadGame cartridge.game(), cartridge.projectId()

      Meteor.clearTimeout @_deviceStartTimeout

      @_deviceStartTimeout = Meteor.setTimeout =>
        device.powerStart()
      ,
        1500

  onBackButton: ->
    drawer = @drawer()

    if @cartridge()
      @device().powerStop()

      Meteor.setTimeout =>
        @cartridge null
        drawer.deselectCartridge()
      ,
        500

    else if drawer.selectedCartridge()
      drawer.selectedCartridge null
      drawer.audio.caseClose()
    
    else
      return

    # Inform that we've handled the back button.
    true

  cartridgeActiveClass: ->
    'cartridge-active' if @cartridge()
