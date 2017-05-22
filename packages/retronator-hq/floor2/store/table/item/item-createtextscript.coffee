AE = Artificial.Everywhere
LOI = LandsOfIllusions
HQ = Retronator.HQ

Nodes = LOI.Adventure.Script.Nodes

class HQ.Store.Table.Item extends HQ.Store.Table.Item
  _createTextScript: ->
    nodes = []
    retro = @options.retro

    for postPart in $(@post.text)
      lastNode = _.last nodes

      tag = postPart.tagName
      $postPart = $(postPart)

      if tag.toLowerCase() is 'p' or tag.toLowerCase() is 'figure'
        $image = $postPart.find('img')
        $youtube = $postPart.find('#youtube_iframe')

        if $image.length > 0
          createPhoto = =>
            imageSource = $image.attr 'src'

            imageWidth = $image.data 'orig-width'
            imageHeight = $image.data 'orig-height'

            if imageWidth is 540
              imageSource = imageSource.replace '500.', '540.'

            [
              original_size:
                url: imageSource
                width: imageWidth
                height: imageHeight
            ]

          if lastNode instanceof Nodes.DialogLine
            # Previous node was Retro talking, so make the narration before showing the image.
            line = lastNode.line

            # Replace colon with ellipsis.
            if line.slice(-1) is ':'
              line = line.slice(0, html.length - 1) + '…'

            line += '"'

            lastNode.line = line

            nodes.push new Nodes.NarrativeLine
              line: "Retro shows you an image:"

          if lastNode.imageInteraction
            # Previous node was the image interaction, so we should just append this photo to its photo array.
            lastNode.imageInteraction.addPhoto createPhoto()

            # Also pluralize the narration text.
            secondToLastNode = lastNode[lastNode.length - 2]
            if secondToLastNode instanceof Nodes.DialogLine
              secondToLastNode.line = "Retro shows you some images:"

          else
            # This is a new image interaction.
            imageInteraction = new HQ.Store.Table.Interaction.Photos [
              original_size:
                url: $image.attr 'src'
            ]

            imageInteractionNode = new Nodes.Callback
              callback: (complete) =>
                imageInteraction.start justActivate: true
                complete()

            imageInteractionNode.imageInteraction = imageInteraction

            nodes.push imageInteractionNode

        else if $youtube.length > 0
          ###
          if lastParagraphType is 'text'
            $last = $('#post p').last()
            html = $last.html()
            # Replace colon with ellipsis.
            if html.slice(-1) is ':'
              html = html.slice(0, html.length - 1) + '…'
            html += '"'
            $last.html html
            $('#post').append '<p>Retro shows you a video:</p>'
            lastParagraphType = 'video'
          $youtube = $(this).find('#youtube_iframe')
          youtubeSource = $youtube.attr('src')
          $('#post').append '<div class="video-player-placeholder" src="' + youtubeSource + '"></div>'
          ###

        else
          html = $postPart.html()

          # Filter empty paragraphs.
          continue unless html.length

          # Inject html directly into the dialog line.
          nodes.push new Nodes.DialogLine
            actor: retro
            line: "%%html#{html}html%%"

      else
        console.warn "Not sure how to display post part", $postPart, "with tag", tag

    # Link post nodes in reverse to construct the script chain.
    for node, index in nodes[..-1]
      node.next = nodes[index + 1]

    # Return the start node.
    _.first nodes
