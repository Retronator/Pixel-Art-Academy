AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project.Asset.Sprite.BriefComponent extends AM.Component
  @register 'PixelArtAcademy.Practice.Project.Asset.Sprite.BriefComponent'

  constructor: (@sprite) ->
    super
    
  onCreated: ->
    super
    
    @parent = @ancestorComponentWith 'editAsset'

  needsSettingsSelection: ->
    not (PAA.PixelBoy.Apps.Drawing.state('editorId') or PAA.PixelBoy.Apps.Drawing.state('externalSoftware'))

  needsToolsChallenge: ->
    true

  noActions: ->
    not (@canEdit() or @canUpload())

  canEdit: ->
    # Editor needs to be selected.
    return unless PAA.PixelBoy.Apps.Drawing.state('editorId')

    PAA.Practice.Project.Asset.Sprite.state 'canEdit'

  canUpload: ->
    # External software needs to be selected.
    return unless PAA.PixelBoy.Apps.Drawing.state('externalSoftware')

    PAA.Practice.Project.Asset.Sprite.state 'canUpload'

  customPaletteColorsString: ->
    count = 0
    count += ramp.shades.length for ramp in @sprite.customPalette().ramps

    "#{count} color#{if count > 1 then 's' else ''}"

  events: ->
    super.concat
      'click .edit-button': @onClickEditButton
      'click .assets-button': @onClickAssetsButton
      'click .upload-button': @onClickUploadButton

  onClickEditButton: (event) ->
    @parent.editAsset()

  onClickAssetsButton: (event) ->
    @parent.showSecondPage()

  onClickUploadButton: (event) ->
    $fileInput = $('<input type="file"/>')

    $fileInput.on 'change', (event) =>
      return unless file = $fileInput[0]?.files[0]

      # Load file.
      reader = new FileReader()
      reader.onload = (event) =>
        image = new Image
        image.onload = =>
          sprite = @parent.asset()

          if fixedDimensions = sprite.fixedDimensions()
            # Make sure the dimensions match.
            unless image.width is fixedDimensions.width and image.height is fixedDimensions.height
              # Report the mismatch to the player.
              LOI.adventure.showActivatableModalDialog
                dialog: new LOI.Components.Dialog
                  message: "The size of the uploaded image (#{image.width}×#{image.height}) does not match
                            the required sprite size (#{fixedDimensions.width}×#{fixedDimensions.height})."
                  buttons: [text: "OK"]

              return

          canvas = $('<canvas>')[0]
          canvas.width = image.width
          canvas.height = image.height
          context = canvas.getContext '2d'

          context.drawImage image, 0, 0

          imageData = context.getImageData 0, 0, canvas.width, canvas.height
          @processUploadData imageData

        image.src = event.target.result

      reader.readAsDataURL file

    $fileInput.click()

  processUploadData: (imageData) ->
    # TODO: Replace sprite pixels with those from image.
