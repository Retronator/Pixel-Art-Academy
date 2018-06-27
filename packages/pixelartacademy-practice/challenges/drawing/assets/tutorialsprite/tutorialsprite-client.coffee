AB = Artificial.Base
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Challenges.Drawing.TutorialSprite extends PAA.Practice.Challenges.Drawing.TutorialSprite
  @createPixelsFromImageUrl: (url, callback) ->
    # Load pixels directly from the source image.
    image = new Image
    image.addEventListener 'load', =>
      callback @createPixelsFromImage image
    ,
      false

    # Initiate the loading.
    image.src = url
    
  @createPixelsFromImage: (image) ->
    canvas = $('<canvas>')[0]
    canvas.width = image.width
    canvas.height = image.height

    context = canvas.getContext '2d'
    context.drawImage image, 0, 0
    imageData = context.getImageData 0, 0, image.width, image.height

    @createPixelsFromImageData imageData
