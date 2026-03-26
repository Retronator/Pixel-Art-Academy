AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

util = require 'util'

class PAA.Practice.Project extends PAA.Practice.Project
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
    
    # The content is the type of the project.
    content = @type
    content += "\n"
    content += EJSON.stringify @
    
    encoder = new util.TextEncoder
    arrayBuffer = encoder.encode content
    
    plainData: @
    arrayBuffer: arrayBuffer
    path: "#{@name or @_id}.txt"
    lastEditTime: @lastEditTime
