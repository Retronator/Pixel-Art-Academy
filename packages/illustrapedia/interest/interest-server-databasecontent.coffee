AB = Artificial.Babel
AM = Artificial.Mummification
IL = Illustrapedia

util = require 'util'

class IL.Interest extends IL.Interest
  @Meta
    name: @id()
    replaceParent: true
  
  @deserializeDatabaseContent: (arrayBuffer) ->
    decoder = new util.TextDecoder
    content = decoder.decode arrayBuffer
    
    # The last line will have JSON content.
    lines = content.split '\n'
    EJSON.parse _.last lines
  
  databaseContentPath: -> "illustrapedia/interest/#{_.kebabCase @searchTerms[0]}"
  
  getDatabaseContent: ->
    # Add last edit time if needed so that documents don't need unnecessary imports.
    @lastEditTime ?= new Date()
    
    # The content is the list of search terms.
    content = @searchTerms.join '\n'
    
    content += "\n#{EJSON.stringify @}"
    
    encoder = new util.TextEncoder
    arrayBuffer = encoder.encode content
    
    plainData: @
    arrayBuffer: arrayBuffer
    path: "#{@databaseContentPath()}.txt"
    lastEditTime: @lastEditTime
