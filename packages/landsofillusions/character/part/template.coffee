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
  #   translations
  # description: how this part was described by the author
  #   _id
  #   translations
  # type: type of this part
  # data: data of the template (root node), as inherited from hierarchy template
  # spriteIds: generated array of all sprite Ids found in the template data
  @Meta
    name: @id()
    fields: =>
      author: Document.ReferenceField RA.User, ['displayName', 'publicName'], false
      authorName: Document.GeneratedField 'self', ['author'], (part) ->
        authorName = part.author?.publicName or null
        [part._id, authorName]
      name: Document.ReferenceField AB.Translation, ['translations'], false
      description: Document.ReferenceField AB.Translation, ['translations'], false
      spriteIds: [Document.GeneratedField 'self', ['data'], (template) ->
        spriteIds = []

        addSpriteIds = (data) =>
          return unless data

          for fieldName, fieldData of data
            if fieldName is 'spriteId'
              spriteIds.push fieldData.value if fieldData?.value

            else if _.isObject fieldData
              addSpriteIds fieldData

        addSpriteIds template.data

        [template._id, spriteIds]
      ]

  @forId: @subscription 'forId'
  @forType: @subscription 'forType'
  @forTypes: @subscription 'forTypes'
  @forCurrentUser: @subscription 'forCurrentUser'

  @insert: @method 'insert'
  @updateData: @method 'updateData'

if Meteor.isServer
  importDirective = 'LandsOfIllusions.Character.Part.Template.adminTemplates'
  
  LOI.GameContent.addToExport ->
    documents = []

    # TODO: Fetch only admin templates.
    templates = LOI.Character.Part.Template.documents.fetch()

    # Strip authors from templates.
    for template in templates
      delete template.author
      delete template.authorName
      template._importDirective = importDirective
      
    documents.push templates...

    # Add template names and descriptions.
    names = AB.Translation.documents.fetch
      _id: $in: (template.name._id for template in templates)

    documents.push names...

    descriptions = AB.Translation.documents.fetch
      _id: $in: (template.description._id for template in templates)

    documents.push descriptions...

    documents

  LOI.GameContent.addImportDirective importDirective, (template) ->
    # Associate the template back to the (new) admin.
    unless admin = RA.User.documents.findOne username: 'admin'
      console.warn "Admin user hasn't been created yet. Restart server to update template authors."

      # Delete ID to skip importing for now.
      delete template._id

      return

    template.author = _id: admin._id
    template.authorName = admin.publicName
