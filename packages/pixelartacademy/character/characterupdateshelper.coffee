LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.CharacterUpdatesHelper
  constructor: ->
    @person = new ReactiveField null
  
    @earliestTime = new ComputedField =>
      return unless person = @person()
      previousHangout = person.personState('previousHangout')
  
      # Take the last hangout time, but not earlier than 1 month.
      previousHangoutTime = previousHangout?.time or 0
      earliestTime = Math.max previousHangoutTime, Date.now() - 30 * 24 * 60 * 60 * 1000
  
      previousHangoutGameTime = previousHangout?.gameTime or 0
  
      time: new Date earliestTime
      gameTime: new LOI.GameDate previousHangoutGameTime
  
    @actionsSubscription = new ComputedField =>
      return unless person = @person()
      return unless earliestTime = @earliestTime()
  
      LOI.Memory.Action.recentForCharacter.subscribe person._id, earliestTime.time
  
    @memoriesSubscription = new ComputedField =>
      return unless person = @person()
      return unless earliestTime = @earliestTime()
  
      actions = person.recentActions earliestTime
      memoryIds = _.uniq (action.memory._id for action in actions when action.memory)
  
      LOI.Memory.forIds.subscribe memoryIds

    @ready = new ComputedField =>
      @actionsSubscription()?.ready() and @memoriesSubscription()?.ready()

  recordHangout: ->
    person = @person()
    lastHangout = person.personState('lastHangout')
    lastHangoutTime = lastHangout?.time or 0

    # If this hangout is happening more than 15 minutes after the last hangout, record it as an actual new hangout.
    time = Date.now()
    timeSinceLastHangout = time - lastHangoutTime

    if timeSinceLastHangout > 15 * 60 * 1000
      # Store last hangout as the previous hangout so that we can calculate updates since then.
      person.personState 'previousHangout', _.cloneDeep lastHangout

    # Update last hangout to now.
    lastHangout =
      time: Date.now()
      gameTime: LOI.adventure.gameTime().getTime()

    person.personState 'lastHangout', lastHangout

  destroy: ->
    @earliestTime.stop()
    @actionsSubscription.stop()
    @memoriesSubscription.stop()
    @ready.stop()
