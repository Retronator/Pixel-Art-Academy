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
        # Clear any event that was happening with Muni.
        Meteor.clearTimeout @_eventTimeout

        # Add or remove the Muni from location
        if currentLocation.id() is Soma.Muni.getLocation()?.id()
          @atLocation true

          @_scheduleDeparture 5000

        else
          @atLocation false

          # Move train from whatever station it was so it doesn't appear there if we return.
          Soma.Muni.setLocation null unless currentLocation instanceof Soma.Muni

          if currentLocation.constructor in [
            Soma.MosconeStation
            Soma.FourthAndKing
            Soma.MissionRock
            Soma.MissionBay
          ]
            # Come to location in 3 seconds.
            @_scheduleArrival 3000

  destroy: ->
    super

    Meteor.clearTimeout @_eventTimeout

  _scheduleArrival: (time) ->
    @_eventTimeout = Meteor.setTimeout =>
      @atLocation true
      @listener.startScript label: 'Arrive'
      Soma.Muni.setLocation LOI.adventure.currentLocation()

      # Leave after 20 seconds.
      @_scheduleDeparture 20000
    ,
      time

  _scheduleDeparture: (time) ->
    # Leave after 20 seconds.
    @_eventTimeout = Meteor.setTimeout =>
      @atLocation false
      @listener.startScript label: 'Leave'
      Soma.Muni.setLocation null

      # Come back after 20 seconds.
      @_scheduleArrival 20000
    ,
      time

  exits: ->
    "#{Vocabulary.Keys.Directions.In}": Soma.Muni if @atLocation()
