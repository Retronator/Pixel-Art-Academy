LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

Vocabulary = LOI.Parser.Vocabulary

class C1.Items.AcceptanceLetter extends LOI.Adventure.Item
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Items.AcceptanceLetter'
  @url: -> 'acceptance-letter'

  @version: -> '0.0.1'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "acceptance letter"
  @shortName: -> "letter"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

  @description: ->
    "
      It's the acceptance letter, inviting _char_ to study at Retropolis Academy of Art.
    "
    
  @initialize()

  onActivate: (finishedActivatingCallback) ->
    Tracker.nonreactive =>
      @autorun (computation) =>
        return unless @isRendered()
        computation.stop()

        Meteor.setTimeout =>
          @$('.scroll').velocity
            height: @$('.content').outerHeight()
          ,
            duration: 2000
            complete: =>
              finishedActivatingCallback()
        ,
          200

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500

  backButtonCallback: ->
    =>
      @$('.scroll').velocity
        height: 50 * LOI.adventure.interface.display.scale()
      ,
        duration: 800

      Meteor.setTimeout =>
        LOI.adventure.deactivateActiveItem()
      ,
        500

  # Listener

  onCommand: (commandResponse) ->
    acceptanceLetter = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.Read, Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Use], acceptanceLetter]
      priority: 1
      action: =>
        LOI.adventure.goToItem acceptanceLetter
