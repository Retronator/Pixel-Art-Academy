AE = Artificial.Everywhere
AM = Artificial.Mirage
PAA = PixelArtAcademy

ONNX = require 'onnxruntime-web'

class PAA.Pages.ImageClassification.Classifier
  @modelPath: -> AE.NotImplementedException "Classifier must specify the path to the model file."
  @inputSize: -> 64
  @targetSize: -> 60
  @tensorShape: -> [1, 64, 64, 1]
  @labelsPath: -> null # Override to specify the document to load the labels from.
  @labels: -> ["airplane","alarm clock","ant","apple","axe","banana","bat","bear","bee","bench","bicycle","bread",
    "butterfly","camel","candle","cannon","car","castle","cat","chair","church","couch","cow","crab","cup","dog",
    "dolphin","door","duck","elephant","eyeglasses","fan","fish","flower","frog","giraffe","guitar","hamburger",
    "hammer","harp","hat","hedgehog","helicopter","horse","hot air balloon","hourglass","kangaroo","knife","lion",
    "lobster","mouse","mushroom","owl","parrot","pear","penguin","piano","pickup truck","pig","pineapple","pizza",
    "rabbit","raccoon","rhinoceros","rifle","sailboat","saw","saxophone","scissors","scorpion","sea turtle","shark",
    "sheep","shoe","skyscraper","snail","snake","spider","spoon","squirrel","strawberry","swan","sword","table",
    "teapot","teddy bear","tiger","tree","trumpet","umbrella","violin","windmill","wine bottle","zebra"]
  @performSoftmax: -> false # Override if softmax should be performed on the output.
  @valueScale: -> 1

  constructor: ->
    @inferenceSession = new ReactiveField null
    @labels = new ReactiveField null

    @loadLabels()
    
    inputSize = @constructor.inputSize()
    
    @inputCanvas = new AM.ReadableCanvas inputSize, inputSize
  
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
    
  loadLabels: ->
    if labelsPath = @constructor.labelsPath()
      try
        response = await fetch Meteor.absoluteUrl(labelsPath)
        data = await response.json()
        @labels data
      
      catch error
        console.error "Error loading labels from #{labelsPath}", error
        @labels []
        
      return
    
    if labels = @constructor.labels()
      @labels labels
      return
      
    @labels []
  
  ready: ->
    @inferenceSession() and @labels()
    
  classify: (strokes) ->
    inferenceSession = @inferenceSession()
    labels = @labels()
    
    # Find bounds of drawn area
    minX = Number.POSITIVE_INFINITY
    minY = Number.POSITIVE_INFINITY
    maxX = Number.NEGATIVE_INFINITY
    maxY = Number.NEGATIVE_INFINITY
    
    for stroke in strokes
      for {x, y} in stroke
        minX = Math.min minX, x
        minY = Math.min minY, y
        maxX = Math.max maxX, x
        maxY = Math.max maxY, y
    
    inputSize = @constructor.inputSize()
    targetSize = @constructor.targetSize()
    
    # Adjust if nothing was drawn
    if minX > maxX or minY > maxY
      minX = 0
      minY = 0
      maxX = inputSize
      maxY = inputSize
    
    @inputCanvas.context.clearRect 0, 0, inputSize, inputSize
    
    sourceWidth = maxX - minX
    sourceHeight = maxY - minY
    
    targetWidth = if sourceWidth > sourceHeight then targetSize else targetSize * sourceWidth / sourceHeight
    targetHeight = targetWidth / sourceWidth * sourceHeight

    # Draw the bounded area scaled to fit the input canvas
    originX = (inputSize - targetWidth) / 2
    originY = (inputSize - targetHeight) / 2
    
    # Scale strokes to fit target area
    scaleX = targetWidth / sourceWidth
    scaleY = targetHeight / sourceHeight
    
    @inputCanvas.context.lineWidth = 2
    @inputCanvas.context.strokeStyle = '#000000'
    @inputCanvas.context.lineCap = 'round'
    @inputCanvas.context.lineJoin = 'round'
    
    scalePoint = (point) =>
      x: (point.x - minX) * scaleX + originX
      y: (point.y - minY) * scaleY + originY
    
    for stroke in strokes
      continue unless stroke.length
      
      @inputCanvas.context.beginPath()
      
      # Move to first point
      firstPoint = scalePoint stroke[0]
      @inputCanvas.context.moveTo firstPoint.x, firstPoint.y
      
      # Draw lines to remaining points
      for point in stroke
        scaledPoint = scalePoint point
        @inputCanvas.context.lineTo scaledPoint.x, scaledPoint.y
      
      @inputCanvas.context.stroke()
    
    imageData = @inputCanvas.getFullImageData()
    inputData = new Float32Array inputSize * inputSize
    valueScale = @constructor.valueScale()
    
    for x in [0...inputSize]
      for y in [0...inputSize]
        pixelIndex = y * inputSize + x
        inputData[pixelIndex] = imageData.data[pixelIndex * 4 + 3] * valueScale
    
    inputTensor = new ONNX.Tensor 'float32', inputData, @constructor.tensorShape()
    output = await inferenceSession.run "#{inferenceSession.inputNames[0]}": inputTensor
    logits = Array.from output[inferenceSession.outputNames[0]].data
    
    labelProbabilities = for logit, labelIndex in logits
      label: labels[labelIndex]
      probability: logit
      
    if @constructor.performSoftmax()
      maxLogit = _.max logits
      expSum = 0
      expSum += Math.exp logit - maxLogit for logit in logits
      
      for labelProbability in labelProbabilities
        labelProbability.probability = Math.exp(labelProbability.probability - maxLogit) / expSum
    
    _.sortBy labelProbabilities, (labelProbability) => -labelProbability.probability
    
  class @Sketchy extends @
    @modelPath: -> '/pixelartacademy/imageclassification/sketchy.onnx'

  class @QuickDraw extends @
    @modelPath: -> '/pixelartacademy/imageclassification/quickdraw.onnx'
