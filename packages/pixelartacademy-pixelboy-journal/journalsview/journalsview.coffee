AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Journal.JournalsView extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Journal.JournalsView'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  constructor: (@journal) ->
    super

    # Prepare all reactive fields.
    @renderer = new ReactiveField null
    @sceneManager = new ReactiveField null

    @camera = new AE.ReactiveWrapper null

  onCreated: ->
    super

    @autorun =>
      PAA.Practice.Journal.forCharacterId.subscribe @, LOI.characterId()

    @sceneManager new @constructor.SceneManager @

    camera = new THREE.PerspectiveCamera 90, 1, 0.001, 1000
    camera.position.set 0, 30, 40
    camera.rotation.x = -0.5
    camera.updateProjectionMatrix()
    @camera camera

    @renderer new @constructor.Renderer @

  onRendered: ->
    super

    # Handle resize of mesh canvas.
    @autorun =>
      # Depend on window size changing, but read width and height from the actual dom element size.
      pixelBoySize = @journal.os.pixelBoy.animatingSize()

      # Update the camera's aspect.
      camera = @camera()
      camera.aspect = pixelBoySize.width / pixelBoySize.height
      camera.updateProjectionMatrix()

    # Handle resizes of overlay content.
    @$overlay = @$('.overlay')
    @$overlayContent = @$('.overlay-content')

    @autorun (computation) =>
      # Depend on PixelBoy size and number of journals.
      width = @journal.os.pixelBoy.animatingSize().width
      count = @activeJournals().count()
      scale = LOI.adventure.interface.display.scale()
      contentWidth = 2 * 95 + 120 * count

      @maxOverlayScrollLeft = (contentWidth - width) * scale

    # Start rendering after the canvas has been flushed to the DOM.
    Tracker.afterFlush =>
      @renderer().start()

  onDestroyed: ->
    super

    @renderer().destroy()
    @sceneManager().destroy()

  # Helpers

  activeJournals: ->
    @_journals $ne: true

  archivedJournals: ->
    @_journals true

  _journals: (archived) ->
    PAA.Practice.Journal.documents.find
      'character._id': LOI.characterId()
      archived: archived

  # Events

  events: ->
    super.concat
      'click .new-journal-button': @onClickNewJournalButton
      'scroll .overlay': @onScrollOverlay
      'mouseenter .journal': @onMouseEnterJournal
      'mouseleave .journal': @onMouseLeaveJournal
      'click .journal': @onClickJournal

  onClickNewJournalButton: (event) ->
    PAA.Practice.Journal.insert LOI.characterId(),
      type: PAA.Practice.Journal.Design.Type.Traditional
      size: PAA.Practice.Journal.Design.Size.Small
      orientation: PAA.Practice.Journal.Design.Orientation.Portrait
      bindingPosition: PAA.Practice.Journal.Design.BindingPosition.Left
      paper:
        type: PAA.Practice.Journal.Design.PaperType.QuadDense
        color:
          hue: LOI.Assets.Palette.Atari2600.hues.brown
          shade: 7
      cover:
        color:
          hue: LOI.Assets.Palette.Atari2600.hues.grey
          shade: 1

  onScrollOverlay: (event) ->
    maxCameraPositionX = 50 * (@activeJournals().count() - 1)

    if @maxOverlayScrollLeft
      cameraPositionX = @$overlay.scrollLeft() / @maxOverlayScrollLeft * maxCameraPositionX

    else
      cameraPositionX = 0

    camera = @camera()
    camera.position.x = cameraPositionX
    camera.updateProjectionMatrix()
    @camera.updated()
    
  onMouseEnterJournal: (event) ->
    journal = @currentData()
    
    @sceneManager().hoverJournal journal._id

  onMouseLeaveJournal: (event) ->
    journal = @currentData()

    @sceneManager().leaveJournal journal._id
