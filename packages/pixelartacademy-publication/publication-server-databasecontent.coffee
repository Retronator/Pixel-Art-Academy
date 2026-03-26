PAA = PixelArtAcademy

util = require 'util'

class PAA.Publication extends PAA.Publication
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
    
    # The content is the reference ID of the publication and its contents.
    content = "#{@referenceId}\n"
    
    for contentItem in _.orderBy @contents, (contentItem) => contentItem.order
      content += "- #{contentItem.part.referenceId}\n"
    
    content += "\n#{EJSON.stringify @}"
    
    encoder = new util.TextEncoder
    arrayBuffer = encoder.encode content
    
    plainData: @
    arrayBuffer: arrayBuffer
    path: "#{@referenceId.split('.').join('/').toLowerCase()}.txt"
    lastEditTime: @lastEditTime
