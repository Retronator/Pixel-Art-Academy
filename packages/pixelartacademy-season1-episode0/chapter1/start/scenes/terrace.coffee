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

  @listenerClasses: -> [
    @Listener
  ]

  @initialize()

  things: ->
    [
      C1.Start.Backpack unless C1.Start.Backpack.state 'inInventory'
      C1.Actors.Alex if @state 'alexPresent'
    ]

  class @Listener extends LOI.Adventure.Listener
    @scriptUrls: -> [
      'retronator_pixelartacademy-season1-episode0/chapter1/start/scenes/terrace.script'
    ]

    class @Scripts.Terrace extends LOI.Adventure.Script
      @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Start.Terrace'
      @initialize()

      initialize: ->
        @setCallbacks
          AlexEnters: (complete) =>
            @options.parent.state 'alexPresent', true
            complete()

          AlexLeaves: (complete) =>
            @options.parent.state 'alexPresent', false
            C1.Actors.Alex.state 'firstTalkDone', true
            complete()

    @initialize()

    onEnter: (enterResponse) ->
      return unless enterResponse.currentLocationClass is @options.parent.constructor.location()

      # Provide the introduction text the first time we enter.
      introductionDone = @options.parent.state 'introductionDone'

      unless introductionDone
        enterResponse.overrideIntroduction =>
          @options.parent.translations().intro

        @options.parent.state 'introductionDone', true

      # Alex should enter after 30s unless he is already present or he has already talked to you.
      unless @options.parent.state('alexPresent') or C1.Actors.Alex.state('firstTalkDone')
        @_alexEntersTimeout = Meteor.setTimeout =>
          LOI.adventure.director.startScript @scripts[@constructor.Scripts.Terrace.id()], label: "AlexEnters"
        ,
          30000

      # Alex should talk when at location.
      @_alexTalksAutorun = @autorun (computation) =>
        return unless @scriptsReady()
        return unless alex = LOI.adventure.getCurrentThing C1.Actors.Alex
        computation.stop()

        script = @scripts[@constructor.Scripts.Terrace.id()]
        script.setActors {alex}

        LOI.adventure.director.startScript script, label: "AlexIsPresent"

    onExitAttempt: (exitResponse) ->
      return unless exitResponse.currentLocationClass is @options.parent.constructor.location()

      hasBackpack = C1.Start.Backpack.state 'inInventory'
      return if hasBackpack

      LOI.adventure.director.startScript @scripts[@constructor.Scripts.Terrace.id()], label: 'LeaveWithoutBackpack'
      exitResponse.preventExit()

    onExit: (exitResponse) ->
      return unless exitResponse.currentLocationClass is @options.parent.constructor.location()

      # Stop Alex's timer if we leave location before they enter.
      Meteor.clearTimeout @_alexEntersTimeout
      @_alexTalksAutorun.stop()
