AE = Artificial.Everywhere
AP = Artificial.Pyramid
AS = Artificial.Spectrum
AM = Artificial.Mirage
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

_bezierVertex = new THREE.Vector2

class PAA.Practice.ReadabilityAnalysis
  # passes: boolean if all regions are readable
  # regions: an array of parts of the bitmap on which to do the analysis
  #   targetLabel: the label that the region should convey
  #   passes: boolean if the region is readable
  #   recognition:
  #     passes: boolean if the target label is recognized correctly
  #   bounds: the bounds of the region in the bitmap, if not covering the whole bitmap
  #     x, y, width, height
  #   labels: the analysis of which labels get recognized in the image
  #     symbolic, realistic: arrays of label probabilities sorted by probability descending (only labels with 1% and up probability stored in the asset)
  #       label: string with the name
  #       probability: number between 0 and 1 how likely this label is drawn, not stored in the asset
  #       probabilityPercentage: integer between 1 and 100
  @getStrokesFromPixelArtEvaluation: (pixelArtEvaluation, bounds) ->
    strokes = []
    
    for layer in pixelArtEvaluation.layers
      # Convert lines into polygonal chains.
      for line in layer.lines
        if bounds
          lineBounds = line.getPixelBounds()
          
          # Skip line if it doesn't intersect with region bounds
          continue if lineBounds.maxX < bounds.x
          continue if lineBounds.maxY < bounds.y
          continue if lineBounds.minX >= bounds.x + bounds.width
          continue if lineBounds.minY >= bounds.y + bounds.height
        
        vertices = []
        
        for part in line.parts
          if part instanceof PAE.Line.Part.StraightLine
            vertices.push part.displayLine2.start, part.displayLine2.end
            
          else if part instanceof PAE.Line.Part.Curve
            points = part.displayPoints
            getPoint = (index) => if part.isClosed then points[_.modulo index, points.length] else points[index]
            
            vertices.push points[0].position
            
            endIndex = if part.isClosed then points.length - 1 else points.length - 2
            
            for pointIndex in [0..endIndex]
              start = getPoint pointIndex
              end = getPoint pointIndex + 1
              vertexCount = Math.max 2, Math.abs(start.position.x - end.position.x), Math.abs(start.position.y - end.position.y)

              for vertexIndex in [1...vertexCount]
                vertices.push AP.BezierCurve.getPointOnCubicBezierCurve start.position, start.controlPoints.after, end.controlPoints.before, end.position, vertexIndex / (vertexCount - 1)
        
        strokes.push new AP.PolygonalChain vertices
      
      # Add extra connections based on points.
      for point in layer.points
        if bounds
          # Skip point if it doesn't lie in region bounds
          continue unless 0 <= point.x - bounds.x < bounds.width
          continue unless 0 <= point.y - bounds.y < bounds.width
          
        extraConnectionCreated = false
        
        # Add lines between extra neighbors that haven't been connected with lines.
        extraNeighbors = _.difference point.allNeighbors, point.neighbors
        
        pointOutlines = point.getOutlines()

        for neighbor in extraNeighbors
          # Skip lines between outline points of the same outline.
          if pointOutlines
            neighborOutlines = neighbor.getOutlines()
            continue if _.intersection(pointOutlines, neighborOutlines).length > 0
          
          strokes.push new AP.PolygonalChain [
            new THREE.Vector2 point.x, point.y
            new THREE.Vector2 neighbor.x, neighbor.y
          ]
          
        # Create a (dummy) line if no other connection was found.
        unless extraConnectionCreated or point.lines.length
          vertex = new THREE.Vector2 point.x, point.y
          strokes.push new AP.PolygonalChain [vertex, vertex]
  
    strokes        
  
  constructor: (@bitmap, @options = {}) ->
    @options.preserveNoisyFeatures ?= true

    @regions = null
    
    @pixelArtEvaluation = new PAE @bitmap, @options
    
    @classifiers =
      symbolic: new PAA.ImageClassification.SimpleClassifier.Symbolic
      realistic: new PAA.ImageClassification.SimpleClassifier.Realistic
      
    Meteor.setTimeout =>
      for classifierName, classifier of @classifiers
        await classifier.createInferenceSession()
    
    @_classificationDependency = new Tracker.Dependency
    
    inputSize = PAA.ImageClassification.SimpleClassifier.inputSize
    @_classificationInputData = []
    
    @_depixelizerSourceCanvas = new AM.ReadableCanvas @bitmap.bounds.width + 2, @bitmap.bounds.height + 2
    
    @regionsOptions = new ReactiveField @_extractRegionsOptions(@bitmap), EJSON.equals
    
    @analyzing = new ReactiveField false
    
    @_classificationCounter = 0
    
    @_classificationAutorun = Tracker.autorun (computation) =>
      for classifierName, classifier of @classifiers
        return unless classifier.ready()
      
      return unless regionsOptions = @regionsOptions()

      # Re-run every time we get new lines and points from the pixel art evaluation.
      @pixelArtEvaluation.depend()
      
      # Track which re-run this is so we can cancel previous runs that are still going.
      @_classificationCounter++
      classificationCounter = @_classificationCounter
      
      do (classificationCounter) =>
        Tracker.nonreactive =>
          @analyzing true
          
          # Split the bitmap into regions.
          regions = []
          
          for regionOptions, regionIndex in regionsOptions
            return unless classificationCounter is @_classificationCounter
            
            region = _.clone regionOptions
            regions.push region
            
            # Generate strokes from detected elements.
            pixelArtEvaluationStrokes = @constructor.getStrokesFromPixelArtEvaluation @pixelArtEvaluation, region.bounds
            continue unless pixelArtEvaluationStrokes.length
            
            # Convert strokes into input data for the classifiers.
            @_classificationInputData[regionIndex] ?= {}
            @_classificationInputData[regionIndex].pixelArtEvaluation ?= new Float32Array inputSize * inputSize
            PAA.ImageClassification.SimpleClassifier.convertStrokesToInputData pixelArtEvaluationStrokes, @_classificationInputData[regionIndex].pixelArtEvaluation

            # Run classification.
            classificationPromises = for classifierType, classifier of @classifiers
              do (classifierType, classifier) =>
                new Promise (resolve, reject) =>
                  labelProbabilities = await classifier.classify @_classificationInputData[regionIndex].pixelArtEvaluation
                  resolve {classifierType, labelProbabilities}
          
            pixelArtEvaluationClassifierResults = await Promise.all classificationPromises
            return unless classificationCounter is @_classificationCounter
            
            # Retry classification with depixelized strokes.
            depixelizerStrokes = []
            
            imageData = @_depixelizerSourceCanvas.getFullImageData()
            
            for x in [@bitmap.bounds.left..@bitmap.bounds.right]
              for y in [@bitmap.bounds.top..@bitmap.bounds.bottom]
                canvasX = x - @bitmap.bounds.left + 1
                canvasY = y - @bitmap.bounds.top + 1
                
                dataIndex = (canvasX + canvasY * imageData.width) * 4 + 3
                imageData.data[dataIndex] = 0
                
                if region.bounds
                  # Skip the pixel if it isn't in the region bounds.
                  continue unless region.bounds.x <= x < region.bounds.x + region.bounds.width
                  continue unless region.bounds.y <= y < region.bounds.y + region.bounds.height
                
                if @bitmap.findPixelAtAbsoluteCoordinates x, y
                  imageData.data[dataIndex] = 255

            @_depixelizerSourceCanvas.putFullImageData imageData
            
            splines = AS.PixelArt.Upscaling.Depixelizer.getBSplines @_depixelizerSourceCanvas
            
            for spline in splines
              depixelizerStrokes.push spline.getPolygonalChain 4
            
            @_classificationInputData[regionIndex].depixelizer ?= new Float32Array inputSize * inputSize
            PAA.ImageClassification.SimpleClassifier.convertStrokesToInputData depixelizerStrokes, @_classificationInputData[regionIndex].depixelizer

            # Run classification.
            classificationPromises = for classifierType, classifier of @classifiers
              do (classifierType, classifier) =>
                new Promise (resolve, reject) =>
                  labelProbabilities = await classifier.classify @_classificationInputData[regionIndex].depixelizer
                  resolve {classifierType, labelProbabilities}
          
            depixelizerClassifierResults = await Promise.all classificationPromises
            return unless classificationCounter is @_classificationCounter
            
            maxTargetProbability = (classifierResults) =>
              targetProbability = 0
              
              for classifierResult in classifierResults
                targetLabelProbability = _.find classifierResult.labelProbabilities, (labelProbability) => labelProbability.label is region.targetLabel
                targetProbability = Math.max targetProbability, targetLabelProbability.probability
              
              targetProbability
            
            depixelizerResultIsBetter = maxTargetProbability(depixelizerClassifierResults) > maxTargetProbability(pixelArtEvaluationClassifierResults)
            
            if depixelizerResultIsBetter
              classifierResults = depixelizerClassifierResults
              @_classificationInputData[regionIndex].better = @_classificationInputData[regionIndex].depixelizer
              
            else
              classifierResults = pixelArtEvaluationClassifierResults
              @_classificationInputData[regionIndex].better = @_classificationInputData[regionIndex].pixelArtEvaluation
            
            # Store label probabilities into the region.
            region.labels = {}
            
            for classifierResult in classifierResults
              region.labels[classifierResult.classifierType] = classifierResult.labelProbabilities
              
          # The analysis completed without being cancelled due to a re-run so save new results.
          @regions = regions
          @analyzing false
          @_classificationDependency.changed()

    # Subscribe to changes of the readability property.
    LOI.Assets.Bitmap.versionedDocuments.operationsExecuted.addHandler @, @onOperationsExecuted
  
  destroy: ->
    @_classificationAutorun.stop()
    
    @pixelArtEvaluation.destroy()

    LOI.Assets.Bitmap.versionedDocuments.operationsExecuted.removeHandler @, @onOperationsExecuted
    
  depend: ->
    @_classificationDependency.depend()

  onOperationsExecuted: (document, operations, changedFields) ->
    return unless document._id is @bitmap._id
    return unless changedFields.properties?.readabilityAnalysis
    
    @regionsOptions @_extractRegionsOptions document
    
  _extractRegionsOptions: (bitmap) ->
    return {} unless regions = bitmap.properties?.readabilityAnalysis?.regions
    
    for region in regions
      _.pick region, 'targetLabel', 'bounds'
