LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.CharacterUpdatesHelper
  constructor: ->
    @person = new ReactiveField null

    @actionsSubscription = new ComputedField =>
      return unless person = @person()
      person.subscribeRecentActions()

    @memoriesSubscription = new ComputedField =>
      return unless person = @person()
      person.subscribeRecentMemories()

    @ready = new ComputedField =>
      @actionsSubscription()?.ready() and @memoriesSubscription()?.ready()

  destroy: ->
    @actionsSubscription.stop()
    @memoriesSubscription.stop()
    @ready.stop()
