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

    # Always show the first activity if none is displayed.
    @autorun (computation) =>
      return unless activitiesSubscription.ready()

      activityId = AB.Router.getParameter 'activityId'

      # Make sure the current document exists.
      return if activityId and PAA.StudyGuide.Activity.documents.findOne activityId

      # Switch to the first document on the display list (or no document if we can't find it).
      firstDocument = @activities().fetch()[0]

      AB.Router.setParameters activityId: firstDocument?._id or null

  onDestroyed: ->
    super arguments...

    Artificial.Babel.inTranslationMode false

  activities: ->
    PAA.StudyGuide.Activity.documents.find {},
      sort:
        goalId: 1

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
    AB.Router.setParameters activityId: @currentData()._id
