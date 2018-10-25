LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.Pico8Cartridges extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Pico8Cartridges'

  @location: -> PAA.Pico8.Cartridges

  @initialize()

  constructor: ->
    super arguments...

  things: ->
    cartridges = [
      PAA.Pico8.Cartridges.Snake if C1.AdmissionProjects.Snake.Intro.Coworking.Listener.Script.state 'ReceiveCartridge'
    ]

    obtainableCartridges = []

    for cartridgeClass in obtainableCartridges
      hasCartridge = cartridgeClass.state 'inInventory'
      cartridges.push cartridgeClass if hasCartridge

    cartridges
