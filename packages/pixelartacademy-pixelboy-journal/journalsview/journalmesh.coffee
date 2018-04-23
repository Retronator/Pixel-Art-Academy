AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Journal.JournalsView.JournalMesh extends THREE.Mesh
  constructor: (@sceneManager, @journal) ->
    switch @journal.design.size
      when PAA.Practice.Journal.Design.Size.Small
        @width = 20
        @height = 30
      when PAA.Practice.Journal.Design.Size.Medium
        @width = 30
        @height = 40
      when PAA.Practice.Journal.Design.Size.Large
        @width = 40
        @height = 60

    if @journal.design.orientation is PAA.Practice.Journal.Design.Orientation.Landscape
      [@width, @height] = [@height, @width]

    geometry = new THREE.BoxGeometry @width, 2, @height

    material = new THREE.MeshPhongMaterial color: 0

    Tracker.autorun (computation) =>
      return unless palette = LOI.Assets.Palette.defaultPalette()
      coverColor = @journal.design.cover.color
      material.color = THREE.Color.fromObject palette.ramps[coverColor.hue].shades[coverColor.shade]
      material.needsUpdate = true
    
    super geometry, material
    
    @position.y = 1
    @position.x = 0
    @position.z = -@height / 2
    @castShadow = true

    # Dummy DOM element to run velocity on.
    @$animate = $('<div>')

  destroy: ->
    @geometry.dispose()
    @material.dispose()
    
  hover: ->
    @_moveYTo 2, 200
    
  unhover: ->
    @_moveYTo 1, 200

  _moveYTo: (targetY, duration) ->
    @_startingY = @position.y
    @_deltaY = targetY - @_startingY

    @$animate.velocity('stop', 'moveY').velocity
      tween: [1, 0]
    ,
      duration: duration
      easing: 'ease-out'
      queue: 'moveY'
      progress: (elements, complete, remaining, current, tweenValue) =>
        @position.y = @_startingY + @_deltaY * tweenValue
        @sceneManager.scene.updated()

    @$animate.dequeue('moveY')

  activate: ->
    @_moveZTo 30 + @height / 2, 500, 'ease-in'

  deactivate: ->
    # Wait until the journal view transitions out first.
    Meteor.setTimeout =>
      @_moveZTo -@height / 2, 500, 'ease-out'
    ,
      500

  _moveZTo: (targetZ, duration, easing) ->
    @_startingZ = @position.z
    @_deltaZ = targetZ - @_startingZ

    @$animate.velocity('stop', 'moveZ').velocity
      tween: [1, 0]
    ,
      duration: duration
      easing: easing
      queue: 'moveZ'
      progress: (elements, complete, remaining, current, tweenValue) =>
        @position.z = @_startingZ + @_deltaZ * tweenValue
        @sceneManager.scene.updated()

    @$animate.dequeue('moveZ')
