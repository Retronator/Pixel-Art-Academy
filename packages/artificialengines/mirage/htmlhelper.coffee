AM = Artificial.Mirage

# Helper functions for dealing with HTML.
class AM.HtmlHelper
  # Escape text for direct HTML injection with triple braces, i.e. {{{formattedText}}}.
  @escapeText: (text) ->
    div = document.createElement 'div'
    div.appendChild document.createTextNode text
    div.innerHTML

  @unescapeText: (text) ->
    document = new DOMParser().parseFromString text, 'text/html'
    document.documentElement.textContent
