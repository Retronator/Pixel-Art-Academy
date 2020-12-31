AM = Artificial.Mirage
AMu = Artificial.Mummification

class AMu.Pages.Admin.DatabaseContent extends AM.Component
  @id: -> 'Artificial.Mummification.Pages.Admin.DatabaseContent'
  @register @id()

  events: ->
    super(arguments...).concat
      'click .download-button': @onClickDownloadButton

  onClickDownloadButton: (event) ->
    password = @$('.password').val()

    # Encrypt userId with the password.
    userId = CryptoJS.AES.encrypt(Meteor.userId(), password).toString()

    $link = $('<a style="display: none">')
    $('body').append $link

    link = $link[0]
    link.download = 'databasecontent.zip'
    link.href = "/admin/artificial/mummification/databasecontent/databasecontent.zip?userId=#{encodeURIComponent userId}"
    link.click()

    $link.remove()
