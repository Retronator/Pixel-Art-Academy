AM = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.CheckIn extends AM.Document
  @id: -> 'PixelArtAcademy.Practice.CheckIn'
  # time: the time when post was published
  # character: character that published the post
  #   _id
  #   avatar
  #     fullName
  #     color
  # post: (optional) the external post with the check-in data
  #   url
  # text: (optional) the text of the post
  # artwork: (optional) the artwork associated with the post
  #   _id
  #   image:
  #     url
  # image: (optional) the image associated with the post
  #   url
  # video: (optional) the video associated with the post
  #   url
  # memories: list of memories revolving around this check-in
  #   _id
  @Meta
    name: @id()
    fields: =>
      character: @ReferenceField LOI.Character, ['avatar.fullName', 'avatar.color'], true
      memories: [@ReferenceField LOI.Memory]

  # Methods

  @insert: @method 'insert'
  @remove: @method 'remove'
  @updateTime: @method 'updateTime'
  @updateText: @method 'updateText'
  @updateUrl: @method 'updateUrl'
  @newMemory: @method 'newMemory'

  # Server methods

  @getExternalUrlImage: @method 'getExternalUrlImage'
  @extractImagesFromPosts: @method 'extractImagesFromPosts'
  @import: @method 'import'

  # Subscriptions
  @forCharacterId: @subscription 'forCharacterId'
  @forDateRange: @subscription 'forDateRange'
  @memoriesForCheckInId: @subscription 'memoriesForCheckInId'
