AE = Artificial.Everywhere
AM = Artificial.Mirage
PAA = PixelArtAcademy

ONNX = require 'onnxruntime-web'

class PAA.Pages.ImageClassification.Classifier
  @modelPath: -> AE.NotImplementedException "Classifier must specify the path to the model file."
  @inputSize: -> AE.NotImplementedException "Classifier must specify how big the input is."
  @targetSize: -> AE.NotImplementedException "Classifier must specify how big the image should be resized."
  @labelsPath: -> null # Override to specify the document to load the labels from.
  @labels: -> null # Override to directly specify the labels.
  @performSoftmax: -> false # Override if softmax should be performed on the output.
  @valueScale: -> 1 / 255

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
    if labels = @constructor.labels()
      @labels labels
      return
      
    labelsPath = @constructor.labelsPath()
    
    try
      response = await fetch Meteor.absoluteUrl(labelsPath)
      data = await response.json()
      @labels data
    
    catch error
      console.error "Error loading labels from #{labelsPath}", error
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
    @modelPath: -> '/pixelartacademy/imageclassification/sketchy_cnn.onnx'
    @inputSize: -> 64
    @targetSize: -> 50
    @tensorShape: -> [1, 64, 64, 1]
    @labels: -> ['airplane', 'alarm_clock', 'ant', 'ape', 'apple', 'armor', 'axe', 'banana', 'bat', 'bear', 'bee',
      'beetle', 'bell', 'bench', 'bicycle', 'blimp', 'bread', 'butterfly', 'cabin', 'camel', 'candle', 'cannon',
      'car', 'castle', 'cat', 'chair', 'chicken', 'church', 'couch', 'cow', 'crab', 'crocodilian', 'cup',
      'deer', 'dog', 'dolphin', 'door', 'duck', 'elephant', 'eyeglasses', 'fan', 'fish', 'flower', 'frog', 'geyser',
      'giraffe', 'guitar', 'hamburger', 'hammer', 'harp', 'hat', 'hedgehog', 'helicopter', 'hermit_crab', 'horse',
      'hot-air_balloon', 'hotdog', 'hourglass', 'jack-o-lantern', 'jellyfish', 'kangaroo', 'knife', 'lion', 'lizard',
      'lobster', 'motorcycle', 'mouse', 'mushroom', 'owl', 'parrot', 'pear', 'penguin', 'piano', 'pickup_truck', 'pig',
      'pineapple', 'pistol', 'pizza', 'pretzel', 'rabbit', 'raccoon', 'racket', 'ray', 'rhinoceros', 'rifle', 'rocket',
      'sailboat', 'saw', 'saxophone', 'scissors', 'scorpion', 'sea_turtle', 'seagull', 'seal', 'shark', 'sheep', 'shoe',
      'skyscraper', 'snail', 'snake', 'songbird', 'spider', 'spoon', 'squirrel', 'starfish', 'strawberry', 'swan',
      'sword', 'table', 'tank', 'teapot', 'teddy_bear', 'tiger', 'tree', 'trumpet', 'turtle', 'umbrella', 'violin',
      'volcano', 'wading_bird', 'wheelchair', 'windmill', 'window', 'wine_bottle', 'zebra']

  class @QuickDraw extends @
    @modelPath: -> '/pixelartacademy/imageclassification/quickdraw_cnn.onnx'
    @inputSize: -> 28
    @targetSize: -> 28
    @tensorShape: -> [1, 28, 28, 1]
    @labels: -> [
      "bowtie","windmill","tree","river","ice cream","eye","book","sun","star",
      "airplane","butterfly","clock","car","fish","face","umbrella","cat","bicycle",
      "pizza","house","cake","bucket","crown","light bulb","cell phone","t-shirt"
    ]
  
  class @QuickDrawXenova extends @
    @modelPath: -> '/pixelartacademy/imageclassification/quickdraw_xenova.onnx'
    @inputSize: -> 28
    @targetSize: -> 28
    @tensorShape: -> [1, 1, 28, 28]
    @labelsPath: -> '/pixelartacademy/imageclassification/quickdraw_xenova_labels.json'
    @performSoftmax: -> true
  
  class @QuickDrawMobileNet extends @
    @modelPath: -> '/pixelartacademy/imageclassification/quickdraw_mobilenet.onnx'
    @inputSize: -> 64
    @targetSize: -> 60
    @tensorShape: -> [1, 64, 64, 1]
    @valueScale: -> 1
    @labels: -> ["airplane","alarm clock","ant","apple","axe","banana","bat","bear","bee","bench","bicycle","bread",
      "butterfly","camel","candle","cannon","car","castle","cat","chair","church","couch","cow","crab","cup","dog",
      "dolphin","door","duck","elephant","eyeglasses","fan","fish","flower","frog","giraffe","guitar","hamburger",
      "hammer","harp","hat","hedgehog","helicopter","horse","hot air balloon","hourglass","kangaroo","knife","lion",
      "lobster","mouse","mushroom","owl","parrot","pear","penguin","piano","pickup truck","pig","pineapple","pizza",
      "rabbit","raccoon","rhinoceros","rifle","sailboat","saw","saxophone","scissors","scorpion","sea turtle","shark",
      "sheep","shoe","skyscraper","snail","snake","spider","spoon","squirrel","strawberry","swan","sword","table",
      "teapot","teddy bear","tiger","tree","trumpet","umbrella","violin","windmill","wine bottle","zebra"]
