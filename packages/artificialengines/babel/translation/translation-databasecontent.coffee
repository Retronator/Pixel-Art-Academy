AE = Artificial.Everywhere
AB = Artificial.Babel
AT = Artificial.Telepathy
AM = Artificial.Mummification

util = require 'util'

# Document that stores the translated texts for a given key in a namespace.
class AB.Translation extends AB.Translation
  @Meta
    name: @id()
    replaceParent: true

  @importDatabaseContent: (arrayBuffer) ->

  exportDatabaseContent: ->
    # See if we have a custom path on the object itself (it would be set manually before exporting).
    if @_databaseContentPath
      path = @_databaseContentPath
      delete @_databaseContentPath

    # See if we have a namespace-key pair.
    else if @namespace and @key
      path = @namespace.toLowerCase().replace /\./g, '/'
      path = "#{path}/#{@key.toLowerCase()}"

    else
      # We can only reference this document by ID so we put it in a common translation folder.
      path = "artificial/babel/translation/#{@_id}"

    # The content is a list of all translations plus the JSON information.
    content = ""

    for translation in @allTranslationData()
      content += "#{translation.languageRegion}: #{translation.translationData.text}\n"

    content += "\n"
    content += EJSON.stringify @

    encoder = new util.TextEncoder
    arrayBuffer = encoder.encode content

    # We don't currently store edit times, so we assume we have the latest translation.
    lastEditTime = new Date()

    arrayBuffer: arrayBuffer
    path: "#{path}.translation.txt"
    lastEditTime: lastEditTime
