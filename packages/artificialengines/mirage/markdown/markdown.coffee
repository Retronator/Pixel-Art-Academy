AM = Artificial.Mirage

class AM.Markdown extends AM.Component
  @register "Artificial.Mirage.Markdown"

  process: (contentTemplate) ->
    text = Blaze.toHTML contentTemplate

    # Strip leading indentation.
    lines = text.match /^.*$/gm

    # Get all indentation lengths but don't include empty lines.
    indentationLengths = for line in lines when line.length
      trimmedLine = _.trimStart line
      line.length - trimmedLine.length
      
    indentationLength = _.min indentationLengths
    
    # Outdent the lines (negative indent)
    lines = for line in lines
      _.outdent line, indentationLength

    # Return processed lines.
    lines.join '\n'
