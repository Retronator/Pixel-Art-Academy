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
    @ancestorComponentOfType LOI.Adventure.Chapter

  events: ->
    super.concat
      'click': @onClick

  onClick: (event) ->
    @activatable.deactivate()
