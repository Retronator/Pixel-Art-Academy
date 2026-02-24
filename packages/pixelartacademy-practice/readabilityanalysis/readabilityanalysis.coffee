AE = Artificial.Everywhere
AP = Artificial.Pyramid
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

class PAA.Practice.ReadabilityAnalysis
  # passes: boolean if all regions are readable
  # regions: an array of parts of the bitmap on which to do the analysis
  #   targetLabel: the label that the region should convey
  #   passes: boolean if the region is readable
  #   recognition:
  #     passes: boolean if the target label is recognized correctly
  #   bounds: the bounds of the region in the bitmap, not stored in the asset
  #     x, y, width, height
  #   labels: the analysis of which labels get recognized in the image
  #     symbolic, realistic: arrays of label probabilities sorted by probability descending (only labels with 1% and up probability stored in the asset)
  #       label: string with the name
  #       probability: number between 0 and 1 how likely this label is drawn, not stored in the asset
  #       probabilityPercentage: integer between 1 and 100
  #   lines: an array of analyses for each line's importance, not stored in the asset
  #     line: the line object from the pixel art evaluation
  #     labels: the analysis of which labels get recognized in the image when this line is omitted
  #       symbolic, realistic: arrays of label probabilities sorted by probability descending
  #     probabilityChange: the analysis how much the target label's probability changes when this line is omitted
  #       symbolic, realistic: the probability difference between the image without and with this line
  constructor: (@bitmap, @options = {}) ->
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
    
    @regionsOptions = new AE.LiveComputedField =>
      _.resolve @options.regions
    ,
      EJSON.equals
    
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
            
            region =
              targetLabel: regionOptions.label
              bounds: regionOptions.bounds
            
            regions.push region
            
            # Generate strokes from detected elements.
            strokes = []
            elements = []
            
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
                
                strokes.push new AP.PolygonalChain vertices
                elements.push line
              
              # Convert points into (dummy) polygonal chains.
              for point in layer.points when not point.lines.length
                if region.bounds
                  # Skip point if it doesn't lie in region bounds
                  continue unless 0 <= point.x - region.bounds.x < region.bounds.width
                  continue unless 0 <= point.y - region.bounds.y < region.bounds.width
                
                vertex = {x: point.pixels[0].x, y: point.pixels[0].y}
                strokes.push new AP.PolygonalChain [vertex, vertex]
                elements.push point
            
            continue unless strokes.length
            
            # Convert strokes into input data for the classifiers.
            @_classificationInputData[regionIndex] ?= []
            @_classificationInputData[regionIndex][0] ?= new Float32Array inputSize * inputSize
            PAA.ImageClassification.SimpleClassifier.convertStrokesToInputData strokes, @_classificationInputData[regionIndex][0]

            # Run classification.
            classificationPromises = for classifierType, classifier of @classifiers
              do (classifierType, classifier) =>
                new Promise (resolve, reject) =>
                  labelProbabilities = await classifier.classify @_classificationInputData[regionIndex][0]
                  resolve {classifierType, labelProbabilities}
          
            classifierResults = await Promise.all classificationPromises
            return unless classificationCounter is @_classificationCounter
            
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
              strokeAnalysis =
                element: elements[omittedStrokeIndex]
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

  destroy: ->
    @_classificationAutorun.stop()
    
    @regionsOptions.stop()
    @pixelArtEvaluation.destroy()
    
  depend: ->
    @_classificationDependency.depend()
