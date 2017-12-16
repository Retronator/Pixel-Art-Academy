AM = Artificial.Mirage
PAA = PixelArtAcademy
PADB = PixelArtDatabase

class PADB.Pages.Admin.Websites.Website extends PAA.Pages.Admin.Components.Document
  @id: -> 'PixelArtDatabase.Pages.Admin.Websites.Website'
  @register @id()

  events: ->
    super.concat
      'click .render-preview-button': @onClickRenderPreviewButton

  onClickRenderPreviewButton: (event) ->
    website = @currentData()
    PADB.Website.renderPreview website._id
    
  class @Name extends AM.DataInputComponent
    @register 'PixelArtDatabase.Pages.Admin.Websites.Website.Name'

    load: -> @currentData()?.name
    save: (value) -> PADB.Website.update @currentData()._id, $set: name: value

  class @Url extends AM.DataInputComponent
    @register 'PixelArtDatabase.Pages.Admin.Websites.Website.Url'

    load: -> @currentData()?.url
    save: (value) -> PADB.Website.update @currentData()._id, $set: url: value

  class @FeaturedInRetronatorDaily extends AM.DataInputComponent
    @register 'PixelArtDatabase.Pages.Admin.Websites.Website.FeaturedInRetronatorDaily'

    constructor: ->
      super

      @type = AM.DataInputComponent.Types.Checkbox

    load: -> @currentData()?.featuredInRetronatorDaily
    save: (value) -> PADB.Website.update @currentData()._id, $set: featuredInRetronatorDaily: value
