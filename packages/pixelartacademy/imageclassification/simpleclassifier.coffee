AM = Artificial.Mirage
PAA = PixelArtAcademy

ONNX = require 'onnxruntime-web'

_normalizationMatrix = new THREE.Matrix3
_scaledVertex = new THREE.Vector2

class PAA.ImageClassification.SimpleClassifier
  @modelPath: -> AE.NotImplementedException "Classifier must specify the path to the model file."
  
  # Drawings need to be normalized into a 64×64 canvas with the drawing scaled into the 60×60 area.
  @inputSize = 64
  @targetSize = 60
  @tensorShape = [1, 64, 64, 1]
  @labels = ['airplane','alarm clock','ant','apple','axe','banana','bat','bear','bee','bench','bicycle','bread',
    'butterfly','camel','candle','cannon','car','castle','cat','chair','church','couch','cow','crab','cup','dog',
    'dolphin','door','duck','elephant','eyeglasses','fan','fish','flower','frog','giraffe','guitar','hamburger',
    'hammer','harp','hat','hedgehog','helicopter','horse','hot air balloon','hourglass','kangaroo','knife','lion',
    'lobster','mouse','mushroom','owl','parrot','pear','penguin','piano','pickup truck','pig','pineapple','pizza',
    'rabbit','raccoon','rhinoceros','rifle','sailboat','saw','saxophone','scissors','scorpion','turtle','shark',
    'sheep','shoe','skyscraper','snail','snake','spider','spoon','squirrel','strawberry','swan','sword','table',
    'teapot','teddy bear','tiger','tree','trumpet','umbrella','violin','windmill','bottle','zebra']

  @convertStrokesToInputData: (strokes, inputData) ->
    # Find bounds of the drawn area.
    minX = Number.POSITIVE_INFINITY
    minY = Number.POSITIVE_INFINITY
    maxX = Number.NEGATIVE_INFINITY
    maxY = Number.NEGATIVE_INFINITY
    
    for stroke in strokes
      for vertex in stroke.vertices
        minX = Math.min minX, vertex.x
        minY = Math.min minY, vertex.y
        maxX = Math.max maxX, vertex.x
        maxY = Math.max maxY, vertex.y
    
    # Make sure something was drawn.
    return if minX > maxX or minY > maxY
    
    # Move drawing to origin.
    _normalizationMatrix.makeTranslation -minX, -minY
    
    # Scale to target size.
    sourceWidth = (maxX - minX) or 1
    sourceHeight = (maxY - minY) or 1
    
    targetWidth = if sourceWidth > sourceHeight then @targetSize else @targetSize * sourceWidth / sourceHeight
    targetHeight = targetWidth / sourceWidth * sourceHeight
    
    _normalizationMatrix.scale targetWidth / sourceWidth, targetHeight / sourceHeight
    
    # Center in the input area.
    originX = (@inputSize - targetWidth) / 2
    originY = (@inputSize - targetHeight) / 2
    
    _normalizationMatrix.translate originX, originY
    
    # Redraw the normalized strokes.
    unless @_normalizedCanvas
      @_normalizedCanvas = new AM.ReadableCanvas @inputSize, @inputSize
      @_normalizedContext = @_normalizedCanvas.context
      @_normalizedContext.lineWidth = 2
      @_normalizedContext.strokeStyle = '#000000'
      @_normalizedContext.lineCap = 'round'
      @_normalizedContext.lineJoin = 'round'
    
    @_normalizedContext.clearRect 0, 0, @inputSize, @inputSize
    
    for stroke in strokes
      @_normalizedContext.beginPath()
      
      # Move to first point
      _scaledVertex.copy(stroke.vertices[0]).applyMatrix3 _normalizationMatrix
      @_normalizedContext.moveTo _scaledVertex.x, _scaledVertex.y
      
      # Draw lines to remaining points
      for vertex in stroke.vertices
        _scaledVertex.copy(vertex).applyMatrix3 _normalizationMatrix
        @_normalizedContext.lineTo _scaledVertex.x, _scaledVertex.y
      
      @_normalizedContext.stroke()
    
    # Extract alpha channel into the input array for classification.
    normalizedImageData = @_normalizedCanvas.getFullImageData()
    
    for x in [0...@inputSize]
      for y in [0...@inputSize]
        pixelIndex = y * @inputSize + x
        inputData[pixelIndex] = normalizedImageData.data[pixelIndex * 4 + 3]
    
    inputData
  
  constructor: ->
    @inferenceSession = new ReactiveField null
  
  createInferenceSession: ->
    ONNX.env.wasm.wasmPaths = Meteor.absoluteUrl '/artificial/mind/onnx/'
    ONNX.env.wasm.simd = true
    ONNX.env.wasm.proxy = true
    
    inferenceSession = await ONNX.InferenceSession.create(
      Meteor.absoluteUrl @constructor.modelPath()
    ,
      executionProviders: ['wasm']
    )
    
    @inferenceSession inferenceSession
  
  ready: ->
    @inferenceSession()
    
  classify: (inputData) ->
    inferenceSession = @inferenceSession()
    
    inputSize = @constructor.inputSize
    labels = @constructor.labels
    
    inputTensorData = new Float32Array inputSize * inputSize
    inputTensorData.set inputData
    
    inputTensor = new ONNX.Tensor 'float32', inputTensorData, @constructor.tensorShape
    output = await inferenceSession.run "#{inferenceSession.inputNames[0]}": inputTensor
    logits = Array.from output[inferenceSession.outputNames[0]].data
    
    labelProbabilities = for logit, labelIndex in logits
      label: labels[labelIndex]
      probability: logit
    
    _.sortBy labelProbabilities, (labelProbability) => -labelProbability.probability
    
  class @Symbolic extends @
    @modelPath: -> '/pixelartacademy/imageclassification/simpleclassifier/quickdraw.onnx'

  class @Realistic extends @
    @modelPath: -> '/pixelartacademy/imageclassification/simpleclassifier/sketchy.onnx'
