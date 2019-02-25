AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Properties.Property extends AM.Component
  draftTemplateClass: ->
    data = @currentData()
    part = data.part or data
    return unless node = part.options.dataLocation()

    'draft-template' if (node.template or node.templateId) and not node.template?.version?
