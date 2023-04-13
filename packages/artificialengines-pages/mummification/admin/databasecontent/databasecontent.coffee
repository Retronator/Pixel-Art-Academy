AM = Artificial.Mirage
AMu = Artificial.Mummification

class AMu.Pages.Admin.DatabaseContent extends AM.Component
  @id: -> 'Artificial.Mummification.Pages.Admin.DatabaseContent'
  @register @id()
  
  documentClassIds: ->
    AMu.Document.getClassIds()

  events: ->
    super(arguments...).concat
      'click .download-button': @onClickDownloadButton
      'change .document-id': @onChangeDocumentId

  onClickDownloadButton: (event) ->
    password = @$('.password').val()

    # Encrypt userId with the password.
    userId = CryptoJS.AES.encrypt(Meteor.userId(), password).toString()

    $link = $('<a style="display: none">')
    $('body').append $link

    link = $link[0]
    link.download = 'databasecontent.zip'
    link.href = "/admin/artificial/mummification/databasecontent/databasecontent.zip?userId=#{encodeURIComponent userId}"
    link.href += "&append=true" if @$('.append').is(':checked')
    link.click()

    $link.remove()
  
  onChangeDocumentId: (event) ->
    documentClassId = @$('.document-class-id').val()
    documentId = $(event.target).val()
    @$('.file-preview').html("<img src='/admin/artificial/mummification/databasecontent/preview.png?documentClassId=#{encodeURIComponent documentClassId}&documentId=#{documentId}'/>")
