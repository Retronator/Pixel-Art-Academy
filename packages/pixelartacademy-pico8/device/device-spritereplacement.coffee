AB = Artificial.Babel
AM = Artificial.Mirage
AC = Artificial.Control
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pico8.Device extends PAA.Pico8.Device
  onCreated: ->
    super

    # Enable live sprite updating.
    @_updatedPixels = []
    @_ioMemory = []

    # Subscribe to all project sprites.
    @autorun (computation) =>
      return unless project = @project()

      for asset in project.assets
        LOI.Assets.Sprite.forId.subscribe @, asset.sprite._id

    # Listen to all sprite changes in the project.
    @autorun (computation) =>
      return unless game = @game()
      return unless project = @project()

      for asset in game.assets
        do (asset) =>
          projectAsset = _.find project.assets, (projectAsset) => projectAsset.id is asset.id

          assetClass = PAA.Practice.Project.Asset.getClassForId asset.id
          backgroundIndex = assetClass.backgroundColor().paletteColor.ramp

          LOI.Assets.Sprite.documents.find(
            _id: projectAsset.sprite._id
          ,
            fields:
              # React only to pixel changes.
              layers: 1
          ).observe
            changed: (newSprite, oldSprite) =>
              # Find the difference between old and new pixels.
              newPixels = newSprite.layers[0].pixels
              oldPixels = oldSprite.layers[0].pixels

              for oldPixel in oldPixels
                # Does the pixel still exists?
                newPixel = _.find newPixels, (pixel) => pixel.x is oldPixel.x and pixel.y is oldPixel.y
                if newPixel
                  # Did the color change?
                  unless newPixel.paletteColor.ramp is oldPixel.paletteColor.ramp
                    # Pixel has changed color.
                    @_updatePixel asset.x * 8 + oldPixel.x, asset.y * 8 + oldPixel.y, newPixel.paletteColor.ramp

                else
                  # Pixel was removed. Fill that location with background color.
                  @_updatePixel asset.x * 8 + oldPixel.x, asset.y * 8 + oldPixel.y, backgroundIndex

              for newPixel in newPixels
                # Did this pixel already exist?
                oldPixel = _.find oldPixels, (pixel) => pixel.x is newPixel.x and pixel.y is newPixel.y
                unless oldPixel
                  # This is a new pixel so we need to color it.
                  @_updatePixel asset.x * 8 + newPixel.x, asset.y * 8 + newPixel.y, newPixel.paletteColor.ramp

  _updatePixel: (x, y, color) ->
    @_updatedPixels.push {x, y, color}

  handleSpriteReplacementIO: (address, value) ->
    # Ignore write calls.
    return if value?
    
    if address is 0
      # PICO-8 is waiting for sprite updates. We can update up to 42 sprites at once.
      transferredPixels = @_updatedPixels.splice 0, 42

      # Transfer the values into the IO buffer.
      for pixel, index in transferredPixels
        @_ioMemory[index * 3 + 1] = pixel.x
        @_ioMemory[index * 3 + 2] = pixel.y
        @_ioMemory[index * 3 + 3] = pixel.color

      # Return the number of pixels we're transferring.
      transferredPixels.length

    else
      # Return the value in the IO buffer.
      @_ioMemory[address]
