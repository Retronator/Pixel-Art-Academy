PAA = PixelArtAcademy

util = require 'util'

class PAA.Publication.Part extends PAA.Publication.Part
  @Meta
    name: @id()
    replaceParent: true
  
  @deserializeDatabaseContent: (arrayBuffer) ->
    decoder = new util.TextDecoder
    content = decoder.decode arrayBuffer
    
    # The last line will have JSON content.
    lines = content.split '\n'
    EJSON.parse _.last lines
  
  getDatabaseContent: ->
    # Add last edit time if needed so that documents don't need unnecessary imports.
    @lastEditTime ?= new Date()
    
    # The content is the title of the publication and the article inserts.
    content = "#{@title or @referenceId}\n"
    
    for operation in @article when _.isString operation.insert
      content += operation.insert
    
    content += "\n#{EJSON.stringify @}"
    
    encoder = new util.TextEncoder
    arrayBuffer = encoder.encode content
    
    plainData: @
    arrayBuffer: arrayBuffer
    path: "#{@referenceId.split('.').join('/').toLowerCase()}.txt"
    lastEditTime: @lastEditTime
