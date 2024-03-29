AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

LOI.Character.Agent::subscribeRecentTaskEntries = (requireInitialHangoutCompleted) ->
  PAA.Learning.Task.Entry.recentForCharacter.subscribe @_id, @recentActionsEarliestTime requireInitialHangoutCompleted

LOI.Character.Agent::recentTaskEntries = (requireInitialHangoutCompleted) ->
  PAA.Learning.Task.Entry.documents.fetch
    'character._id': @_id
    time: $gte: @recentActionsEarliestTime requireInitialHangoutCompleted

LOI.Character.Agent::getTaskEntries = (query) ->
  PAA.Learning.Task.Entry.documents.fetch _.extend {}, query,
    'character._id': @_id
