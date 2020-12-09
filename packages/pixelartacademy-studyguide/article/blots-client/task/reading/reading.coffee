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

  confirmationEnabledClass: ->
    # Allow the user to attempt to complete the task if it's active or if the
    # user is not signed in (in that case they will see the sign in popup).
    'enabled' if @task.active() or not Meteor.userId()

  events: ->
    super(arguments...).concat
      'click .enabled.confirmation': @onClickConfirmation

  onClickConfirmation: (event) ->
    @ensureSignedIn =>
      # Make sure that task is active.
      return unless @task.active()

      PAA.Learning.Task.Entry.insertForUser @task.id()
