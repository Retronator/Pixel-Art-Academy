AB = Artificial.Babel
AM = Artificial.Mirage
AC = Artificial.Control
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pico8.Device extends PAA.Pico8.Device
  onCreated: ->
    super arguments...

    # Enable live sprite updating.
    @_updatedPixels = []
    @_ioMemory = []

    # Listen to all bitmap changes in the project.
    @autorun (computation) =>
      return unless game = @game()
      return unless project = @project()
      
      LOI.Assets.Bitmap.versionedDocuments.operationExecuted.removeHandlers @

      for asset in game.assets
        do (asset) =>
          return unless projectAsset = _.find project.assets, (projectAsset) => projectAsset.id is asset.id

          assetClass = PAA.Practice.Project.Asset.getClassForId asset.id
          backgroundIndex = assetClass.backgroundColor().paletteColor.ramp

          LOI.Assets.Bitmap.versionedDocuments.operationExecuted.addHandler @, (bitmap, operation, changedFields) =>
            return unless bitmap._id is projectAsset.bitmapId

            # React only to pixel changes.
            return unless operation instanceof LOI.Assets.Bitmap.Operations.ChangePixels

            for x in [operation.bounds.x...operation.bounds.x + operation.bounds.width]
              for y in [operation.bounds.y...operation.bounds.y + operation.bounds.height]
                if pixel = bitmap.layers[0].getPixel x, y
                  colorIndex = pixel.paletteColor.ramp

                else
                  # Fill that location with background color.
                  colorIndex = backgroundIndex

                @_updatePixel asset.x * 8 + x, asset.y * 8 + y, colorIndex

  onDestroyed: ->
    super arguments...

    LOI.Assets.Bitmap.versionedDocuments.operationExecuted.removeHandlers @

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
