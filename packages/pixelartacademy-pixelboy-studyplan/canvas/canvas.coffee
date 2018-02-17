AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.StudyPlan.Canvas extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.StudyPlan.Canvas'
  @register @id()
  
  constructor: (@studyPlan) ->
    # Prepare all reactive fields.
    @camera = new ReactiveField null
    @mouse = new ReactiveField null
    @bounds = new AE.Rectangle()
    @$canvas = new ReactiveField null

  onCreated: ->
    super
    
    @display = LOI.adventure.interface.display

    # Initialize components.
    @camera new @constructor.Camera @
    @mouse new @constructor.Mouse @

    # Resize the canvas when app size changes.
    @autorun =>
      return unless $canvas = @$canvas()

      # Depend on app size.
      @studyPlan.os.pixelBoy.size()

      @bounds.width $canvas.width()
      @bounds.height $canvas.height()

  onRendered: ->
    super

    @$canvas @$('.pixelartacademy-pixelboy-apps-studyplan-canvas')
