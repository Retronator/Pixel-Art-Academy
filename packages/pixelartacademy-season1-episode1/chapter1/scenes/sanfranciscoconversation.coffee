LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ
SF = SanFrancisco

Vocabulary = LOI.Parser.Vocabulary

class C1.SanFranciscoConversation extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.SanFranciscoConversation'

  @location: ->
    # Applies to all locations, but has filtering to match only SF regions.
    null

  @initialize()

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/scenes/sanfranciscoconversation.script'

  constructor: ->
    super arguments...

    # Subscribe to everyone's journals.
    @_journalsSubscriptionAutorun = Tracker.autorun =>
      agents = _.filter LOI.adventure.currentLocationThings(), (thing) => thing instanceof LOI.Character.Agent
      characterIds = (agent._id for agent in agents)

      PAA.Practice.Journal.forCharacterIds.subscribe characterIds

  destroy: ->
    super arguments...

    @_journalsSubscriptionAutorun.stop()

  startMainQuestionsWithAgent: (agent) ->
    @_prepareScriptForAgent agent

    script = @listeners[0].script
    LOI.adventure.director.startScript script, label: 'MainQuestions'

  _prepareScriptForAgent: (agent) ->
    script = @listeners[0].script

    # Replace the agent with target character.
    script.setThings {agent}

    # Prepare an ephemeral object for this agent (we need it to be unique for the current agent).
    ephemeralAgents = script.ephemeralState('agents') or {}
    ephemeralAgents[agent._id] ?= {}
    ephemeralAgent = ephemeralAgents[agent._id]

    journals = PAA.Practice.Journal.documents.fetch
      'character._id': agent._id
    ,
      sort:
        order: 1

    _.extend ephemeralAgent,
      journalIds: (journal._id for journal in journals)

    script.ephemeralState 'agents', ephemeralAgents
    script.ephemeralState 'agent', ephemeralAgent

  # Script

  initializeScript: ->
    @setCallbacks
      Journal: (complete) =>
        complete()

        agent = @ephemeralState 'agent'
        journalId = agent.journalIds[0]

        # Create the journal view context and enter it.
        context = new PAA.PixelBoy.Apps.Journal.JournalView.Context {journalId}
        LOI.adventure.enterContext context

  # Listener

  onCommand: (commandResponse) ->
    # This conversation only applies to SF regions.
    regions = [
      SF.Soma
      SF.C3
      HQ
      HQ.LandsOfIllusions
      HQ.Residence
    ]

    regionIds = (region.id() for region in regions)

    location = LOI.adventure.currentLocation()
    return unless location.region().id() in regionIds
    
    agents = _.filter LOI.adventure.currentLocationThings(), (thing) => thing instanceof LOI.Character.Agent
    characterId = LOI.characterId()

    scene = @options.parent

    for agent in agents when agent._id isnt characterId
      do (agent) =>
        commandResponse.onPhrase
          form: [Vocabulary.Keys.Verbs.TalkTo, agent.avatar]
          action: =>
            scene._prepareScriptForAgent agent
            @startScript()
