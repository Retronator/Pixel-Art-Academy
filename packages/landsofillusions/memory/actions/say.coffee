LOI = LandsOfIllusions
AM = Artificial.Mummification

Nodes = LOI.Adventure.Script.Nodes
Vocabulary = LOI.Parser.Vocabulary

class LOI.Memory.Actions.Say extends LOI.Memory.Action
  # content:
  #   say: character says something
  #     text: the text being said
  @type: 'LandsOfIllusions.Memory.Actions.Say'
  @register @type, @

  @registerContentPattern @type,
    say:
      text: String

  @activeDescription: ->
    "_They_ _are_ talking."

  createStartScript: (person, nextNode, nodeOptions) ->
    # After the text is delivered, advertise this context.
    callbackNode = new Nodes.Callback
      next: nextNode
      callback: (complete) =>
        complete()

        context = new LOI.Memory.Contexts.Conversation @memory._id

        LOI.adventure.advertiseContext context

    options = _.extend {}, nodeOptions,
      line: @content.say.text
      actor: person
      next: callbackNode
      immediate: true

    # Return the main dialog node.
    new Nodes.DialogueLine options

  onCommand: (person, commandResponse) ->
    # Listening enters you into the context of this conversation.
    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.ListenTo, person.avatar]
      action: =>
        context = new LOI.Memory.Contexts.Conversation @memory._id

        LOI.adventure.enterContext context
