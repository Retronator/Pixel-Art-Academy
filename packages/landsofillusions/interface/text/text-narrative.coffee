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

    if location.constructor.visited()
      fullName = location.avatar.fullName()
      return unless fullName

      # We've already visited this location so simply return the full name.
      "#{_.upperFirst fullName}."

    else
      # It's the first time we're visiting this location in this session so show the full description.
      situation = LOI.adventure.currentSituation()

      @_formatOutput situation.description.last()

  narrativeLine: ->
    lineText = @currentData()

    @_formatOutput lineText

  dialogSelectionLine: ->
    dialogLineOption = @currentData()

    @_formatOutput dialogLineOption.line

  _formatOutput: (text) ->
    return unless text

    # WARNING: The output of this function should be HTML escaped
    # since the results will be directly injected with triple braces.
    text = AM.HtmlHelper.escapeText text

    # Create color spans.
    text = text.replace /%%c(\d+)-([-\d]+)%(.*?)c%%/g, (match, hue, shade, text) ->
      hue = parseInt hue
      shade = parseInt shade

      colorHexString = LOI.Avatar.colorObject(hue: hue, shade: shade).getHexString()

      "<span style='color: ##{colorHexString}' data-hue='#{hue}' data-shade='#{shade}'>#{text}</span>"

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
      pronouns = character.avatar.pronouns()

      getPronoun = (key) =>
        LOI.adventure.parser.vocabulary.getPhrases("Pronouns.#{key}.#{pronouns}")?[0]

      text = text.replace /_char_/g, (match) ->
        character.avatar.shortName()

      text = text.replace /_CHAR_/g, (match) ->
        _.toUpper character.avatar.shortName()

      for pronounPair in [
        ['they', 'Subjective']
        ['them', 'Objective']
        ['their', 'Adjective']
        ['theirs', 'Possessive']
      ]
        text = text.replace new RegExp("_(t|T)#{pronounPair[0].substring(1)}_", 'g'), (match, pronounCase) ->
          pronoun = getPronoun pronounPair[1]

          if pronounCase is 'T' then pronoun = _.upperFirst pronoun

          pronoun

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
