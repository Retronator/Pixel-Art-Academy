AE = Artificial.Everywhere
AM = Artificial.Mirage
AC = Artificial.Control
LOI = LandsOfIllusions

class LOI.Components.ChapterTitle extends AM.Component
  @register 'LandsOfIllusions.Components.ChapterTitle'
  url: ->
    @chapter().url()

  @version: -> '0.0.1'

  constructor: (@options) ->
    super

    @activatable = new LOI.Components.Mixins.Activatable()

  mixins: -> [@activatable]

  onActivate: (finishedActivatingCallback) ->
    LOI.adventure.addModalDialog @

    Meteor.setTimeout =>
      # unless this is a to-be-continued title, let the chapter title end.
      unless @options.toBeContinued
        $(document).on 'keydown.chapterTitle', (event) =>
          # Only process keys if we're the top-most dialog.
          return unless LOI.adventure.modalDialogs()[0] is @

          keyCode = event.which
          @activatable.deactivate() if keyCode is AC.Keys.enter

        # Automatically continue after 5 seconds.
        Meteor.setTimeout =>
          @activatable.deactivate()
        ,
          5000

      finishedActivatingCallback()
    ,
      500

  onDeactivate: (finishedDeactivatingCallback) ->
    $(document).off '.chapterTitle'

    Meteor.setTimeout =>
      LOI.adventure.removeModalDialog @

      finishedDeactivatingCallback()
    ,
      500

  chapter: ->
    @options.chapter

  toBeContinuedClass: ->
    'to-be-continued' if @options.toBeContinued

  events: ->
    super.concat
      'click': @onClick
      'click .return': @onClickReturn

  onClick: (event) ->
    # Don't hide it if this is a to-be-continued title.
    return if @options.toBeContinued

    @activatable.deactivate()

  onClickReturn: (event) ->
    LOI.adventure.goToLocation Retronator.HQ.LandsOfIllusions.Room

    @activatable.deactivate()
