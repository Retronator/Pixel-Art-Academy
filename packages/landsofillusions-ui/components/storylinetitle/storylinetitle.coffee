AE = Artificial.Everywhere
AM = Artificial.Mirage
AC = Artificial.Control
LOI = LandsOfIllusions

class LOI.Components.StorylineTitle extends AM.Component
  @register 'LandsOfIllusions.Components.StorylineTitle'

  @version: -> '0.0.1'

  constructor: (@options) ->
    super arguments...

    @activatable = new LOI.Components.Mixins.Activatable()

  mixins: -> [@activatable]

  onActivate: (finishedActivatingCallback) ->
    @options.onActivate?()

    Meteor.setTimeout =>
      # unless this is a to-be-continued title, let the chapter title end.
      unless @options.toBeContinued
        $(document).on 'keydown.storylineTitle', (event) =>
          # Only process keys if we're the top-most dialog.
          return unless LOI.adventure.modalDialogs()[0].dialog is @

          keyCode = event.which
          @activatable.deactivate() if keyCode is AC.Keys.enter

        # Automatically continue after 5 seconds.
        Meteor.setTimeout =>
          @activatable.deactivate()
        ,
          5000

      @options.onActivated?()
      finishedActivatingCallback()
    ,
      500

  onDeactivate: (finishedDeactivatingCallback) ->
    $(document).off '.storylineTitle'
    @options.onDeactivate?()

    Meteor.setTimeout =>
      @options.onDeactivated?()
      finishedDeactivatingCallback()
    ,
      500

  chapter: ->
    @options.chapter

  episode: ->
    @options.episode

  toBeContinuedClass: ->
    'to-be-continued' if @options.toBeContinued

  events: ->
    super(arguments...).concat
      'click': @onClick

  onClick: (event) ->
    # Don't hide it if this is a to-be-continued title.
    return if @options.toBeContinued

    @activatable.deactivate()
