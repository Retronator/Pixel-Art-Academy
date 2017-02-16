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
      C1.Actors.Alex unless @state 'alexLeft'
    ]

  class @Listener extends LOI.Adventure.Listener
    @scriptUrls: -> [
      'retronator_pixelartacademy-season1-episode0/chapter1/immigration/scenes/concourse.script'
    ]

    class @Scripts.Concourse extends LOI.Adventure.Script
      @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Immigration.Concourse'
      @initialize()

    @initialize()

    onEnter: (enterResponse) ->
      # Alex should talk when at location.
      @_alexTalksAutorun = @autorun (computation) =>
        return if @options.parent.state('alexLeft')

        return unless @scriptsReady()
        return unless alex = LOI.adventure.getCurrentThing C1.Actors.Alex
        return unless alex.ready()
        computation.stop()

        script = @scripts[@constructor.Scripts.Concourse.id()]
        script.setThings {alex}

        LOI.adventure.director.startScript script, label: "AlexTalks"

    cleanup: ->
      @_alexTalksAutorun?.stop()
