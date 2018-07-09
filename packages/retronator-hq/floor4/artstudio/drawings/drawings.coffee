AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.ArtStudio.Drawings extends LOI.Adventure.Context
  @id: -> 'Retronator.HQ.ArtStudio.Drawings'

  @register @id()
  template: -> @constructor.id()

  @version: -> '0.0.1'

  @fullName: -> "drawings"
  @description: ->
    "
      Various drawings are found in the north-west part of the studio.
    "

  @initialize()

  constructor: ->
    super

  onCreated: ->
    super

  onRendered: ->
    super

    @$scene = @$('.scene')
    @$foreground = @$('.foreground')
    @$easelRight = @$('.easel-right')

  illustrationHeight: ->
    viewport = LOI.adventure.interface.display.viewport()
    scale = LOI.adventure.interface.display.scale()

    Math.min 360, viewport.viewportBounds.height() / scale

  sceneStyle: ->
    viewport = LOI.adventure.interface.display.viewport()
    scale = LOI.adventure.interface.display.scale()

    left: viewport.maxBounds.left() - 120 * scale

  onScroll: (scrollTop) ->
    return unless @isRendered()

    @$scene.css transform: "translate3d(0, #{-scrollTop / 2}px, 0)"

    @$foreground.css transform: "translate3d(0, #{-scrollTop / 20}px, 0)"

  onCommand: (commandResponse) ->
    drawings = @options.parent

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.LookAt, drawings]
      priority: 1
      action: =>
        LOI.adventure.enterContext drawings
