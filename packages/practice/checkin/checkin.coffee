PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PixelArtAcademyPracticeCheckIn extends Document
  # time: the time when post was published
  # character: character that published the post
  #   _id
  #   name
  # text: (optional) the text of the post
  # artwork: (optional) the artwork associated with the post
  #   _id
  #   image:
  #     url
  # image: (optional) the image associated with the post
  #   url
  # video: (optional) the video associated with the post
  #   url
  @Meta
    name: 'PixelArtAcademyPracticeCheckIn'
    fields: =>
      character: @ReferenceField LOI.Accounts.Character, ['name'], true

PAA.Practice.CheckIn = PixelArtAcademyPracticeCheckIn
