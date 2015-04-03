app = null

Q = require 'q'
XMLMapping = require 'xml-mapping'

parseFBResponse = (result) ->
  json = XMLMapping.load(result, throwErrors: true)
  json.response

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
    parseFBResponse result
  .catch (err) ->
    console.log err

sendFBRequestByProxy = (requestData) ->
  app.actions.getFreshBooksCreds()
  .then (creds) ->
    options =
      headers:
        Authorization: 'Basic ' + btoa "#{creds.token}:"
      method: 'POST'
      data: XMLMapping.dump requestData, throwErrors: true, header: true
      dataType: 'text'

    deferred = Q.defer()

    app.api.proxy.jQueryAjax creds.url, '', options, (error, response) ->
      if error
        deferred.reject error
      else
        deferred.resolve response.result
    deferred.promise

  .then (result) ->
    parseFBResponse result
  .catch (error) ->
    console.log error

sendFBRequest = sendFBRequestByProxy if location.host.match /nimble\.com/i

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
        client: client

module.exports =
  init: (_app, propertyName) ->
    app = _app
    _app[propertyName] = freshBooksAPI
