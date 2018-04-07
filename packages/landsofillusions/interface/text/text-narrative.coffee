AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Interface.Text extends LOI.Interface.Text
  introduction: ->
    location = @location()
    return unless location

    if currentIntroductionFunction = @_currentIntroductionFunction()
      introduction = currentIntroductionFunction()
      return @_formatOutput introduction

    if location.constructor.visited() and not LOI.adventure.currentContext()
      fullName = location.avatar.fullName()
      return unless fullName

      # We've already visited this location so simply return the full name.
      "#{_.upperFirst fullName}."

    else
      # It's the first time we're visiting this location in this session,
      # or we're in a context, so show the full description.
      situation = LOI.adventure.currentSituation()

      @_formatOutput situation.description.last()

  postscript: ->
    location = @location()
    return unless location

    situation = LOI.adventure.currentSituation()

    @_formatOutput situation.postscript.last()

  narrativeLine: ->
    # WARNING: The output of this function should be HTML escaped
    # since the results will be directly injected with triple braces.
    lineText = @currentData()

    @_formatOutput lineText

  dialogueSelectionLine: ->
    dialogueLineOption = @currentData()

    @_formatOutput dialogueLineOption.line

  _formatOutput: (text) ->
    # NOTE: The output of this function is HTML escaped and can be used directly injected with triple braces.
    return unless text

    # We could have direct HTML in the text, so we need to collect it here, to replace it back instead of the escaped
    # versions. We have to trust that the provided HTML is already escaped and malicious free.
    htmlParts = text.match /%%html.*html%%/g

    text = AM.HtmlHelper.escapeText text

    # Replace back the html parts.
    for htmlPart in htmlParts or []
      # Extract the html content with a capture group.
      html = htmlPart.match(/%%html(.*)html%%/)[1]

      # Because we don't use global match flag, replacements will happen one by one in order.
      text = text.replace /%%html.*html%%/, html

    # Create color spans.
    text = text.replace /%%c(\d+)-([-\d]+)%(.*?)c%%/g, (match, hue, shade, text) =>
      hue = parseInt hue
      shade = parseInt shade

      colorHexString = LOI.Avatar.colorObject(hue: hue, shade: shade).getHexString()

      # Link should be 2 shades lighter than the text.
      linkColor = LOI.Avatar.colorObject(hue: hue, shade: shade + 2)
      text = @_formatLinks text, linkColor

      "<span style='color: \##{colorHexString}' data-hue='#{hue}' data-shade='#{shade}'>#{text}</span>"

    # Create text transform spans.
    text = text.replace /%%t([L|U])(.*?)t%%/g, (match, transformType, text) =>
      switch transformType
        when 'L' then transform = 'lowercase'
        when 'U' then transform = 'uppercase'

      "<span style='text-transform: #{transform}'>#{text}</span>"

    # Extract commands from image notation.
    text = text.replace /!\[(.*?)]\((.*?)\)/g, (match, text, command) ->
      command = text unless command.length
      "<span class='command' title='#{command}'>#{text}<span class='underline'></span><span class='background'></span></span>"

    # Replace character pronouns.
    if character = LOI.character()
      text = LOI.Character.formatText text, 'char', character
    
    Tracker.afterFlush =>
      # Add colors to commands.
      commands = @$('.narrative .command')
      return unless commands

      for element in commands
        $command = $(element)
        colorParent = $command.parent('*[data-hue]')

        if colorParent.length
          hue = colorParent.data 'hue'
          shade = colorParent.data 'shade'
          colorHexString = LOI.Avatar.colorObject(hue: hue, shade: shade + 1).getHexString()

          $command.css color: "##{colorHexString}"

          $command.find('.underline').css borderBottomColor: "##{colorHexString}"

          $command.find('.background').css backgroundColor: "##{colorHexString}"

    text

  _formatLinks: (escapedText, linkColor) ->
    # Replace urls with links.
    urlRegex = /(https?):\/\/([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:\/~+#-;]*[\w@?^=%&\/~+#-;])?/g

    formattedText = escapedText.replace urlRegex, (url, protocol, domain, path) =>
      urlText = domain

      if path
        # Make sure the path is not longer than 10 characters.
        path = "/…#{path.substring(path.length-8)}" if path.length > 10

        # Add it to the domain.
        urlText = "#{urlText}#{path}"

      styleTag = if linkColor then "style='color:##{linkColor.getHexString()};'" else ''

      # We must unescape the URL that is used as the attribute.
      url = AM.HtmlHelper.unescapeText url

      "<a href='#{url}' target='_blank' #{styleTag}>#{urlText}</a>"

    formattedText
