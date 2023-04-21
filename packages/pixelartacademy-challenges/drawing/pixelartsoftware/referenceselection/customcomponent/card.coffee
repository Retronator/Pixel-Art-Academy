PAA = PixelArtAcademy

CustomComponent = PAA.Challenges.Drawing.PixelArtSoftware.ReferenceSelection.CustomComponent

class CustomComponent.Card
  @size = CustomComponent.cardSize
  @thickness = CustomComponent.cardThickness
  @shadowDirection = x: -4, y: 0.4
  
  constructor: (@id, @copyReferenceClass) ->
    @position = new THREE.Vector3
    @_updatedDependency = new Tracker.Dependency
    
  setPosition: (x, y = @position.y, z = @position.z) ->
    @position.set x, y, z
    @_updatedDependency.changed()
    
  reveal: ->
    @revealed true
    
  cardStyle: ->
    @_updatedDependency.depend()
    
    displayPosition = @_displayPosition()
  
    left: "#{displayPosition.left}rem"
    top: "#{displayPosition.top}rem"
    zIndex: Math.floor @position.z / @constructor.thickness
    
  _displayPosition: ->
    size = @constructor.size
  
    left: Math.floor @position.x - size.width / 2
    top: Math.floor @position.y - @position.z - size.height / 2
  
  shadowStyle: ->
    @_updatedDependency.depend()
    size = @constructor.size
    shadowDirection = @constructor.shadowDirection
  
    left: "#{Math.floor @position.x + shadowDirection.x * @position.z - size.width / 2 - 1}rem"
    top: "#{Math.floor @position.y + shadowDirection.y * @position.z - size.height / 2}rem"
    
  referenceStyle: ->
    size = @constructor.size
    dimensions = @copyReferenceClass.fixedDimensions()
    
    left: "#{Math.floor (size.width - dimensions.width) / 2}rem"
    top: "#{Math.floor (size.height - dimensions.height) / 2}rem"
    width: "#{dimensions.width}rem"
    height: "#{dimensions.height}rem"
    
  referenceUrl: ->
    @copyReferenceClass.goalImageUrl()
    
  frontUrl: ->
    @copyReferenceClass.references()[0].image.url
  
  evenYClass: ->
    'even-y' if @_displayPosition().top % 2 is 0
