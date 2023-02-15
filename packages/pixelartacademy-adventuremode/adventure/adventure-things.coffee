LOI = LandsOfIllusions
PAA = PixelArtAcademy

class LOI.Adventure extends LOI.Adventure
  _initializeThings: ->
    super arguments...

    @currentStudents = new ComputedField =>
      _.filter @currentLocationThings(), (thing) => thing.is PAA.Student
