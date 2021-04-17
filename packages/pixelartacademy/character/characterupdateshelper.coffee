LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.CharacterUpdatesHelper
  constructor: ->
    @person = new ReactiveField null

    @agent = new ComputedField =>
      return unless person = @person()
      return unless person instanceof LOI.Character.Agent
      person
    ,
      true

    @actionsSubscription = new ComputedField =>
      return unless agent = @agent()
      agent.subscribeRecentActions true
    ,
      true

    @memoriesSubscription = new ComputedField =>
      return unless agent = @agent()
      agent.subscribeRecentMemories true
    ,
      true

    @tasksSubscription = new ComputedField =>
      return unless agent = @agent()
      agent.subscribeRecentTaskEntries true
    ,
      true

    @ready = new ComputedField =>
      not @agent() or (@actionsSubscription()?.ready() and @memoriesSubscription()?.ready() and @tasksSubscription()?.ready())
    ,
      true

  destroy: ->
    @agent.stop()
    @actionsSubscription.stop()
    @memoriesSubscription.stop()
    @tasksSubscription.stop()
    @ready.stop()
