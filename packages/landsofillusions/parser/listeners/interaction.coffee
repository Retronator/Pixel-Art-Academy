AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary
Verbs = Vocabulary.Keys.Verbs
Nodes = LOI.Adventure.Script.Nodes

class LOI.Parser.InteractionListener extends LOI.Adventure.Listener
  onCommandExecuted: (likelyAction) ->
    # React to commands that interact with items.
    phraseParts = _.flatten likelyAction.phraseAction.form

    interactionVerbs = [
      Verbs.Use
      Verbs.Press
      Verbs.Read
      Verbs.Get
      Verbs.Open
      Verbs.Close
      Verbs.Buy
    ]

    interactionPhrasePart = _.find phraseParts, (phrasePart) => phrasePart in interactionVerbs
    characterId = LOI.characterId()

    if interactionPhrasePart and characterId
      # Find the other avatar.
      avatarPhrasePart = _.find phraseParts, (phrasePart) => phrasePart instanceof LOI.Avatar or phrasePart instanceof LOI.Adventure.Thing
      if avatarPhrasePart instanceof LOI.Adventure.Thing
        thing = avatarPhrasePart

      else
        avatar = avatarPhrasePart
        thingClass = avatar.thingClass

      targetId = thing?.constructor.id() or thingClass?.id()

      unless targetId
        console.warn "Could not determine target ID.", phraseParts
        return

      # If the thing is one of the things on the location, create a move action.
      type = LOI.Memory.Actions.Move.type
      situation = LOI.adventure.currentSituationParameters()

      return unless targetThing = LOI.adventure.getCurrentLocationThing targetId

      LOI.Memory.Action.do type, characterId, situation,
        landmark: targetThing.constructor.id()
