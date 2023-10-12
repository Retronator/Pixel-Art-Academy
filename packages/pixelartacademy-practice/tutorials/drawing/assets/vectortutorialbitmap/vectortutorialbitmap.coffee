PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Tutorials.Drawing.Assets.VectorTutorialBitmap extends PAA.Practice.Project.Asset.Bitmap
  # [chosenReferenceUrls]: array of reference URLs chosen to be drawn
  @id: -> 'PixelArtAcademy.Practice.Tutorials.Drawing.Assets.VectorTutorialBitmap'
  
  # Override to provide an SVG URL to describing the drawing.
  @svgUrl: -> null

  # Override to provide an SVG URLs that correspond to references.
  @referenceSvgUrls: -> null

  # Override to limit the scale at which the bitmap appears in the clipboard.
  @minClipboardScale: -> null
  @maxClipboardScale: -> null

  # Override to define a background color.
  @backgroundColor: -> null

  # Override to define a palette.
  @restrictedPaletteName: -> null
  @customPaletteImageUrl: -> null
  @customPalette: -> null
  
  # Override to not use progressive path completion.
  @progressivePathCompletion: -> true
  
  @initialize: ->
    super arguments...
    
    # Create reference images on the server. They should be exported as database content.
    if Meteor.isServer and not Meteor.settings.startEmpty
      if references = @references?()
        Document.startup =>
          for reference in references
            # Allow sending in just the reference URL.
            imageUrl = reference.image?.url or reference
      
            LOI.Assets.Image.documents.insert url: imageUrl unless LOI.Assets.Image.documents.findOne url: imageUrl

  constructor: ->
    super arguments...
    
    @tutorial = @project

    # Create bitmap automatically if it is not present.
    Tracker.autorun (computation) =>
      return unless assets = @tutorial.assetsData()
      computation.stop()

      # All is good if we have the asset with a bitmap ID.
      return if _.find assets, (asset) => asset.id is @id() and asset.bitmapId

      # We need to create the asset with the bitmap.
      Tracker.nonreactive => @constructor.create LOI.adventure.profileId(), @tutorial, @id()
      
    # Fetch palette.
    @palette = new ComputedField =>
      return unless bitmapData = @bitmap()
      bitmapData.customPalette or LOI.Assets.Palette.documents.findOne bitmapData.palette._id

    @svgPathGroups = new ReactiveField null
    @currentActivePathIndex = new ReactiveField 0
    
    # Load SVG if only a single one is provided.
    if svgUrl = @constructor.svgUrl()
      svgUrl = Meteor.absoluteUrl svgUrl
      
      fetch(svgUrl).then((response) => response.text()).then (svgXml) =>
        parser = new DOMParser();
        svgDocument = parser.parseFromString svgXml, "image/svg+xml"
        @svgPathGroups [svgPaths: svgDocument.getElementsByTagName 'path']
        
    # Load SVGs of used references.
    if referenceSvgUrls = @constructor.referenceSvgUrls()
      @referenceSvgPaths = new ReactiveField []
      
      for svgUrl, index in referenceSvgUrls
        svgUrl = Meteor.absoluteUrl svgUrl
        
        do (svgUrl, index) =>
          fetch(svgUrl).then((response) => response.text()).then (svgXml) =>
            parser = new DOMParser();
            svgDocument = parser.parseFromString svgXml, "image/svg+xml"
            referenceSvgPaths = @referenceSvgPaths()
            referenceSvgPaths[index] = svgDocument.getElementsByTagName 'path'
            @referenceSvgPaths referenceSvgPaths
      
      # Update chosen references.
      @chosenReferenceUrls = new ComputedField =>
        @data()?.chosenReferenceUrls
      ,
        true
      
      # Only react to displayed reference changes to minimize resizes.
      @displayedReferenceUrls = new ComputedField =>
        return unless bitmap = @bitmap()
        return unless references = bitmap.references
        displayedReferences = _.filter references, (reference) => reference.displayed
        
        reference.image.url for reference in displayedReferences
      ,
        EJSON.equals
      ,
        true

      # Update chosen references and resize the bitmap accordingly if needed.
      @_chosenReferencesAutorun = Tracker.autorun (computation) =>
        return unless displayedReferenceUrls = @displayedReferenceUrls()
        
        Tracker.nonreactive => Tracker.afterFlush =>
          return unless bitmapId = @bitmapId()
          return unless bitmap = @bitmap()
          
          chosenReferenceUrls = Tracker.nonreactive => @chosenReferenceUrls() or []

          # Remove references in the back that haven't been drawn on yet.
          fixedDimensions = @constructor.fixedDimensions()
          singleWidth = fixedDimensions.width
          
          removeNeeded = false
          
          for referenceUrl in chosenReferenceUrls when referenceUrl not in displayedReferenceUrls
            removeNeeded = true
            break
          
          if removeNeeded
            for referenceUrl, index in chosenReferenceUrls by -1
              startX = index * singleWidth
              
              found = false
              for x in [0...singleWidth]
                for y in [0...fixedDimensions.height]
                  if bitmap.findPixelAtAbsoluteCoordinates startX + x, y
                    found = true
                    break
                    
                break if found
                
              # Stop removing unused references since the player has already drawn here.
              break if found
              
              # The player hasn't drawn so far, so if we don't want the reference anymore, we can remove it.
              if referenceUrl not in displayedReferenceUrls
                _.pull chosenReferenceUrls, referenceUrl
          
          # Add new references.
          for referenceUrl in displayedReferenceUrls
            chosenReferenceUrls.push referenceUrl unless referenceUrl in chosenReferenceUrls
          
          assets = @tutorial.assetsData()
          asset = _.find assets, (asset) => asset.id is @id()
          asset.chosenReferenceUrls = chosenReferenceUrls
          
          @tutorial.state 'assets', assets
  
          # If necessary, resize the bitmap to make space for all the chosen references.
          desiredWidth = singleWidth * Math.max 1, chosenReferenceUrls.length
          
          bitmap = Tracker.nonreactive => LOI.Assets.Bitmap.documents.findOne bitmapId, fields: bounds: 1
          width = bitmap.bounds.right - bitmap.bounds.left + 1
          
          unless desiredWidth is width
            bitmap = Tracker.nonreactive => LOI.Assets.Bitmap.versionedDocuments.getDocumentForId bitmapId
  
            # Create a change bounds action.
            changeBounds = new LOI.Assets.Bitmap.Actions.ChangeBounds @id(), bitmap,
              left: 0
              top: 0
              right: desiredWidth - 1
              bottom: fixedDimensions.height - 1
              fixed: true
              
            bitmap.executeAction changeBounds, true
        
      # Dynamically load svg paths of the chosen references.
      @_referenceSvgPathsAutorun = Tracker.autorun (computation) =>
        return unless chosenReferenceUrls = @chosenReferenceUrls()
        return unless bitmap = @bitmap()
        return unless references = bitmap.references
        
        referenceSvgPaths = @referenceSvgPaths()

        svgPathGroups = []
        
        singleWidth = @constructor.fixedDimensions().width
        
        for chosenReferenceUrl, index in chosenReferenceUrls
          urlIndex = _.findIndex references, (reference) => reference.image.url is chosenReferenceUrl
          return unless svgPaths = referenceSvgPaths[urlIndex]
          
          svgPathGroups.push
            offset:
              x: index * singleWidth
              y: 0
            svgPaths: svgPaths
        
        @svgPathGroups svgPathGroups
        
    # Create paths.
    @paths = new ComputedField =>
      return unless @bitmap()
      return unless svgPathGroups = @svgPathGroups()
      
      paths = for svgPathGroup in svgPathGroups
        new @constructor.Path @, svgPath, svgPathGroup.offset for svgPath in svgPathGroup.svgPaths
        
      _.flatten paths
    ,
      true

    # Create the components that will show the goal state.
    @pathsEngineComponent = new @constructor.PathsEngineComponent
      svgPathGroups: => @svgPathGroups()
      paths: => @paths()
      currentActivePathIndex: => @currentActivePathIndex()
    
    @hintsEngineComponent = new @constructor.HintsEngineComponent
      paths: => @paths()
      
    @hasExtraPixels = new ComputedField =>
      return unless bitmapLayer = @bitmap()?.layers[0]
      return unless paths = @paths()
      
      # See if there are any pixels in the bitmap that don't belong to any path.
      for x in [0...bitmapLayer.width]
        for y in [0...bitmapLayer.height]
          # Extra pixels can only exist where pixels are placed.
          continue unless bitmapLayer.getPixel(x, y)
          
          # Try to find a pixel in one of the paths.
          found = false
          for path in paths
            if path.hasPixel x, y
              found = true
              break
          
          # If we didn't find a path that required this pixel, we have an extra.
          return true unless found
          
      false
    ,
      true
      
    @completed = new ComputedField =>
      return unless paths = @paths()
      return unless paths.length
      
      completedPaths = 0
      
      for path in paths
        if path.completed()
          completedPaths++
        
        else
          break
          
      # As a side effect, update which one is the current path to draw.
      if @constructor.progressivePathCompletion()
        @currentActivePathIndex Math.min completedPaths, paths.length - 1
        
      else
        @currentActivePathIndex paths.length - 1
      
      # Note: We shouldn't quit early because of extra pixels, since we wouldn't update
      # active path index otherwise, so we do it here at the end as a final condition.
      completedPaths is paths.length and not @hasExtraPixels()
    ,
      true

    # Save completed value to tutorial state.
    @_completedAutorun = Tracker.autorun (computation) =>
      # Make sure we have the game state loaded. This can become null when switching between characters.
      return unless LOI.adventure.gameState()

      # We expect completed to return true or false, and undefined if can't yet determine (loading).
      completed = @completed()
      return unless completed?

      assets = @tutorial.state 'assets'

      unless assets
        assets = []
        updated = true

      asset = _.find assets, (asset) => asset.id is @id()

      unless asset
        asset = id: @id()
        assets.push asset
        updated = true

      unless asset.completed is completed
        asset.completed = completed
        updated = true

      @tutorial.state 'assets', assets if updated

  destroy: ->
    super arguments...
    
    @chosenReferenceUrls?.stop()
    @displayedReferenceUrls?.stop()
    @_chosenReferencesAutorun?.stop()
    @_referenceSvgPathsAutorun?.stop()
    @paths.stop()
    @hasExtraPixels.stop()
    @completed.stop()
    @_completedAutorun.stop()
  
  solve: ->
  
  editorDrawComponents: -> [
    component: @pathsEngineComponent, before: LOI.Assets.Engine.PixelImage.Bitmap
  ,
    component: @hintsEngineComponent, before: LOI.Assets.SpriteEditor.PixelCanvas.OperationPreview
  ]

  styleClasses: ->
    classes = [
      'completed' if @completed()
    ]

    _.without(classes, undefined).join ' '

  minClipboardScale: -> @constructor.minClipboardScale?()
  maxClipboardScale: -> @constructor.maxClipboardScale?()
