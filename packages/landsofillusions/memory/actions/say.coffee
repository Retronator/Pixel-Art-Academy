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
    "_They_ _are_ ![talking](listen to _person_)."

  createStartScript: (person, nextNode, nodeOptions = {}) ->
    text = @content.say.text

    if nodeOptions.background and text.length > 100
      # Shorten the text under 100 characters.
      text = text[..100]
      lastSpace = text.lastIndexOf ' '
      text = "#{text[..lastSpace]}…"

    options = _.extend
      # Say the line immediately by default.
      immediate: true
    ,
      nodeOptions
    ,
      line: text
      actor: person
      next: nextNode

    dialogueNode = new Nodes.DialogueLine options

    # After the text is delivered, advertise this context.
    callbackNode = new Nodes.Callback
      next: dialogueNode
      callback: (complete) =>
        complete()

        # Advertise this action's memory context, unless we're already in a context.
        return if LOI.adventure.currentContext()

        Tracker.autorun (computation) =>
          # Wait for memory to be loaded through the person. It might not be loaded when
          # person immediately executes this action upon being added to the people.
          return unless memory = LOI.Memory.documents.findOne @memory._id
          computation.stop()

          Tracker.nonreactive =>
            context = LOI.Memory.Context.createContext memory
            LOI.adventure.advertiseContext context

    # Return the starting callback node.
    callbackNode

  onCommand: (person, commandResponse) ->
    # Listening enters you into the context of this conversation.
    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.ListenTo, person.avatar]
      action: =>
        # See if we're already in a context.
        context = LOI.adventure.currentContext()

        if context
          # Set the focused memory of the context.
          context.displayMemory @memory._id

        else
          # Display the memory in its context.
          memory = LOI.Memory.documents.findOne @memory._id
          memory.display()
