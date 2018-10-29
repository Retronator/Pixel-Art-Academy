LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary
Nodes = LOI.Adventure.Script.Nodes

class HQ.Store.Table.Item.Quote extends HQ.Store.Table.Item
  @id: -> 'Retronator.HQ.Store.Table.Item.Quote'

  @fullName: -> "quote"

  @initialize()

  descriptiveName: ->
    # Clean up the source name of any html tags.
    name = $("<div>#{@post.quote.source}</div>").text()

    "A ![quote](hear quote) from #{name}."

  description: ->
    "It's something someones once said."

  # Quote completely overrides how to create the interaction script (not just the intro).
  _createInteractionScript: ->
    nodes = []

    nodes.push new Nodes.DialogueLine
      actor: @options.retro
      line: "%%html#{@post.quote.source}html%% once said:"

    $text = $("<div>#{@post.quote.text}</div>")
    $paragraphs = $text.find('p')
    $paragraphs = $text unless $paragraphs.length

    for paragraph in $paragraphs
      nodes.push new Nodes.DialogueLine
        actor: @options.retro
        line: "%%html#{$(paragraph).html()}html%%"

    # Add quotes around the quote part.
    nodes[1].line = "'#{nodes[1].line}"
    nodes[nodes.length - 1].line = "#{nodes[nodes.length - 1].line}'"

    # Link together all nodes.
    node.next = nodes[index + 1] for node, index in nodes

    # Return the start node.
    nodes[0]

  onCommand: (commandResponse) ->
    super arguments...

    quote = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.ListenTo, Vocabulary.Keys.Verbs.Read], quote.avatar]
      action: => quote.start()
