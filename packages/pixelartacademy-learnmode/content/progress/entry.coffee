AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mummification
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

# An entry that is created or updated when a player makes progress in course content.
# Note that these are public documents and should contain no sensitive information.
class LM.Content.Progress.Entry extends AM.Document
  @id: -> 'LearnMode.Content.Progress.Entry'
  # profileId: the profile that made progress
  # lastEditTime: the time when progress was made
  # contentId: content ID of the course content this is an entry for
  # completedRatio: progress ratio towards fully completing this content
  # completedUnitsCount: optional number of units completed in this content
  # requiredCompletedRatio: optional progress ratio towards completing just the requirements of this content
  # requiredCompletedUnitsCount: optional number of required units completed in this content
  @Meta
    name: @id()
      
  @enablePersistence()
  
  @makeProgress: (profileId, contentId, data) ->
    entry = _.extend
      profileId: profileId
      lastEditTime: new Date()
      contentId: contentId
    ,
      data

    PAA.Learning.Task.Entry.documents.upsert entry
