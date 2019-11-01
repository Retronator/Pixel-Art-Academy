AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Pages.Admin.Characters extends AM.Component
  @register 'LandsOfIllusions.Pages.Admin.Characters'

  onCreated: ->
    super arguments...

    @avatarUrls = new ReactiveField null
