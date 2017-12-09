LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary
Nodes = LOI.Adventure.Script.Nodes

class HQ.Store.Table.Item.Article extends HQ.Store.Table.Item
  @id: -> 'Retronator.HQ.Store.Table.Item.Article'

  @fullName: -> "article"

  @initialize()

  fullName: ->
    # Use the post title as the full name.
    @post.title

  shortName: ->
    # Retain the original short name.
    @constructor.fullName()

  descriptiveName: ->
    "An ![article](read article) titled #{@post.title}."

  description: ->
    "It's an article."

  # Article completely overrides how to create the interaction script (not just the intro).
  _createInteractionScript: ->
    introNodes = []
    outroNodes = []

    # Figure out the author.
    if @post.reblog
      attribution = "reblogged from"
      author = "<a href='#{@post.reblog.root.url}' target='_blank'>#{@post.reblog.root.title}</a>"

    else
      if 'Guest Blog' in @post.tags
        attribution = "guest blog by"
        author = "Sarah 'Burra' Burrough" if 'Burra' in @post.tags
        author = "Benjamin Asl" if 'Benjamin Asl' in @post.tags

      else
        attribution = "by"
        author = "Matej 'Retro' Jan"

    date = @post.time.toLocaleString Artificial.Babel.currentLanguage(),
      month: 'long'
      day: 'numeric'
      year: 'numeric'

    # Create the article html. If there is a block quote at the start or the end, it's converted into narration.
    $article = $('<div class="retronator-hq-store-table-item-article">')
    $article.append("""
      <h1 class="title">#{@post.title}</h1>
      <h2 class="byline">
        <span class="attribution">#{attribution}</span>
        <span class="author">#{author}</span>, #{date}
      </h2>
    """)

    $content = $('<div>')
    $content.append(@post.text)

    if @post.reblog
      # Reblog posts have a main blockquote that inclodes the source article. Everything before and after
      # the blog post should be turned into flavor text, following the normal conversion method.

      foundBlockquote = false

      $children = $content.children()

      for child, index in $children
        isBlockquote = child.nodeName is 'BLOCKQUOTE'
        isNextBlockquote = $children[index + 1]?.nodeName is 'BLOCKQUOTE'

        if foundBlockquote
          # Add the node to the outro.
          outroNodes = outroNodes.concat @_createInteractionScriptNodes child.outerHTML

        else
          if isBlockquote
            # We found the blockquote.
            $article.append(child.innerHTML)
            foundBlockquote = true

          else unless isNextBlockquote
            # Add the node to the intro.
            introNodes = introNodes.concat @_createInteractionScriptNodes child.outerHTML

    else
      processFlavorText = ($element, nodes) ->
        if $element[0].nodeName is 'BLOCKQUOTE'
          # Flavor text will be encapsulated in a bold+italic combo.
          foundBoldItalic = false

          for paragraph in $element.find('p')
            # Remove bold+italic combos.
            $paragraph = $(paragraph)

            $boldItalic = $paragraph.find('b > i').add($paragraph.find('i > b'))

            if $boldItalic.length
              foundBoldItalic = true

            else
              continue

            # Try to unwap the children nodes (this will not work when there are no children).
            $boldItalic.children().unwrap().unwrap()

            # See if the previous method failed. In that case its contents is pure text, so we can directly unwrap it.
            if $boldItalic.length > 0 and $boldItalic[0].childNodes.length > 0
              paragraphContent = $boldItalic.text()

            else
              paragraphContent = $paragraph.html()

            # Split narrative into lines.
            paragraphLines = paragraphContent.split(/<br\/?>/i)

            # Take non-empty lines.
            paragraphLines = _.filter paragraphLines, (paragraphLine) ->
              paragraphLine.trim().length

            for paragraphLine in paragraphLines
              # When lines start with a (em)dash or >, we have a choice node.
              if match = paragraphLine.match /^(?:[-—>]|&gt;)\s*(.*)/
                # We create a choice node with the given text (dialog node). The next property of the last
                # dialog node will be linked later so that the last choice always continues the flow.
                nodes.push new Nodes.Choice
                  node: new Nodes.DialogueLine
                    line: match[1]

              else
                nodes.push new Nodes.NarrativeLine
                  line: "%%html#{paragraphLine}html%%"

          $element.remove() if foundBoldItalic

      # Process first and last child.
      $children = $content.children()
      processFlavorText $children.eq(0), introNodes
      processFlavorText $children.eq(-1), outroNodes

      $article.append $content.html()

    # We inject the html with the article.
    articleNode = new Nodes.NarrativeLine
      line: "%%html#{$article[0].outerHTML}html%%"
      scrollStyle: LOI.Interface.Components.Narrative.ScrollStyle.Top

    # If no other intro was created, user looks at the article.
    unless introNodes.length
      introNodes.push new Nodes.NarrativeLine
        line: "You read the article:"
        next: articleNode

    # Link together all nodes.
    nodes = [introNodes..., articleNode, outroNodes...]
    for node, index in nodes
      node.next = nodes[index + 1]

      # Also link the last choice node's consequence (embedded node's next) to the next non-choice node.
      if (node instanceof Nodes.Choice) and not (node.next instanceof Nodes.Choice)
        node.node.next = node.next

    # Return the start node.
    nodes[0]

  onCommand: (commandResponse) ->
    super

    article = @options.parent

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Read, article.avatar]
      action: => article.start()
