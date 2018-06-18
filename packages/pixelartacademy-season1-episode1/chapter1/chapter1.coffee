AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ
RS = Retronator.Store

class PAA.Season1.Episode1.Chapter1 extends LOI.Adventure.Chapter
  # READ-ONLY
  # application:
  #   applied: boolean if character has applied for admission week
  #   applicationTime: game date when character applied
  #   applicationRealTime: real date of application, so that applications can be accepted in order
  #   accepted: boolean if accepted event has happened
  #   acceptedTime: time when accepted event has happened
  C1 = @

  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1'

  @fullName: -> "Admission Week"
  @number: -> 1

  @sections: -> [
    @Intro
    @Waiting
    @PrePixelBoy
    @PixelBoy
    @PostPixelBoy
    @AdmissionProjects
    @AdmissionProjects.Snake.Intro
    @AdmissionProjects.Snake.Drawing
  ]

  @scenes: -> [
    @Inventory
    @Inbox
    @Apps
    @Pico8Cartridges
    @DrawingTutorial
    @SanFranciscoConversation
    @Groups.SanFranciscoFriends
    @Groups.SanFranciscoFriends.Conversation
    @Groups.Family
  ]

  @initialize()

  # We specifically set the requirement of Chapter 1 since it's used to allow students to get accepted. 
  # We do it for class as well as object method, because object by default inherits from episode.
  @accessRequirement: -> RS.Items.CatalogKeys.PixelArtAcademy.AlphaAccess
  accessRequirement: -> @constructor.accessRequirement()

  # Methods

  @applyCharacter: new AB.Method name: "#{@id()}.applyCharacter"

  constructor: ->
    super
