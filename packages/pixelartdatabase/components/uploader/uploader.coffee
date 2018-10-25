AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.Artworks.Components.Uploader extends AM.Component
  @register 'PixelArtAcademy.Artworks.Components.Uploader'

  events: ->
    super(arguments...).concat
      'click .upload-button': @onClickUpload

  onClickUpload: ->
    file = @$('.file-input')[0]?.files[0]
    artwork = @currentData()
    return unless file and artwork

    PAA.Artworks.upload artwork._id, file
