AM = Artificial.Mirage

# Helper functions for dealing with HTML.
class AM.HtmlHelper
  # Escape text for direct HTML injection with triple braces, i.e. {{{formattedText}}}.
  @escapeText: (text) ->
    div = document.createElement 'div'
    div.appendChild document.createTextNode text
    div.innerHTML
