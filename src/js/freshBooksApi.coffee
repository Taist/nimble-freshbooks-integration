app = null

Q = require 'q'
XMLMapping = require 'xml-mapping'

parseFBResponse = (result) ->
  json = XMLMapping.load(result, throwErrors: true)
  json.response

sendFBRequest = (requestData) ->
  freshBooksAPI.getCreds()
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
  freshBooksAPI.getCreds()
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
  setCreds: (creds) ->
    app.exapi.setUserData 'freshBooksCreds', creds

  getCreds: ->
    app.exapi.getUserData 'freshBooksCreds'

  getClientLink: (clientId) ->
    unless clientId
      return null
    freshBooksAPI.getCreds()
    .then (creds) ->
      ( a = document.createElement 'a' ).href = creds.url
      "#{a.protocol}//#{a.host}/showUser?userid=#{clientId}"

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

  createEstimate: (estimate) ->
    sendFBRequest
      request:
        method: 'estimate.create'
        estimate: estimate

module.exports =
  init: (_app, propertyName) ->
    app = _app
    _app[propertyName] = freshBooksAPI
