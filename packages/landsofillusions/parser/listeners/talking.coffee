AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary
Nodes = LOI.Adventure.Script.Nodes

class LOI.Parser.TalkingListener extends LOI.Adventure.Listener
  onCommandExecuted: (likelyAction) ->
    # React to 'talk to' commands.
    phraseParts = _.flatten likelyAction.phraseAction.form

    talkToPhrasePart = _.find phraseParts, (phrasePart) => phrasePart is Vocabulary.Keys.Verbs.TalkTo
    characterId = LOI.characterId()

    if talkToPhrasePart and characterId
      # Find the other avatar.
      avatarPhrasePart = _.find phraseParts, (phrasePart) => phrasePart instanceof LOI.Avatar or phrasePart instanceof LOI.Adventure.Thing
      if avatarPhrasePart instanceof LOI.Adventure.Thing
        thing = avatarPhrasePart

      else
        avatar = avatarPhrasePart
        thingClass = avatar.thingClass

      targetPersonId = thing?.characterId?() or thing?.constructor.id() or avatar?.characterId?() or thingClass?.id()

      unless targetPersonId
        console.warn "Could not determine target person ID.", phraseParts
        return

      # Create talk memory action.
      type = LOI.Memory.Actions.Talk.type
      situation = LOI.adventure.currentSituationParameters()

      LOI.Memory.Action.do type, characterId, situation,
        person: targetPersonId

  onScriptNodeHandled: (node) ->
    agent = LOI.agent()
    labelNode = node if node instanceof Nodes.Label

    # If this is an End label, this usually indicates end of talking, so we
    # should stop the talking memory action if the agent is performing one.
    if labelNode?.name is 'End' and agent?.action() instanceof LOI.Memory.Actions.Talk
      # Create idle memory action.
      type = LOI.Memory.Actions.Idle.type
      situation = LOI.adventure.currentSituationParameters()

      LOI.Memory.Action.do type, agent._id, situation
