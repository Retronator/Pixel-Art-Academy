AB = Artificial.Base
AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

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
      return unless audioContext = LOI.adventure.audioManager.context()
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

    # Change PixelPad size.
    @autorun (computation) =>
      if @cartridge()
        @setFixedPixelPadSize 320, 157

      else
        @setFixedPixelPadSize 380, 300
    
    # Set/unset cartridge if in play.
    @autorun (computation) =>
      # Depend only on parameters to minimize reactivity.
      cartridgeParameter = AB.Router.getParameter 'parameter3'
      playParameter = AB.Router.getParameter 'parameter4'
      
      Tracker.nonreactive =>
        drawer = @drawer()
        
        if cartridgeParameter and playParameter
          @cartridge drawer.selectedCartridge()
        
        else
          # Turn off the device and deselect the cartridge when returning from play.
          if @cartridge()
            # Wait for the power off animation if needed.
            delay = 0
            device = @device()
  
            if device.powerOn()
              device.powerStop()
              delay = 500
            
            Meteor.setTimeout =>
              @cartridge null
              drawer.deselectCartridge()
            ,
              delay
      
    # Start the device when we have the cartridge.
    @autorun (computation) =>
      return unless cartridge = @cartridge()
      return unless device = @device()
      
      # Load the game non-reactively so that changing of the project ID won't
      # cause a restart (instead we're forcing the player to go out and back in).
      Tracker.nonreactive => device.loadGame cartridge.game(), cartridge.projectId()

      Meteor.clearTimeout @_deviceStartTimeout

      @_deviceStartTimeout = Meteor.setTimeout =>
        device.powerStart()
      ,
        1500
  
  inGameMusicMode: ->
    # Turn off music when viewing the device.
    if AB.Router.getParameter 'parameter4' then LM.Interface.InGameMusicMode.Off else LM.Interface.InGameMusicMode.Direct
    
  cartridgeActiveClass: ->
    'cartridge-active' if @cartridge()
