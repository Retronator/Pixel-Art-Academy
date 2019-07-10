AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Actions.GenerateMipmaps extends LOI.Assets.Editor.Actions.AssetAction
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.GenerateMipmaps'
  @displayName: -> "Generate mipmaps"
    
  @initialize()

  enabled: ->
    loader = @loader()
    loader instanceof LOI.Assets.SpriteEditor.MipLoader and loader.mipmaps().length

  execute: ->
    mipLoader = @loader()
    existingMipmaps = mipLoader.mipmaps()
    largestMipmap = _.first existingMipmaps

    widths = []

    power = 0
    width = 1

    while width <= largestMipmap.bounds.width
      widths.push width
      power++
      width = Math.pow 2, power

    for width in widths by -1
      # Skip generation if we already have this sprite.
      continue if _.find existingMipmaps, (mipmap) => mipmap.bounds.width is width

      # Duplicate the largest mipmap. We need to explicitly request for the stub to return the new sprite ID.
      newMipmapId = LOI.Assets.Asset.duplicate.apply [LOI.Assets.Sprite.className, largestMipmap._id], returnStubValue: true

      # Add a placeholder to existing mipmaps so we know which ID was used for that size.
      mipmapPlaceholder =
        _id: newMipmapId
        bounds:
          width: width

      existingMipmaps.push mipmapPlaceholder

      # Rename the duplicate.
      LOI.Assets.Asset.update LOI.Assets.Sprite.className, newMipmapId,
        $set:
          name: "#{mipLoader.fileId}/#{width}"

      # Resize the duplicate to desired width.
      LOI.Assets.Sprite.resize newMipmapId, width, width, (error) =>
