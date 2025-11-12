AM = Artificial.Mirage
PAA = PixelArtAcademy

ONNX = require 'onnxruntime-web'

class PAA.Pixeltosh.Programs.DrawQuickly.Classifier
  @modelPath: -> AE.NotImplementedException "Classifier must specify the path to the model file."
  
  @inputSize = 64
  @tensorShape = [1, 64, 64, 1]
  @labels = ["airplane","alarm clock","ant","apple","axe","banana","bat","bear","bee","bench","bicycle","bread",
    "butterfly","camel","candle","cannon","car","castle","cat","chair","church","couch","cow","crab","cup","dog",
    "dolphin","door","duck","elephant","eyeglasses","fan","fish","flower","frog","giraffe","guitar","hamburger",
    "hammer","harp","hat","hedgehog","helicopter","horse","hot air balloon","hourglass","kangaroo","knife","lion",
    "lobster","mouse","mushroom","owl","parrot","pear","penguin","piano","pickup truck","pig","pineapple","pizza",
    "rabbit","raccoon","rhinoceros","rifle","sailboat","saw","saxophone","scissors","scorpion","turtle","shark",
    "sheep","shoe","skyscraper","snail","snake","spider","spoon","squirrel","strawberry","swan","sword","table",
    "teapot","teddy bear","tiger","tree","trumpet","umbrella","violin","windmill","bottle","zebra"]

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
    @modelPath: -> '/pixelartacademy/imageclassification/quickdraw.onnx'

  class @Realistic extends @
    @modelPath: -> '/pixelartacademy/imageclassification/sketchy.onnx'
