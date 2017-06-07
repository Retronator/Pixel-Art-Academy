AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

class LOI.Character.Part.Template extends AM.Hierarchy.Template
  @id: -> 'LandsOfIllusions.Character.Part.Template'
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
  # data: data of the template (root node), as inherited from hierarchy template
  @Meta
    name: @id()
    fields: =>
      author: @ReferenceField RA.User, ['displayName'] , true, 'characters', ['name']
      authorName: @GeneratedField 'self', ['author'], (part) ->
        authorName = part.author?.publicName or null
        [user._id, authorName]

  @forId: @subscription 'forId'
  @forType: @subscription 'forType'
  @forCurrentUser: @subscription 'forCurrentUser'

  @updateData: @method 'updateData'
