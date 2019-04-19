LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.CharacterUpdatesHelper
  constructor: ->
    @person = new ReactiveField null

    @agent = new ComputedField =>
      return unless person = @person()
      return unless person instanceof LOI.Character.Agent
      person

    @actionsSubscription = new ComputedField =>
      return unless agent = @agent()
      agent.subscribeRecentActions()

    @memoriesSubscription = new ComputedField =>
      return unless agent = @agent()
      agent.subscribeRecentMemories()

    @ready = new ComputedField =>
      not @agent() or (@actionsSubscription()?.ready() and @memoriesSubscription()?.ready())

  destroy: ->
    @agent.stop()
    @actionsSubscription.stop()
    @memoriesSubscription.stop()
    @ready.stop()
