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
    decoder = new util.TextDecoder
    content = decoder.decode arrayBuffer

    # The last line will have JSON content.
    lines = content.split '\n'
    EJSON.parse _.last lines

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

    # Add last edit time if needed so that documents don't need unnecessary imports.
    @lastEditTime ?= new Date()

    # The content is a list of all translations plus the JSON information.
    content = ""

    for translation in @allTranslationData()
      content += "#{translation.languageRegion}: #{translation.translationData.text}\n"

    content += "\n"
    content += EJSON.stringify @

    encoder = new util.TextEncoder
    arrayBuffer = encoder.encode content

    arrayBuffer: arrayBuffer
    path: "#{path}.translation.txt"
    lastEditTime: @lastEditTime
