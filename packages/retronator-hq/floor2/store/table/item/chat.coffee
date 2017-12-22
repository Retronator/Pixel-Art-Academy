LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary
Nodes = LOI.Adventure.Script.Nodes

class HQ.Store.Table.Item.Chat extends HQ.Store.Table.Item
  @id: -> 'Retronator.HQ.Store.Table.Item.Chat'

  @fullName: -> "conversation"

  @initialize()

  descriptiveName: ->
    if @post.title
      "A ![conversation](listen to conversation) labeled as #{@post.title}."

    else
      "An interesting ![conversation](listen to conversation)."

  description: ->
    "A couple people are talking about something."

  # Chat completely overrides how to create the interaction script (not just the intro).
  _createInteractionScript: ->
    nodes = []
    
    for dialogueLine in @post.dialogue
      nodes.push new Nodes.DialogueLine
        actor: dialogueLine.name
        line: dialogueLine.phrase

    # Link together all nodes.
    node.next = nodes[index + 1] for node, index in nodes

    # Return the start node.
    nodes[0]

  onCommand: (commandResponse) ->
    super

    audio = @options.parent

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.ListenTo, audio.avatar]
      action: => audio.start()
