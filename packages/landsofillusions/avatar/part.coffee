AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

class LOI.Avatar.Part extends AM.Document
  # author: the designer of this part
  #   _id
  #   displayName
  #   publicName
  # authorName: public name of the author
  # name: how this part was named by the author 
  #   _id
  # description: how this part was described by the author
  #   _id
  # type: type of this part
  @Meta
    name: 'LandsOfIllusions.Avatar.Part'
    fields: =>
      author: @ReferenceField RA.User, ['displayName'] , true, 'characters', ['name']
      authorName: @GeneratedField 'self', ['author'], (part) ->
        authorName = part.author?.publicName or null
        [user._id, authorName]
