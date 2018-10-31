AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.Node.Parameter extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.AudioEditor.Node.Parameter'
  @register @id()
  
  constructor: (@options) ->
    super arguments...

  onCreated: ->
    super arguments...
    
    @dataInput = new @constructor.DataInput @options

  class @DataInput extends AM.DataInputComponent
    @register 'LandsOfIllusions.Assets.AudioEditor.Node.Parameter.DataInput'

    constructor: (@options) ->
      super arguments...

      if typeof @options.pattern is String
        @type = AM.DataInputComponent.Types.Text

    load: ->
      @options.load()

    save: (value) ->
      @options.save value
