AEc = Artificial.Echo
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio.Nodes.ModalDialog extends AEc.Node
  @type: -> 'LandsOfIllusions.Assets.Engine.Audio.Nodes.ModalDialog'
  @displayName: -> 'Modal Dialog'

  @initialize()

  @outputs: -> [
    name: 'value'
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Boolean
  ]

  @parameters: ->
    options = for componentClass in AM.Component.getClasses()
      name = componentClass.componentName()

      name: name
      value: name

    options = _.sortBy options, 'value'
    options.unshift
      name: 'Any'
      value: '_any'
    
    [
      name: 'name'
      pattern: [String]
      options: options
      type: AEc.ConnectionTypes.ReactiveValue
      valueType: AEc.ValueTypes.String
    ]

  constructor: ->
    super arguments...

    @value = new ComputedField =>
      return unless componentNames = @readParameter 'name'

      # Create an array if needed.
      componentNames = [componentNames] unless _.isArray componentNames

      # Dialog value is true if one of the components is displayed as a modal dialog.
      modalDialogs = LOI.adventure.modalDialogs()
      
      return true if modalDialogs.length and '_any' in componentNames
      
      for modalDialog in modalDialogs
        return true if modalDialog.dialog.constructor.componentName() in componentNames
        
      false
    ,
      true
    
  destroy: ->
    super arguments...
    
    @value.stop()

  getReactiveValue: (output) ->
    return super arguments... unless output is 'value'
    
    @value
