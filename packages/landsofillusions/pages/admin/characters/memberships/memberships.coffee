AM = Artificial.Mirage
AB = Artificial.Babel
ABs = Artificial.Base
LOI = LandsOfIllusions

class LOI.Pages.Admin.Characters.Memberships extends AM.Component
  @id: -> 'LandsOfIllusions.Pages.Admin.Characters.Memberships'
  @register @id()

  onCreated: ->
    super arguments...

    @groupId = new ReactiveField null

    @autorun (computation) =>
      return unless groupId = @groupId()
      LOI.Character.Membership.forGroupId.subscribe groupId

  members: ->
    LOI.Character.Membership.documents.find
      groupId: @groupId()
    ,
      sort:
        memberId: -1

  events: ->
    super(arguments...).concat
      'click .new-pre-made-character': => @constructor.insert()

  class @GroupSelect extends AM.DataInputComponent
    @register 'LandsOfIllusions.Pages.Admin.Characters.Memberships.GroupSelect'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Select

    onCreated: ->
      super arguments...

      @membershipsComponent = @ancestorComponentOfType LOI.Pages.Admin.Characters.Memberships

    options: ->
      groupClasses = _.filter LOI.Adventure.Thing.getClasses(), (thingClass) => thingClass.prototype instanceof LOI.Adventure.Group

      for groupClass in groupClasses
        groupId = groupClass.id()

        name: "#{groupId} (#{groupClass.fullName()})"
        value: groupId

    load: ->
      @membershipsComponent.groupId()

    save: (value) ->
      @membershipsComponent.groupId value

    renderBioTranslatable: ->
      @bioTranslatable.renderComponent @currentComponent()
