AE = Artificial.Everywhere
AM = Artificial.Mummification

class AM.Hierarchy.Template extends AM.Document
  # data: the root node of the template
  #   fields: the data of the template
  #     {field}: string name of related keys
  #       value: the terminal raw value of the field
  #       template: a reference to a template which should be inserted at this field
  #         id: id of the template document
  #         version: the index of a specific version of data
  #         data: the denormalized data of the template's specified version
  #       node: a non-terminal value of the field that continues the hierarchy
  #         fields:
  #           {field}:
  #             value
  #             template
  #             node
  #               ...
  # dataPublished: boolean whether latest changes to the data have been published
  # versions: array of data that can be referenced by version
  #   fields
  #     ...
  # latestVersion: the last entry of the versions array, useful for subscriptions
  #   index: the integer index of the version
  #   data: data of the version
  #     ...
  @Meta
    abstract: true
    fields: =>
      latestVersion: Document.GeneratedField 'self', ['versions'], (template) ->
        if latestVersionData = _.last template.versions
          latestVersion =
            index: template.versions.length - 1
            data: latestVersionData

        [template._id, latestVersion]

  # Child class should implement these methods and subscriptions. They need to be 
  # initialized in child classes because they will require the id method of the class.
  @insert: null
  @updateData: null
  @publish: null
  @revert: null
  @forId: null

  @denormalizeTemplateField: (templateClass, templateField) ->
    throw new AE.ArgumentNullException "You must specify the ID in a template field." unless templateField.id
    throw new AE.ArgumentNullException "You must specify the version in a template field." unless templateField.version?

    referencedTemplate = templateClass.documents.findOne templateField.id
    throw new AE.ArgumentNullException "The specified template does not exist." unless referencedTemplate

    templateField.data = referencedTemplate.versions?[templateField.version]
    throw new AE.ArgumentNullException "The specified template version does not exist." unless templateField.data

  @assertNoDraftTemplates: (node) ->
    for fieldName, field of node.fields
      if field.template or field.templateId
        throw new AE.ArgumentException "The template to be published can't include draft templates." unless field.template?.version?

      else if field.node
        @assertNoDraftTemplates field.node

  @_publish: (templateClass, template) ->
    # Make sure template data doesn't reference any draft (unversioned) templates.
    @assertNoDraftTemplates template.data

    if template.versions
      # We add current data as a new version.
      update =
        $push:
          versions: template.data

      versionIndex = template.versions.length

    else
      # We need to create the versions array as well.
      update =
        $set:
          versions: [template.data]

      versionIndex = 0

    # Mark that data was published.
    update.$set ?= {}
    update.$set.dataPublished = true

    templateClass.documents.update template._id, update

    # Return the version index.
    versionIndex

  @_revert: (templateClass, template) ->
    throw new AE.ArgumentException "The given template does not have a last version to revert to." unless template.latestVersion

    LOI.Character.Part.Template.documents.update template._id,
      $set:
        data: template.latestVersion.data
        dataPublished: true

    # Return the index of the reverted version.
    template.latestVersion.index

  constructor: ->
    super arguments...
    
    # The field that loaded the template will want a node with our data.
    # Note that this resets the address hierarchy from here on out to this template.
    @node = new AM.Hierarchy.Node
      templateClass: @constructor
      template: @
      address: new AM.Hierarchy.Address
      load: => @data
      save: (address, value) =>
        @constructor.updateData @_id, address, value
