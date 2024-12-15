AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Publication.Article.Figure.Image extends LOI.Component
  @id: -> 'PixelArtAcademy.Publication.Article.Figure.Image'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @Audio = new LOI.Assets.Audio.Namespace @id(),
    subNamespace: true
    variables:
      cut: AEc.ValueTypes.Trigger
      paste: AEc.ValueTypes.Trigger
  
  onCreated: ->
    super arguments...

    @figure = @ancestorComponentOfType PAA.Publication.Article.Figure

    @bitmap = new ComputedField =>
      return unless LOI.adventure
      return unless editor = PAA.PixelPad.Apps.Drawing.Editor.getEditor()
      return unless asset = editor.activeAsset()
      return unless asset instanceof PAA.Practice.Project.Asset.Bitmap
      asset

    @addedToReferences = new ComputedField =>
      return unless bitmap = @bitmap()
      return unless references = bitmap.bitmap()?.references
      
      element = @data()
      _.find references, (reference) => reference.image.url is element.image.url
  
  addedToReferencesClass: ->
    'added-to-references' if @addedToReferences()
    
  canCut: ->
    @figure.readOnly() and @bitmap()
  
  imageSource: ->
    element = @data()
    element.image.url
  
  imageCredit: ->
    element = @data()
    element.image.credit

  events: ->
    super(arguments...).concat
      'load img': @onLoadImage
      'click img': @onClickImage
      'click .cutout': @onClickCutout
      'click .added-to-references-info': @onClickAddedToReferencesInfo

  onLoadImage: (event) ->
    image = event.target

    # Make image fit perfectly into the row.
    $(image).parents('.element').eq(0).css
      flexGrow: image.naturalWidth / image.naturalHeight

    # Inform figure that content has updated so that the surrounding article can recalculate the number of pages.
    @figure.contentUpdated()

  onClickImage: (event) ->
    artworks = [
      image: event.target
    ]

    LOI.adventure.interface.focusArtworks artworks
    
  onClickCutout: (event) ->
    element = @data()
    bitmap = @bitmap()
    document = bitmap.bitmap()
    
    document.executeAction new LOI.Assets.VisualAsset.Actions.AddReferenceByUrl @constructor.id(), document, element.image.url,
      position:
        x: 100 * (Math.random() - 0.5)
        y: 100 * (Math.random() - 0.5)
        
    @audio.cut()
        
  onClickAddedToReferencesInfo: (event) ->
    element = @data()
    bitmap = @bitmap()
    document = bitmap.bitmap()
    
    document.executeAction new LOI.Assets.VisualAsset.Actions.RemoveReferenceByUrl @constructor.id(), document, element.image.url
    
    @audio.paste()
    
  class @Property extends AM.DataInputComponent
    @property: -> throw new AE.NotImplementedException "Property name must be provided."

    constructor: ->
      super arguments...

      @realtime = false

    onCreated: ->
      super arguments...

      @figure = @ancestorComponentOfType PAA.Publication.Article.Figure

    load: ->
      element = @data()
      element.image[@constructor.property()]
      
    save: (value) ->
      element = @data()
      @figure.updateElementProperty element.index, @constructor.property(), value
  
  class @Url extends @Property
    @register 'PixelArtAcademy.Publication.Article.Figure.Image.Url'
    @property: -> 'url'

  class @Credit extends @Property
    @register 'PixelArtAcademy.Publication.Article.Figure.Image.Credit'
    @property: -> 'credit'
