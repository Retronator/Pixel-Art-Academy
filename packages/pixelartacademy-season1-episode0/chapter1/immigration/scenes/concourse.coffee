LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode0.Chapter1
RS = Retropolis.Spaceport

class C1.Immigration.Concourse extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Immigration.Concourse'

  @location: -> RS.AirportTerminal.Concourse

  @listeners: -> [
    @Listener
  ]

  @initialize()

  things: ->
    [
      C1.Actors.Alex if @state 'alexPresent'
    ]

  class @Listener extends LOI.Adventure.Listener
    @scriptUrls: -> [
      'retronator_pixelartacademy-season1-episode0/chapter1/immigration/scenes/concourse.script'
    ]

    class @Scripts.Concourse extends LOI.Adventure.Script
      @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Immigration.Concourse'
      @initialize()

      initialize: ->

    @initialize()

    onEnter: (enterResponse) ->

    onExitAttempt: (exitResponse) ->

    onExit: (exitResponse) ->
