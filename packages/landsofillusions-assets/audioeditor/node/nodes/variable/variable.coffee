AB = Artificial.Babel
AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.Node.Variable extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.AudioEditor.Node.Variable'
  @register @id()
  
  @initializeDataComponent()
  
  constructor: (@node) ->
    super arguments...

  onCreated: ->
    super arguments...

    @audioNode = new ComputedField =>
      return unless audio = @node.audioCanvas.audio()
      audio.getNode @node.id
      
    @variable = new ComputedField =>
      return unless id = @audioNode()?.readParameter 'id'
      AEc.Variable.getVariableForId id
      
    @namespace = new ReactiveField null
    @name = new ReactiveField null
    
    # Fill out the namespace and name when ID changes.
    @autorun (computation) =>
      return unless id = @audioNode()?.readParameter 'id'
      
      # Only react to ID changes.
      Tracker.nonreactive =>
        lastDotIndex = id.lastIndexOf('.')
        @namespace id[...lastDotIndex]
        @name id[lastDotIndex + 1..]
        
    # Set ID when namespace or name changes.
    @autorun (computation) =>
      return unless namespace = @namespace()
      return unless name = @name()
      
      # Only react to namespace and name changes.
      Tracker.nonreactive =>
        return unless id = @audioNode()?.readParameter 'id'
        newId = "#{namespace}.#{name}"
        return if newId is id
        
        @node.audioCanvas.audioLoader().changeNodeParameter @node.id, 'id', newId
        
    @namespaces = _.uniq (id[...id.lastIndexOf('.')] for id in AEc.Variable.getVariableIds())
    
  events: ->
    super(arguments...).concat
      'click .trigger-button': @onClickTriggerButton
  
  onClickTriggerButton: (event) ->
    return unless variable = @variable()
    variable()

  class @Namespace extends @DataInputComponent
    @register 'LandsOfIllusions.Assets.AudioEditor.Node.Variable.Namespace'
    
    constructor: ->
      super arguments...
      
      @propertyName = 'namespace'
      @type = AM.DataInputComponent.Types.Select
    
    options: ->
      options = for namespace in @dataProviderComponent.namespaces
        value: namespace
        name: namespace
      
      options = _.sortBy options, 'name'
      
      options.unshift
        value: null
        name: ''

      options
  
  class @Name extends @DataInputComponent
    @register 'LandsOfIllusions.Assets.AudioEditor.Node.Variable.Name'
    
    constructor: ->
      super arguments...
      
      @propertyName = 'name'
      @type = AM.DataInputComponent.Types.Select
    
    options: ->
      options = [
        value: null
        name: ''
      ]
      
      return options unless namespace = @dataProviderComponent.namespace()
      
      for id in AEc.Variable.getVariableIds() when _.startsWith id, namespace
        name = id[id.lastIndexOf('.') + 1..]
        
        options.push
          value: name
          name: name
      
      _.sortBy options, 'name'
