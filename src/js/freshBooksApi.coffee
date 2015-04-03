app = null

Q = require 'q'
XMLMapping = require 'xml-mapping'


sendFBRequest = (requestData) ->
  app.actions.getFreshBooksCreds()
  .then (creds) ->
    Q.when $.ajax
      url: creds.url
      headers:
        Authorization: 'Basic ' + btoa "#{creds.token}:"
      method: 'POST'
      data: XMLMapping.dump requestData, throwErrors: true, header: true
      dataType: 'text'
  .then (result) ->
    Q.resolve XMLMapping.load result, throwErrors: true
  .catch (err) ->
    console.log err

freshBooksAPI =
  getClients: ->
    sendFBRequest
      request:
        method: 'client.list'
    .then (clients) ->
      console.log clients

  createClient: (client) ->
    sendFBRequest
      request:
        method: 'client.create'
        client:
          first_name: $t: 'Jane'
          last_name: $t: 'Doe'
          email: $t: 'janedoe@freshbooks.com'
    .then (result) ->
      console.log result

module.exports =
  init: (_app, propertyName) ->
    app = _app
    _app[propertyName] = freshBooksAPI
