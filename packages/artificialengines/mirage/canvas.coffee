AE = Artificial.Everywhere
AM = Artificial.Mirage

if Meteor.isServer
  {createCanvas, Image} = require 'canvas'

# A canvas that works on client and server.
class AM.Canvas
  constructor: (widthOrImage, heightOrContextAttributes, contextAttributes) ->
    if widthOrImage?.width
      image = widthOrImage
      width = image.width
      height = image.height
      contextAttributes = heightOrContextAttributes
      
    else
      width = widthOrImage or 0
      height = heightOrContextAttributes or 0
    
    if Meteor.isServer
      canvas = createCanvas width, height

    else
      canvas = $('<canvas>')[0]
      canvas.width = width
      canvas.height = height
  
    canvas.context = canvas.getContext '2d', contextAttributes
    canvas.context.drawImage image, 0, 0 if image

    canvas.getImage = ->
      image = new Image
      image.src = canvas.toDataURL()
      image

    return canvas

class AM.ReadableCanvas
  constructor: (widthOrImage, heightOrContextAttributes, contextAttributes) ->
    if widthOrImage?.width
      image = widthOrImage
      contextAttributes = heightOrContextAttributes
  
    else
      width = widthOrImage or 0
      height = heightOrContextAttributes or 0
  
    contextAttributes ?= {}
    contextAttributes.willReadFrequently = true

    if image
      canvas = new AM.Canvas image, contextAttributes
      
    else
      canvas = new AM.Canvas width, height, contextAttributes
  
    canvas.getFullImageData = ->
      canvas.context.getImageData 0, 0, canvas.width, canvas.height
  
    canvas.putFullImageData = (imageData) ->
      canvas.context.putImageData imageData, 0, 0
      
    return canvas
