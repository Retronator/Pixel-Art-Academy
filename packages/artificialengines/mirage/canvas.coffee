AE = Artificial.Everywhere
AM = Artificial.Mirage

if Meteor.isServer
  {createCanvas} = require 'canvas'

# A canvas that works on client and server.
class AM.Canvas
  constructor: (width, height) ->
    if Meteor.isServer
      canvas = createCanvas width, height

    else
      canvas = $('<canvas>')[0]
      canvas.width = width
      canvas.height = height

    canvas.context = canvas.getContext '2d'

    canvas.getFullImageData = ->
      canvas.context.getImageData 0, 0, canvas.width, canvas.height

    canvas.putFullImageData = (imageData) ->
      canvas.context.putImageData imageData, 0, 0

    return canvas
