AT = Artificial.Telepathy

class AT.EmailComposer
  constructor: ->
    @text = ""
    @html = "<!DOCTYPE html><html><body>"

  addParagraph: (text) ->

    formattedText = @_formatText text
    @text += "#{formattedText}\n\n"

    html = @_transformTextToHtml text
    @html += "<p>#{html}</p>\n"

  end: ->
    @html += "</body></html>"

  _formatText: (text) ->
    lines = text.split '\n'

    # Wrap lines at 40 characters.
    formattedLines = for line in lines
      words = line.split ' '

      formattedLine = ""
      currentLine = ""

      appendCurrentLine = ->
        formattedLine += "\n" if formattedLine.length
        formattedLine += currentLine

      # Repeat until we run out of words.
      while words.length
        nextWord = words.shift()

        # Always add the first word.
        unless currentLine.length
          currentLine = nextWord
          continue

        # Check if adding to current line would go over 40 characters.
        if currentLine.length + 1 + nextWord.length> 40
          # We need a new line.
          appendCurrentLine()
          currentLine = nextWord
          continue

        currentLine += " #{nextWord}"

      # Add the final line.
      appendCurrentLine()
      formattedLine

    formattedLines.join '\n'

  _transformTextToHtml: (text) ->
    text.replace /\n/g, '<br/>'
