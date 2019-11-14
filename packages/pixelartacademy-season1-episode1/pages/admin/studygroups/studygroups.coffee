AM = Artificial.Mirage
E1 = PixelArtAcademy.Season1.Episode1
C1 = E1.Chapter1

class E1.Pages.Admin.StudyGroups extends AM.Component
  @register 'PixelArtAcademy.Season1.Episode1.Pages.Admin.StudyGroups'

  onCreated: ->
    super arguments...

    for studyGroupId in @studyGroupIds()
      LOI.Character.Membership.forGroupId.subscribe @, studyGroupId

    C1.CoordinatorAddress.CharacterIntroduction.all.subscribe @

  studyGroupIds: ->
    [
      C1.Groups.AdmissionsStudyGroup.A.id()
      C1.Groups.AdmissionsStudyGroup.B.id()
      C1.Groups.AdmissionsStudyGroup.C.id()
    ]

  members: ->
    studyGroupId = @currentData()

    LOI.Character.Membership.documents.find
      groupId: studyGroupId
    ,
      sort:
        memberId: -1

  introduction: ->
    membership = @currentData()
    introductionAction = C1.CoordinatorAddress.CharacterIntroduction.latestIntroductionForCharacter.query(membership.character._id).fetch()[0]
    introductionAction.content.introduction
