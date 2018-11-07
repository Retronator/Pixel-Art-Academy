AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.GameContent
  @exportGetters = []
  @importTransforms = {}

  @addToExport: (getter) ->
    @exportGetters.push getter

  @addImportDirective: (directive, transform) ->
    @importTransforms[directive] = transform

  @export: ->
    exportedDocuments = {}

    for getter in @exportGetters

      exportingDocuments = getter()

      for exportingDocument in exportingDocuments
        classId = exportingDocument.constructor.id()

        exportedDocuments[classId] ?= []
        exportedDocuments[classId].push exportingDocument

    exportedDocuments

  @import: (exportedDocuments) ->
    for documentClassId, exportedDocumentsData of exportedDocuments
      documentClass = AM.Document.getClassForId documentClassId

      for exportedDocumentData in exportedDocumentsData
        if exportedDocumentData._importDirective
          transform = @importTransforms[exportedDocumentData._importDirective]
          delete exportedDocumentData._importDirective
          transform exportedDocumentData

        documentClass.documents.upsert exportedDocumentData._id, exportedDocumentData
