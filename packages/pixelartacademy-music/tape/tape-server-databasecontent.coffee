AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

util = require 'util'

class PAA.Music.Tape extends PAA.Music.Tape
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

    # The content is a list of all the tracks plus the JSON information.
    content = ""
    content += "#{title} by #{author}\n\n"
    
    for side in [@sideA, @sideB]
      content += "Side #{if side is @sideA then "A" else "B"}"
      content += ": #{side.title}" if side.title
      content += "\n"
      
      for artwork in side.artworks
        artwork.refresh()
        content += "#{artwork.title}\n"
      
      content += "\n"

    content += EJSON.stringify @

    encoder = new util.TextEncoder
    arrayBuffer = encoder.encode content
  
    plainData: @
    arrayBuffer: arrayBuffer
    path: "pixelartacademy/music/tape/#{@slug or @_id}.txt"
    lastEditTime: @lastEditTime
