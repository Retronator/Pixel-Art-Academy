LOI = LandsOfIllusions
PAA = PixelArtAcademy
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class Soma.Muni.Scene extends LOI.Adventure.Scene
  @id: -> 'SanFrancisco.Soma.Muni.Scene'
  @timelineId: -> PAA.TimelineIds.RealLife

  @location: ->
    # Muni will dynamically come to the current location so we will override it in the instance.
    null

  @initialize()

  @defaultScriptUrl: -> 'retronator_sanfrancisco-soma/muni/scene.script'

  constructor: ->
    super

    @atLocation = new ReactiveField false

    @listener = @listeners[0]

    # Listen to player changing location.
    @autorun (computation) =>
      return unless currentLocation = LOI.adventure.currentLocation()

      Tracker.nonreactive =>
        # Remove the Muni from location.
        @atLocation false

        # Clear any event that was happening with Muni.
        Meteor.clearTimeout @_eventTimeout

        if currentLocation.constructor in [
          Soma.SecondAndKing
          Soma.FourthAndKing
          Soma.MissionRock
          Soma.MissionBay
        ]
          # Come to location in 5 seconds.
          @_scheduleArrival 5000

  _scheduleArrival: (time) ->
    @_eventTimeout = Meteor.setTimeout =>
      @atLocation true
      @listener.startScript label: 'Arrive'

      # Leave after 20 seconds.
      @_eventTimeout = Meteor.setTimeout =>
        @atLocation false
        @listener.startScript label: 'Leave'

        # Come back after 20 seconds.
        @_scheduleArrival 20000
      ,
        20000
    ,
      time

  exits: ->
    "#{Vocabulary.Keys.Directions.In}": Soma.Muni if @atLocation()
