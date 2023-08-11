AE = Artificial.Everywhere
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Actions.Export extends LOI.Assets.Editor.Actions.AssetAction
  @id: -> 'LandsOfIllusions.Assets.Editor.Actions.Export'
  @displayName: -> "Export"

  @initialize()

  execute: ->
    # Serialize asset to binary.
    asset = @asset()

    pngData = asset.getDatabaseContent().arrayBuffer
    pngBlob = new Blob [pngData], type: "image/png"
    pngUrl = URL.createObjectURL pngBlob

    # Export image.
    $link = $('<a style="display: none">')
    $('body').append $link

    name = asset.name or asset._id
    nameStartIndex = name.lastIndexOf('/') + 1
    name = "#{name.substring nameStartIndex}.#{_.toLower asset.constructor.className}.png"

    link = $link[0]
    link.download = name
    link.href = pngUrl
    link.click()

    $link.remove()
