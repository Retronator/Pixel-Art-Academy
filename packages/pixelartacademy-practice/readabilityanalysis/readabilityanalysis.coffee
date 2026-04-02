AE = Artificial.Everywhere
AP = Artificial.Pyramid
AS = Artificial.Spectrum
AM = Artificial.Mirage
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

class PAA.Practice.ReadabilityAnalysis
  # passes: boolean if all regions are readable
  # regions: an array of parts of the bitmap on which to do the analysis
  #   targetLabel: the label that the region should convey
  #   passes: boolean if the region is readable
  #   recognition:
  #     passes: boolean if the target label is recognized correctly
  #   bounds: the bounds of the region in the bitmap, if not covering the whole bitmap
  #     x, y, width, height
  #   drawnBounds: the bounds inside the region where pixels have been placed, not stored in the asset
  #     x, y, width, height
  #   labels: the analysis of which labels get recognized in the image
  #     symbolic, realistic: arrays of label probabilities sorted by probability descending (only labels with 1% and up probability stored in the asset)
  #       label: string with the name
  #       probability: number between 0 and 1 how likely this label is drawn, not stored in the asset
  #       probabilityPercentage: integer between 1 and 100
  #   strokes: an array of analyses for each stroke's importance, not stored in the asset
  #     vertices: the points that make this stroke
  #     labels: the analysis of which labels get recognized in the image when this line is omitted
  #       symbolic, realistic: arrays of label probabilities sorted by probability descending
  #     probabilityChange: the analysis how much the target label's probability changes when this line is omitted
  #       symbolic, realistic: the probability difference between the image without and with this line
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
            pixelArtEvaluationStrokes = []
            
            for layer in @pixelArtEvaluation.layers
              # Convert lines into polygonal chains.
              for line in layer.lines
                if region.bounds
                  lineBounds = line.getPixelBounds()
                  
                  # Skip line if it doesn't intersect with region bounds
                  continue if lineBounds.maxX < region.bounds.x
                  continue if lineBounds.maxY < region.bounds.y
                  continue if lineBounds.minX >= region.bounds.x + region.bounds.width
                  continue if lineBounds.minY >= region.bounds.y + region.bounds.height
                
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
                      end = getPoint pointIndex + 1
                      vertices.push end.position
                
                pixelArtEvaluationStrokes.push new AP.PolygonalChain vertices
              
              # Convert points into (dummy) polygonal chains.
              for point in layer.points when not point.lines.length
                if region.bounds
                  # Skip point if it doesn't lie in region bounds
                  continue unless 0 <= point.x - region.bounds.x < region.bounds.width
                  continue unless 0 <= point.y - region.bounds.y < region.bounds.width
                
                vertex = new THREE.Vector2 point.pixels[0].x, point.pixels[0].y
                pixelArtEvaluationStrokes.push new AP.PolygonalChain [vertex, vertex]
            
            continue unless pixelArtEvaluationStrokes.length
            
            # Convert strokes into input data for the classifiers.
            @_classificationInputData[regionIndex] ?= []
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
            
            drawnMinX = Number.POSITIVE_INFINITY
            drawnMaxX = Number.NEGATIVE_INFINITY
            drawnMinY = Number.POSITIVE_INFINITY
            drawnMaxY = Number.NEGATIVE_INFINITY
            
            for x in [@bitmap.bounds.left..@bitmap.bounds.right]
              for y in [@bitmap.bounds.top..@bitmap.bounds.bottom]
                bitmapX = x - @bitmap.bounds.left + 1
                bitmapY = y - @bitmap.bounds.top + 1
                
                dataIndex = ((x + 1) + (y + 1) * imageData.width) * 4 + 3
                imageData.data[dataIndex] = 0
                
                if region.bounds
                  # Skip the pixel if it isn't in the region bounds.
                  continue unless region.bounds.x <= x < region.bounds.x + region.bounds.width
                  continue unless region.bounds.y <= y < region.bounds.y + region.bounds.height
                
                if @bitmap.findPixelAtAbsoluteCoordinates x, y
                  imageData.data[dataIndex] = 255

                  drawnMinX = Math.min drawnMinX, bitmapX
                  drawnMaxX = Math.max drawnMaxX, bitmapX
                  drawnMinY = Math.min drawnMinY, bitmapY
                  drawnMaxY = Math.max drawnMaxY, bitmapY
                  
            region.drawnBounds =
              x: drawnMinX
              y: drawnMinY
              width: drawnMaxX - drawnMinX + 1
              height: drawnMaxY - drawnMinY + 1
            
            @_depixelizerSourceCanvas.putFullImageData imageData
            
            splines = AS.PixelArt.Upscaling.Depixelizer.getBSplines @_depixelizerSourceCanvas
            
            for spline in splines
              depixelizerStrokes.push spline.getPolygonalChain 4
            
            # Keep merging strokes that share endpoints until no more joins are possible.
            mergeOccurred = true
            
            while mergeOccurred
              mergeOccurred = false
              
              for strokeA, strokeIndexA in depixelizerStrokes
                break if mergeOccurred
                
                firstA = _.first strokeA.vertices
                lastA = _.last strokeA.vertices
                
                for strokeB, strokeIndexB in depixelizerStrokes
                  continue if strokeIndexB <= strokeIndexA
                  
                  firstB = _.first strokeB.vertices
                  lastB = _.last strokeB.vertices
                  
                  if lastA.equals firstB
                    strokeA.vertices.push strokeB.vertices[1..]...
                    
                  else if firstA.equals lastB
                    strokeA.vertices.unshift strokeB.vertices[0..-2]...
                    
                  else if lastA.equals lastB
                    strokeA.vertices.push strokeB.vertices[0..-2].reverse()...
                    
                  else if firstA.equals firstB
                    strokeA.vertices.unshift strokeB.vertices[1..].reverse()...
                    
                  else
                    continue
                  
                  depixelizerStrokes.splice strokeIndexB, 1
                  mergeOccurred = true
                  break
              
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
              strokes = depixelizerStrokes
              classifierResults = depixelizerClassifierResults
              @_classificationInputData[regionIndex][0] = @_classificationInputData[regionIndex].depixelizer
              
            else
              strokes = pixelArtEvaluationStrokes
              classifierResults = pixelArtEvaluationClassifierResults
              @_classificationInputData[regionIndex][0] = @_classificationInputData[regionIndex].pixelArtEvaluation
            
            # Store label probabilities into the region.
            region.labels = {}
            
            for classifierResult in classifierResults
              region.labels[classifierResult.classifierType] = classifierResult.labelProbabilities
              
            # Analyze the importance of each stroke, by running classification again without that stroke.
            strokesWithoutOmittedStroke = strokes[1..]
            
            # We need to calculate the probability change for the target class,
            # so first find what the probability is with all the strokes.
            targetClassProbability = {}
            
            for classifierType, labelProbabilities of region.labels
              labelProbabilityWithLine = _.find labelProbabilities, (labelProbability) => labelProbability.label is region.targetLabel
              targetClassProbability[classifierType] = labelProbabilityWithLine.probability

            # Analyze each stroke.
            region.strokes = []
            
            for stroke, omittedStrokeIndex in strokes
              inputDataIndex = 1
              
              # When debugging, store each individual input data so we can see them for debugging purposes.
              inputDataIndex += omittedStrokeIndex if PAA.PixelPad.Apps.Drawing.Editor.Desktop.ReadabilityAnalysis.debug
              @_classificationInputData[regionIndex][inputDataIndex] ?= new Float32Array inputSize * inputSize
              PAA.ImageClassification.SimpleClassifier.convertStrokesToInputData strokesWithoutOmittedStroke, @_classificationInputData[regionIndex][inputDataIndex]
              
              # Run classification.
              classificationPromises = for classifierType, classifier of @classifiers
                do (classifierType, classifier) =>
                  new Promise (resolve, reject) =>
                    labelProbabilities = await classifier.classify @_classificationInputData[regionIndex][inputDataIndex]
                    resolve {classifierType, labelProbabilities}
            
              classifierResults = await Promise.all classificationPromises
              return unless classificationCounter is @_classificationCounter
              
              # Store stroke analysis into the region.
              displayVertexOffset = if depixelizerResultIsBetter then -1 else 0.5
              
              strokeAnalysis =
                vertices: for vertex in stroke.vertices
                  x: vertex.x + displayVertexOffset
                  y: vertex.y + displayVertexOffset
                labels: {}
                probabilityChange: {}

              region.strokes[omittedStrokeIndex] = strokeAnalysis
              
              for classifierResult in classifierResults
                # Store all label probabilities.
                strokeAnalysis.labels[classifierResult.classifierType] = classifierResult.labelProbabilities
                
                # Calculate the probability change for the target class.
                labelProbabilityWithoutLine = _.find classifierResult.labelProbabilities, (labelProbability) => labelProbability.label is region.targetLabel
                strokeAnalysis.probabilityChange[classifierResult.classifierType] = targetClassProbability[classifierResult.classifierType] - labelProbabilityWithoutLine.probability

              # Put back the stroke that was omitted, in place of the next omitted stroke.
              strokesWithoutOmittedStroke[omittedStrokeIndex] = strokes[omittedStrokeIndex]
              
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
