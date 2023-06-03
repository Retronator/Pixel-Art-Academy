AM = Artificial.Mummification
Persistence = AM.Document.Persistence
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Chapter extends PAA.Chapter
  @courses: -> [] # Override to provide any course classes that the chapter oversees.

  constructor: ->
    super arguments...

    # Handle courses content for this chapter.
    @courses = (new courseClass for courseClass in @constructor.courses())
    @contents = _.flatten (course.allContents() for course in @courses)

  destroy: ->
    super arguments...

    course.destroy() for course in @courses

  getCourse: (courseClass) ->
    _.find @courses, (course) => course instanceof courseClass

  getTask: (taskClass) ->
    _.find @tasks, (task) => task instanceof taskClass
