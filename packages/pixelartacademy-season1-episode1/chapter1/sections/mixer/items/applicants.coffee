AB = Artificial.Babel
LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.Applicants extends LOI.Adventure.Thing
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Mixer.Applicants'
  @register @id()

  @fullName: -> "Retropolis Academy of Art applicants"
  @shortName: -> "applicants"
  @descriptiveName: -> "Other Retropolis Academy of Art ![applicants](look at applicants)."

  @description: ->
    "
      Other students partaking in Admission Week are present at the meeting. Looking at their name tags, their names
      are {{applicantNames}}. You can look at each individual to learn more about them.
    "

  @initialize()

  description: ->
    # Substitute applicant names in the description.
    galleryWest = _.find LOI.adventure.activeScenes(), (scene) => scene instanceof C1.Mixer.GalleryWest

    # We use the reverse order than otherStudents() to get NPCs first, since they have custom descriptions
    # (so that if the player tries clicking on their names in order, the NPC descriptions will show first).
    applicants = [galleryWest.actors()..., galleryWest.otherAgents()...]


    applicantNames = for applicant in applicants
      name = applicant.fullName()
      "![#{name}](look at #{name})"

    applicantNamesText = AB.Rules.English.createNounSeries applicantNames

    super().replace '{{applicantNames}}', applicantNamesText
