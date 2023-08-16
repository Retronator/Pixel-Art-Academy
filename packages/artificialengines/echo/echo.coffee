class Artificial.Echo
  @debug = false
  
  @ConnectionTypes =
    Channels: 'Channels'
    Parameter: 'Parameter'
    ReactiveValue: 'ReactiveValue'
  
  @ValueTypes =
    Buffer: 'Buffer'
    Trigger: 'Trigger'
    Boolean: 'Boolean'
    Number: 'Number'
    String: 'String'
  
  @getPanForPosition = (x) ->
    x / window.innerWidth * 2 - 1
    
  @getPanForElement = (element) ->
    boundingRectangle = element.getBoundingClientRect()
    elementCenter = boundingRectangle.left + boundingRectangle.width / 2
    @getPanForPosition elementCenter
