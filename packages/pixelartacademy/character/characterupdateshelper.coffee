LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.CharacterUpdatesHelper
  constructor: ->
    @person = new ReactiveField null
  
    @earliestTime = new ComputedField =>
      return unless person = @person()
      lastHangout = person.personState('lastHangout')
  
      # Take the last hangout time, but not earlier than 1 month.
      lastHangoutTime = lastHangout?.time.getTime() or 0
      earliestTime = Math.max lastHangoutTime, Date.now() - 30 * 24 * 60 * 60 * 1000
  
      lastHangoutGameTime = lastHangout?.gameTime.getTime() or 0
  
      time: new Date earliestTime
      gameTime: new LOI.GameDate lastHangoutGameTime
  
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

  destroy: ->
    @earliestTime.stop()
    @actionsSubscription.stop()
    @memoriesSubscription.stop()
    @ready.stop()
