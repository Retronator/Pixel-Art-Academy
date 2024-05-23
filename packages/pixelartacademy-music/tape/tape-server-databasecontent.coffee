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
    if @title
      content = @title
      
    else
      content = "#{@sides[0].title} / #{@sides[1].title}"
      
    content += " by #{@artist}\n\n"
    
    for side, sideIndex in @sides
      content += "SIDE #{if sideIndex is 0 then "A" else "B"}"
      content += ": #{side.title}" if side.title
      content += "\n"
      
      for track in side.tracks
        content += "#{track.title}\n"
      
      content += "\n"

    content += EJSON.stringify @

    encoder = new util.TextEncoder
    arrayBuffer = encoder.encode content
  
    plainData: @
    arrayBuffer: arrayBuffer
    path: "pixelartacademy/music/tape/#{@slug or @_id}.txt"
    lastEditTime: @lastEditTime
