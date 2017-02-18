LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode0.Chapter1
RS = Retropolis.Spaceport

class C1.Start.Terrace extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Start.Terrace'

  @location: -> RS.AirportTerminal.Terrace

  @translations: ->
    intro: "
      You exit the Retropolis International Spaceport.
      A magnificent view of the city opens before you and you feel the adventure in the air.
      The terrace you're standing on connects back to the airport terminal in the south.
    "

  @initialize()

  things: ->
    [
      C1.Backpack unless C1.Backpack.state 'inInventory'
      C1.Actors.Alex if @state 'alexPresent'
    ]

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode0/chapter1/sections/start/scenes/terrace.script'

  onEnter: (enterResponse) ->
    scene = @options.parent

    # Provide the introduction text the first time we enter.
    introductionDone = scene.state 'introductionDone'

    unless introductionDone
      enterResponse.overrideIntroduction =>
        scene.translations()?.intro

      scene.state 'introductionDone', true

    # Alex should enter after 30s unless they are already present or they have already talked to you.
    unless scene.state('alexPresent') or C1.Actors.Alex.state('firstTalkDone')
      # But wait first that the interface and time is ready.
      @autorun (computation) =>
        return unless LOI.adventure.interface.uiInView()
        return unless time = LOI.adventure.time()
        computation.stop()
        
        @_alexEntersTimeout = Meteor.setTimeout =>
          @startScript label: "AlexEnters"
        ,
          30000
        
        # Also record the adventure time so we have our 10 min countdown for airship departure.
        scene.section.chapter.state 'startTime', time

    # Alex should talk when at location.
    @_alexTalksAutorun = @autorun (computation) =>
      return unless scene.state('alexPresent')

      return unless @scriptsReady()
      return unless alex = LOI.adventure.getCurrentThing C1.Actors.Alex
      return unless alex.ready()
      computation.stop()

      @script.setThings {alex}

      @startScript label: "AlexIsPresent"

  onExitAttempt: (exitResponse) ->
    hasBackpack = C1.Backpack.state 'inInventory'
    return if hasBackpack

    @startScript label: 'LeaveWithoutBackpack'
    exitResponse.preventExit()

  cleanup: ->
    # Stop Alex's timer.
    Meteor.clearTimeout @_alexEntersTimeout

    @_alexTalksAutorun?.stop()

