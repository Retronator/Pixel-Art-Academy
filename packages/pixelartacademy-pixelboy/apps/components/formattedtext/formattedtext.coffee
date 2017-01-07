AM = Artificial.Mirage
LOI = LandsOfIllusions
LOI = LandsOfIllusions

class LOI.PixelBoy.Apps.Components.FormattedText extends AM.Component
  @register "LandsOfIllusions.PixelBoy.Apps.Components.FormattedText"

  constructor: (@text, @linkColor) ->

  formattedText: ->
    # DANGER ZONE:
    # We are using direct HTML injection with triple braces, i.e. {{{formattedText}}}, so make sure we escape properly.
    div = document.createElement 'div'
    div.appendChild document.createTextNode @text
    escapedText = div.innerHTML

    # Replace urls with links.
    urlRegex = /(https?):\/\/([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:\/~+#-]*[\w@?^=%&\/~+#-])?/g

    formattedText = escapedText.replace urlRegex, (url, protocol, domain, path) =>
      urlText = domain

      if path
        # Make sure the path is not longer than 10 characters.
        path = "/…#{path.substring(path.length-8)}" if path.length > 10

        # Add it to the domain.
        urlText = "#{urlText}#{path}"

      styleTag = if @linkColor then "style='color:##{@linkColor.getHexString()};'" else ''
      "<a href='#{url}' target='_blank' #{styleTag}>#{urlText}</a>"

    formattedText
