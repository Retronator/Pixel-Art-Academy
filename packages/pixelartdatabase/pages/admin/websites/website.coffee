AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.Pages.Admin.Websites.Website extends Artificial.Mummification.Admin.Components.Document
  @id: -> 'PixelArtDatabase.Pages.Admin.Websites.Website'
  @register @id()

  events: ->
    super(arguments...).concat
      'click .blog-feature .render-preview-button': @onClickBlogFeatureRenderPreviewButton

  onClickBlogFeatureRenderPreviewButton: (event) ->
    website = @currentData()
    PADB.Website.renderBlogPreview website._id
    
  class @Name extends AM.DataInputComponent
    @register 'PixelArtDatabase.Pages.Admin.Websites.Website.Name'

    load: -> @currentData()?.name
    save: (value) -> PADB.Website.update @currentData()._id, $set: name: value

  class @Url extends AM.DataInputComponent
    @register 'PixelArtDatabase.Pages.Admin.Websites.Website.Url'

    load: -> @currentData()?.url
    save: (value) -> PADB.Website.update @currentData()._id, $set: url: value

  class @BlogFeature extends AM.DataInputComponent
    @register 'PixelArtDatabase.Pages.Admin.Websites.Website.BlogFeature'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Checkbox

    load: -> @currentData()?.blogFeature?.enabled
    save: (value) -> PADB.Website.update @currentData()._id, $set: 'blogFeature.enabled': value

    class @Order extends AM.DataInputComponent
      @register 'PixelArtDatabase.Pages.Admin.Websites.Website.BlogFeature.Order'
  
      constructor: ->
        super arguments...
  
        @type = AM.DataInputComponent.Types.Number
  
      load: -> @currentData()?.blogFeature.order
      save: (value) ->
        value = parseInt value
        value = null if _.isNaN value
        PADB.Website.update @currentData()._id, $set: 'blogFeature.order': value

    class @CustomCss extends AM.DataInputComponent
      @register 'PixelArtDatabase.Pages.Admin.Websites.Website.BlogFeature.CustomCss'

      constructor: ->
        super arguments...

        @type = AM.DataInputComponent.Types.TextArea

      load: -> @currentData()?.blogFeature.preview?.customCss
      save: (value) -> PADB.Website.update @currentData()._id, $set: 'blogFeature.preview.customCss': value
      
    class @Width extends AM.DataInputComponent
      @register 'PixelArtDatabase.Pages.Admin.Websites.Website.BlogFeature.Width'

      constructor: ->
        super arguments...

        @type = AM.DataInputComponent.Types.Number

      load: -> @currentData()?.blogFeature.preview?.width
      save: (value) ->
        value = parseInt value
        value = null if _.isNaN value
        PADB.Website.update @currentData()._id, $set: 'blogFeature.preview.width': value

    class @Height extends AM.DataInputComponent
      @register 'PixelArtDatabase.Pages.Admin.Websites.Website.BlogFeature.Height'

      constructor: ->
        super arguments...

        @type = AM.DataInputComponent.Types.Number

      load: -> @currentData()?.blogFeature.preview?.height
      save: (value) ->
        value = parseInt value
        value = null if _.isNaN value
        PADB.Website.update @currentData()._id, $set: 'blogFeature.preview.height': value

    class @RenderDelay extends AM.DataInputComponent
      @register 'PixelArtDatabase.Pages.Admin.Websites.Website.BlogFeature.RenderDelay'

      constructor: ->
        super arguments...

        @type = AM.DataInputComponent.Types.Number

      load: -> @currentData()?.blogFeature.preview?.renderDelay
      save: (value) ->
        value = parseInt value
        value = null if _.isNaN value
        PADB.Website.update @currentData()._id, $set: 'blogFeature.preview.renderDelay': value
