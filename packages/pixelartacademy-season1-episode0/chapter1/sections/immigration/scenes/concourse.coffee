LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode0.Chapter1
RS = Retropolis.Spaceport

class C1.Immigration.Concourse extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Immigration.Concourse'

  @location: -> RS.AirportTerminal.Concourse

  @intro: -> "
    The airport terminal is small and cozy with only a few dozen
    people heading from airplanes towards immigration in the east.
  "

  @initialize()

  things: ->
    [
      C1.Actors.Alex unless @state 'alexLeft'
    ]

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode0/chapter1/sections/immigration/scenes/concourse.script'

  onEnter: (enterResponse) ->
    # Alex should talk when at location.
    @_alexTalksAutorun = @autorun (computation) =>
      return if @options.parent.state('alexLeft')

      return unless @scriptsReady()
      return unless alex = LOI.adventure.getCurrentThing C1.Actors.Alex
      return unless alex.ready()
      computation.stop()

      @script.setThings {alex}

      @startScript label: "AlexTalks"

  cleanup: ->
    @_alexTalksAutorun?.stop()
