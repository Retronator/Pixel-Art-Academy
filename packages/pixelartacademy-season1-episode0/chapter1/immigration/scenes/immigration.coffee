LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode0.Chapter1
RS = Retropolis.Spaceport

class C1.Immigration.Immigration extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Immigration.Immigration'

  @location: -> RS.AirportTerminal.Immigration

  @listeners: -> [
    @Listener
  ]

  @translations: ->
    intro: "You line up in the queue and wait for your turn at one of the automated immigration checkpoints."

  @initialize()

  onEnter: (enterResponse) ->
    enterResponse.overrideIntroduction =>
      @options.parent.translations()?.intro
