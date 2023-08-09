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
    
  @getPanForElement: (element) ->
    boundingRectangle = element.getBoundingClientRect()
    elementCenter = boundingRectangle.left + boundingRectangle.width / 2
    
    elementCenter / window.innerWidth * 2 - 1
