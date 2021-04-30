AM = Artificial.Mirage
AB = Artificial.Base
PAA = PixelArtAcademy

class PAA.StudyGuide.Pages.Admin.Activities extends AM.Component
  @id: -> 'PixelArtAcademy.StudyGuide.Pages.Admin.Activities'
  @register @id()

  template: -> @constructor.id()

  onCreated: ->
    super arguments...

    Artificial.Babel.inTranslationMode true

    activitiesSubscription = PAA.StudyGuide.Activity.initializeAll @

    # Unselect the current activity if it gets deleted.
    @autorun (computation) =>
      return unless activitiesSubscription.ready()

      activityId = AB.Router.getParameter 'activityId'

      # Make sure the current document exists.
      return if activityId and PAA.StudyGuide.Activity.documents.findOne activityId

      # Route back to index.
      @goToActivity null

  onDestroyed: ->
    super arguments...

    Artificial.Babel.inTranslationMode false

  activities: ->
    PAA.StudyGuide.Activity.documents.find {},
      sort:
        goalId: 1

  goToActivity: (activityId) ->
    # Switch to document, but don't create history so that it's easy to get back out from the admin page.
    AB.Router.setParameters
      activityId: activityId
    ,
      createHistory: false

  activeClass: ->
    'active' if @currentData()._id is AB.Router.getParameter 'activityId'

  activity: ->
    id = AB.Router.getParameter 'activityId'
    PAA.StudyGuide.Activity.documents.findOne id

  shortGoalId: ->
    activity = @currentData()

    activity.goalId.substring 'PixelArtAcademy.StudyGuide.'.length

  events: ->
    super(arguments...).concat
      'click .add-activity-button': @onClickAddActivityButton
      'click .activity': @onClickActivity

  onClickAddActivityButton: ->
    goalSuffix = @$('.new-activity-goalid').val()
    goalId = "PixelArtAcademy.StudyGuide.#{goalSuffix}"

    PAA.StudyGuide.Activity.insert goalId, (error) =>
      return console.error error if error

  onClickActivity: ->
    @goToActivity @currentData()._id
