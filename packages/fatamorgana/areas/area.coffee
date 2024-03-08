AM = Artificial.Mirage
FM = FataMorgana

class FM.Area extends AM.Component
  @id: -> 'FataMorgana.Area'
  @register @id()
  
  @dimensionProperties: ['left', 'right', 'top', 'bottom', 'width', 'height', 'minWidth', 'minHeight']

  template: -> @constructor.id()

  onCreated: ->
    super arguments...

    @interface = @ancestorComponentOfType FM.Interface
    
    # Isolate data values to minimize reactivity.
    @type = new ComputedField => @data().get 'type'
    @contentComponentId = new ComputedField => @data().get 'contentComponentId'
    @contentComponentData = new ComputedField => @data().get 'contentComponentData'

  areaClass: -> # Override to set a styling class for this area.
  
  childComponentOverridesSize: ->
    return unless childComponent = @childComponents()[0]
    childComponent?.overrideAreaSize?()

  areaStyle: ->
    # We should not fix the area size if a child component asks to control it instead.
    return {} if @childComponentOverridesSize()
    
    options = @data().value()

    style = _.pick options, @constructor.dimensionProperties

    if style.width and options.widthStep
      style.width = Math.round(style.width / options.widthStep) * options.widthStep

    for property, value of style when _.isNumber value
      style[property] = "#{value}rem"

    style

  renderContentComponent: ->
    # Code adapted from the AM.Render component.
    component = @interface.getComponent @contentComponentId()
    return null unless component
    
    if component._blazeTemplate and not component.isDestroyed()
      return null if component.isRendered() and (component.parentComponent() isnt @)
      
      return component._blazeTemplate
    
    component._blazeTemplate = component.renderComponent? @currentComponent()
  
  componentData: ->
    # We allow sending custom component data for particular instances (such as for dialogs).
    if contentComponentData = @contentComponentData()
      return contentComponentData

    # Otherwise get global data from the interface.
    return unless contentComponentId = @contentComponentId()
    @interface.getComponentData contentComponentId
