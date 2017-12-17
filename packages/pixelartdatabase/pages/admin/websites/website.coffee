AM = Artificial.Mirage
PAA = PixelArtAcademy
PADB = PixelArtDatabase

class PADB.Pages.Admin.Websites.Website extends PAA.Pages.Admin.Components.Document
  @id: -> 'PixelArtDatabase.Pages.Admin.Websites.Website'
  @register @id()

  events: ->
    super.concat
      'click .retronator-daily-feature .render-preview-button': @onClickRetronatorDailyFeatureRenderPreviewButton

  onClickRetronatorDailyFeatureRenderPreviewButton: (event) ->
    website = @currentData()
    PADB.Website.renderRetronatorDailyFeaturePreview website._id
    
  class @Name extends AM.DataInputComponent
    @register 'PixelArtDatabase.Pages.Admin.Websites.Website.Name'

    load: -> @currentData()?.name
    save: (value) -> PADB.Website.update @currentData()._id, $set: name: value

  class @Url extends AM.DataInputComponent
    @register 'PixelArtDatabase.Pages.Admin.Websites.Website.Url'

    load: -> @currentData()?.url
    save: (value) -> PADB.Website.update @currentData()._id, $set: url: value

  class @RetronatorDailyFeature extends AM.DataInputComponent
    @register 'PixelArtDatabase.Pages.Admin.Websites.Website.RetronatorDailyFeature'

    constructor: ->
      super

      @type = AM.DataInputComponent.Types.Checkbox

    load: -> @currentData()?.retronatorDailyFeature?.enabled
    save: (value) -> PADB.Website.update @currentData()._id, $set: 'retronatorDailyFeature.enabled': value

    class @Order extends AM.DataInputComponent
      @register 'PixelArtDatabase.Pages.Admin.Websites.Website.RetronatorDailyFeature.Order'
  
      constructor: ->
        super
  
        @type = AM.DataInputComponent.Types.Number
  
      load: -> @currentData()?.retronatorDailyFeature.order
      save: (value) -> PADB.Website.update @currentData()._id, $set: 'retronatorDailyFeature.order': value

    class @CustomCss extends AM.DataInputComponent
      @register 'PixelArtDatabase.Pages.Admin.Websites.Website.RetronatorDailyFeature.CustomCss'

      constructor: ->
        super

        @type = AM.DataInputComponent.Types.TextArea

      load: -> @currentData()?.retronatorDailyFeature.preview.customCss
      save: (value) -> PADB.Website.update @currentData()._id, $set: 'retronatorDailyFeature.preview.customCss': value
