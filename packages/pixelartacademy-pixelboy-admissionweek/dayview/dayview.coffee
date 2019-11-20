AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.AdmissionWeek.DayView extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.AdmissionWeek.DayView'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  constructor: (@admissionWeek) ->
    super arguments...

  onCreated: ->
    super arguments...

    appClassIds = [
      PAA.PixelBoy.Apps.Calendar.id()
      PAA.PixelBoy.Apps.Drawing.id()
      PAA.PixelBoy.Apps.Journal.id()
      PAA.PixelBoy.Apps.StudyPlan.id()
      PAA.PixelBoy.Apps.Yearbook.id()
    ]

    apps = for appClassId in appClassIds
      appClass = _.thingClass(appClassId)
      _.extend
        _id: appClassId
        avatar: appClass.createAvatar()
        iconUrl: appClass.iconUrl()
        url: @admissionWeek.os.appPath appClass.url()
      ,
        @constructor.AppInfo[appClassId]

    @unlockedAppClassIds = new ComputedField =>
      @admissionWeek.state('unlockedApps') or []

    @lockedAppClassIds = new ComputedField =>
      _.difference appClassIds, @unlockedAppClassIds()

    getApps = (appClassIds) =>
      # Note: We don't simply filter the apps because that would not preserve the order of provided IDs.
      for appId in appClassIds
        _.find apps, (app) => app._id is appId

    @unlockedApps = new ComputedField => getApps @unlockedAppClassIds()
    @lockedApps = new ComputedField => getApps @lockedAppClassIds()

  visibleClass: ->
    'visible' if @admissionWeek.state 'startDay'

  unlocksLeft: ->
    Math.max 0, @admissionWeek.currentDay() - @unlockedApps().length

  events: ->
    super(arguments...).concat
      'click .app-unlock-button': @onClickAppUnlockButton
      'click .unlocked-apps .app': @onClickUnlockedApp

  onClickAppUnlockButton: (event) ->
    app = @currentData()
    @admissionWeek.unlockApp app._id

  onClickUnlockedApp: (event) ->
    app = @currentData()
