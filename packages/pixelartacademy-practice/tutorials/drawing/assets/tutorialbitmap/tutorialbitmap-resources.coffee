AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  # Override to provide a map of resources that need to be loaded on the client for this asset.
  @resources: -> {}
  
  # Override to provide a bitmap string describing the bitmap.
  @bitmapString: -> null
  @goalBitmapString: -> null

  # Override to provide an image URL to describing the bitmap.
  @imageUrl: -> null
  @goalImageUrl: -> null

  # Override to provide an SVG URL to describing the drawing.
  @svgUrl: -> null

  # Override to provide an array of steps to be completed in this tutorial asset.
  @steps: -> null

  # Override to provide an array of goals the player can choose to complete this tutorial bitmap.
  @goalChoices: -> null
  
  @createResources: ->
    # Combine explicitly specified resources with ones defined through class methods.
    explicitResources = @resources()
    
    implicitResources = @_createResourcesObject @
    
    if goalChoices = @goalChoices()
      implicitResources.goalChoices = (@_createResourcesObject goal, true for goal in goalChoices)
    
    if steps = @steps()
      implicitResources.steps = (@_createResourcesObject step for step in steps)
    
    _.extend {}, explicitResources, implicitResources

  @_createResourcesObject: (resourcesProvider, transferAllProperties) ->
    if transferAllProperties
      resources = _.clone resourcesProvider
      
    else
      resources = {}
    
    if _.isObject resourcesProvider
      resources.startPixels = new @Resource.BitmapStringPixels bitmapString if bitmapString = _.propertyValue resourcesProvider, 'bitmapString'
      resources.startPixels = new @Resource.ImagePixels imageUrl if imageUrl = _.propertyValue resourcesProvider, 'imageUrl'
      
      resources.goalPixels = new @Resource.BitmapStringPixels goalBitmapString if goalBitmapString = _.propertyValue resourcesProvider, 'goalBitmapString'
      resources.goalPixels = new @Resource.ImagePixels goalImageUrl if goalImageUrl = _.propertyValue resourcesProvider, 'goalImageUrl'
      
      resources.svgPaths = new @Resource.SvgPaths svgUrl if svgUrl = _.propertyValue resourcesProvider, 'svgUrl'
    
    else
      extension = resourcesProvider[resourcesProvider.lastIndexOf('.') + 1..]
      resources.goalPixels = new @Resource.ImagePixels resourcesProvider if extension is 'png'
      resources.svgPaths = new @Resource.SvgPaths resourcesProvider if extension is 'svg'
    
    resources
