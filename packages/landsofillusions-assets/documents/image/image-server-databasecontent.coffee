AM = Artificial.Mirage
AMu = Artificial.Mummification
LOI = LandsOfIllusions

{ createCanvas, loadImage } = require 'canvas'

# HACK: It seems we can only return plain objects from a wrapAsync
# method, so we return the image data of the loaded image.
getPlainImageData = Meteor.wrapAsync (url, callback) ->
  image = await loadImage(url)
  # Note: For some reason we cannot use AM.Canvas here since it doesn't accept image as an Image object.
  canvas = createCanvas image.width, image.height
  context = canvas.getContext '2d'
  context.drawImage image, 0, 0
  imageData = context.getImageData 0, 0, canvas.width, canvas.height
  callback null, imageData

PNG = require 'fast-png'

class LOI.Assets.Image extends LOI.Assets.Image
  @Meta
    name: @id()
    replaceParent: true

  @deserializeDatabaseContent: (arrayBuffer) ->
    imageData = PNG.decode arrayBuffer
    AMu.EmbeddedImageData.extract imageData

  getDatabaseContent: ->
    # Add last edit time if needed so that documents don't need unnecessary imports.
    @lastEditTime ?= new Date()
  
    previewImage = @getPreviewImage()
    imageData = AMu.EmbeddedImageData.embed previewImage, @,
      scaleDown: true
      minimumSize: 100

    # Encode the PNG.
    arrayBuffer = PNG.encode imageData
  
    plainData: @
    arrayBuffer: arrayBuffer
    path: "landsofillusions/assets/documents/image/#{@_id}.png"
    lastEditTime: @lastEditTime

  getPreviewImage: ->
    url = if _.startsWith @url, '/' then Meteor.absoluteUrl @url else @url
    plainImageData = getPlainImageData url
    
    canvas = new AM.ReadableCanvas plainImageData.width, plainImageData.height
    canvasImageData = canvas.getFullImageData()
    canvasImageData.data.set plainImageData.data
    canvas.putFullImageData canvasImageData

    canvas
