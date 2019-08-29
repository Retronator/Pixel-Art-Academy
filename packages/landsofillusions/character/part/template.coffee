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
  # lastEditTime: time when last update operation was performed
  # type: type of this part
  # spriteIds: generated array of all sprite Ids found in the template data
  @Meta
    name: @id()
    fields: (fields) =>
      _.extend fields,
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

      fields

  @forId: @subscription 'forId'
  @forType: @subscription 'forType'
  @forTypes: @subscription 'forTypes'
  @forCurrentUser: @subscription 'forCurrentUser'

  @insert: @method 'insert'
  @updateData: @method 'updateData'
  @publish: @method 'publish'
  @revert: @method 'revert'

  @_authorizeTemplateAction: (template) ->
    # User must be the author of this template.
    user = Retronator.requireUser()
    throw new AE.UnauthorizedException "You must be the author of the template to change it." unless template.author._id is user._id
  
  @denormalizeTemplateField: (templateField) ->
    AM.Hierarchy.Template.denormalizeTemplateField LOI.Character.Part.Template, templateField

    # Also denormalize the name since we need it for conditional template name checking.
    referencedTemplate = LOI.Character.Part.Template.documents.findOne templateField.id
    templateField.name = referencedTemplate.name.translations?.best?.text

  @canUpgradeComparator: (embeddedTemplate, liveTemplate) ->
    embeddedTemplate?.version < liveTemplate?.latestVersion?.index or embeddedTemplate?.name isnt liveTemplate?.name?.translations?.best?.text
