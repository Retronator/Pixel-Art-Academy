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

    appIds = [
      PAA.PixelBoy.Apps.Calendar.id()
      PAA.PixelBoy.Apps.Drawing.id()
      PAA.PixelBoy.Apps.Journal.id()
      PAA.PixelBoy.Apps.StudyPlan.id()
      PAA.PixelBoy.Apps.Yearbook.id()
    ]

    apps = for appId in appIds
      appClass = _.thingClass(appId)
      _.extend
        _id: appId
        avatar: appClass.createAvatar()
        iconUrl: appClass.iconUrl()
        url: @admissionWeek.os.appPath appClass.url()
      ,
        @constructor.AppInfo[appId]

    @unlockedAppIds = new ComputedField =>
      @admissionWeek.state('unlockedApps') or []

    @lockedAppIds = new ComputedField =>
      _.difference appIds, @unlockedAppIds()

    getApps = (appIds) =>
      # Note: We don't simply filter the apps because that would not preserve the order of provided IDs.
      for appId in appIds
        _.find apps, (app) => app._id is appId

    @unlockedApps = new ComputedField => getApps @unlockedAppIds()
    @lockedApps = new ComputedField => getApps @lockedAppIds()

    @unlockRecommendation = new ComputedField =>
      bestAppId = null
      bestScore = 0
      bestAxis = null

      behaviorPart = LOI.character().behavior.part
      personalityPart = behaviorPart.properties.personality.part
      factorPowers = personalityPart.factorPowers()

      lockedAppIds = @lockedAppIds()

      # No need to recommend something when there's just one choice.
      return unless lockedAppIds.length > 1

      for appId in @lockedAppIds()
        appInfo = @constructor.AppInfo[appId]
        
        score = 0
        bestAxisIndex = null
        bestAxisScore = 0
        bestAxisDirection = null

        for axisIndex, weight of appInfo.factors when factorPowers[axisIndex]
          direction = if weight > 0 then 'positive' else 'negative'
          axisScore = (factorPowers[axisIndex][direction] or 0) * Math.abs weight

          score += axisScore
          
          if axisScore > bestAxisScore
            bestAxisIndex = axisIndex
            bestAxisScore = axisScore
            bestAxisDirection = direction

        if score > bestScore
          bestAppId = appId
          bestScore = score
          bestAxis = LOI.Character.Behavior.Personality.Factors[bestAxisIndex].options[bestAxisDirection]

      # Don't recommend anything if the best app doesn't have at least 10 points.
      return unless bestScore >= 10

      appId: bestAppId
      reason:
        axis: bestAxis

  appRecommendedForUnlock: ->
    app = @currentData()

    return unless unlockRecommendation = @unlockRecommendation()
    unlockRecommendation.appId is app._id

  appRecommendationPersonalityFactorStyle: ->
    return unless palette = LOI.palette()
    return unless unlockRecommendation = @unlockRecommendation()

    colorData = unlockRecommendation.reason.axis.color
    color = palette.color colorData.hue, colorData.shade

    color: "##{color.getHexString()}"

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
