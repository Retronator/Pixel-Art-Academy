AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

LOI.Character.Agent::subscribeRecentTasks = ->
  PAA.Learning.Task.Entry.recentForCharacter.subscribe @_id, @recentActionsEarliestTime()

LOI.Character.Agent::recentTasks = ->
  PAA.Learning.Task.Entry.documents.fetch
    'character._id': @_id
    time: $gte: @recentActionsEarliestTime()
