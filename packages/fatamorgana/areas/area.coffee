AM = Artificial.Mirage
FM = FataMorgana

class FM.Area extends AM.Component
  @dimensionProperties: ['left', 'right', 'top', 'bottom', 'width', 'height', 'minWidth', 'minHeight']

  template: -> 'FataMorgana.Area'

  onCreated: ->
    super arguments...

    @interface = @ancestorComponentOfType FM.Interface
    
    # Isolate type and component ID to minimize reactivity.
    @type = new ComputedField => @data().get 'type'
    @contentComponentId = new ComputedField => @data().get 'contentComponentId'

  areaClass: -> # Override to set a styling class for this area.

  areaStyle: ->
    options = @data().value()

    style = _.pick options, @constructor.dimensionProperties

    if style.width and options.widthStep
      style.width = Math.round(style.width / options.widthStep) * options.widthStep

    for property, value of style when _.isNumber value
      style[property] = "#{value}rem"

    style

  contentComponentData: ->
    @data().get('contentComponentData') or @interface.getComponentData @contentComponentId()
