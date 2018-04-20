AE = Artificial.Everywhere
LOI = LandsOfIllusions
HQ = Retronator.HQ

Nodes = LOI.Adventure.Script.Nodes

class HQ.Store.Table.Item extends HQ.Store.Table.Item
  _createTextScript: ->
    nodes = @_createInteractionScriptNodes @post.text
    
    # Link nodes to construct the script chain.
    for node, index in nodes
      node.next = nodes[index + 1]

    # Return the start node.
    _.first nodes

  _createInteractionScriptNodes: (postText) ->
    nodes = []
    retro = @options.retro

    for postPart in $(postText)
      lastNode = _.last nodes

      tag = postPart.tagName?.toLowerCase()

      # Skip comments (<!-- more --> and such).
      continue unless tag

      $postPart = $(postPart)

      if tag is 'p' or tag is 'figure'
        $image = $postPart.find('img')

        if $postPart.data('provider') is 'youtube'
          $youtube = $postPart.find('iframe')

        else
          $youtube = null

        if $image.length > 0
          if lastNode instanceof Nodes.DialogueLine
            # Previous node was Retro talking, so make the narration before showing the image.
            line = lastNode.line

            # Replace colon with ellipsis. Note that the line is ending with html%%.
            line = line.replace ':html%%', ' …html%%'

            lastNode.line = line

            nodes.push new Nodes.NarrativeLine
              line: "Retro shows you an image:"

          # Create the photos html.
          imageSource = $image.attr('src')
          $photo = $("<img class='photo' src='#{imageSource}'>")

          if lastNode.$photos
            # Previous node was the image interaction, so we should just append this photo to it.
            lastNode.$photos.append($photo)
            lastNode.line = "%%html#{lastNode.$photos[0].outerHTML}html%%"

            # Pluralize the narration text.
            secondToLastNode = nodes[nodes.length - 2]
            secondToLastNode.line = "Retro shows you some images:" if secondToLastNode instanceof Nodes.NarrativeLine

          else
            # This is a new image interaction.
            $photos = $('<div class="retronator-hq-store-table-item-photos">')
            $photos.append($photo)

            # We inject the html with the photos.
            photosNode = new Nodes.NarrativeLine
              line: "%%html#{$photos[0].outerHTML}html%%"
              scrollStyle: LOI.Interface.Components.Narrative.ScrollStyle.Top

            photosNode.$photos = $photos

            nodes.push photosNode

        else if $youtube?.length > 0
          if lastNode instanceof Nodes.DialogueLine
            # Previous node was Retro talking, so make the narration before showing the video.
            line = lastNode.line

            # Replace colon with ellipsis. Note that the line is ending with html%%.
            line = line.replace ':html%%', ' …html%%'

            lastNode.line = line

            nodes.push new Nodes.NarrativeLine
              line: "Retro shows you a video:"

          $youtube.addClass('retronator-hq-store-table-item-video')
          html = $postPart.html()

          # Inject html directly into the dialog line.
          nodes.push new Nodes.NarrativeLine
            line: "%%html#{html}html%%"
            scrollStyle: LOI.Interface.Components.Narrative.ScrollStyle.Top

        else
          html = $postPart.html().replace(/&nbsp;/g, ' ').replace(/<br>/g, '').trim()

          # Filter empty paragraphs.
          continue unless html.length

          # Inject html directly into the dialog line.
          nodes.push new Nodes.DialogueLine
            actor: retro
            line: "%%html#{html}html%%"

      else if tag is 'ul' or tag is 'ol'
        html = $postPart.html()

        nodes.push new Nodes.DialogueLine
          actor: retro
          line: "%%html#{html}html%%"

      else if tag is 'blockquote'
        nodes.push new Nodes.DialogueLine
          actor: retro
          line: "%%html#{$postPart[0].outerHTML}html%%"

      else
        console.warn "Not sure how to display post part", $postPart, "with tag", tag

    # Return the created nodes.
    nodes
