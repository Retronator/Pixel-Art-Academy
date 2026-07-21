AE = Artificial.Everywhere
AM = Artificial.Mirage
AS = Artificial.Spectrum

class AS.ImageDataHelpers
  @getImageData: (source) ->
    # Get context if we have an image.
    if source instanceof HTMLImageElement
      canvas = new AM.Canvas source.naturalWidth, source.naturalHeight
      context = canvas.getContext '2d'
      context.drawImage source, 0, 0
      source = context

    # Get context if we have a canvas.
    source = source.getContext '2d' if source.getContext?

    # Get image data if the source is a context.
    source = source.getImageData 0, 0, source.canvas.width, source.canvas.height if source.getImageData?

    # Return image data.
    return source if source instanceof ImageData

    throw new AE.ArgumentException "You must provide image data, context, canvas, or an image to get image data."

  @hasTransparency: (source) ->
    imageData = @getImageData source

    # Check the alpha channel if there is a value below 255.
    for i in [3...imageData.data.length] by 4
      return true if imageData.data[i] < 255

    false
