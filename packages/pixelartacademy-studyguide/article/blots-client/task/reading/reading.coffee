AM = Artificial.Mirage
PAA = PixelArtAcademy
Quill = AM.Quill

class PAA.StudyGuide.Article.Task.Reading extends PAA.StudyGuide.Article.Task
  @id: -> 'PixelArtAcademy.StudyGuide.Article.Task.Reading'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @registerBlot
    name: 'studyguide-task-reading'
    tag: 'div'
    class: 'pixelartacademy-studyguide-article-task-reading'

  events: ->
    super(arguments...).concat
      'click .enabled.confirmation': @onClickConfirmation

  onClickConfirmation: (event) ->
    PAA.Learning.Task.Entry.insert LOI.characterId(), LOI.adventure.currentSituationParameters(), @parent.task.id()
