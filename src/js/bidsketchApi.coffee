app = null

Q = require 'q'

sendRequestStub = () ->
  Q.resolve 'BIDSKETCH_PROXY_ERROR'

sendRequestByProxy = (endPoint, requestData, method = 'GET') ->
  bidsketchAPI.getCreds()
  .then (creds) ->
    options =
      headers:
        Authorization: "Token token=\"#{creds.token}\""
      method: method
      data: requestData
      dataType: 'text'

    deferred = Q.defer()

    apiUrl = "#{creds.url}/api/v1/#{endPoint}"
    app.api.proxy.jQueryAjax apiUrl, '', options, (error, response) ->
      if error
        deferred.reject error
      else
        deferred.resolve response.result
    deferred.promise

  .then (result) ->
    JSON.parse result

  .catch (error) ->
    #Use stub instead of real function
    console.log error
    sendRequest = sendRequestStub
    'BIDSKETCH_PROXY_ERROR'

sendRequest = sendRequestByProxy

bidsketchAPI =
  setCreds: (creds) ->
    app.exapi.setCompanyData 'bidsketchCreds', creds

  getCreds: ->
    app.exapi.getCompanyData 'bidsketchCreds'

  getClients: (paramsString = '') ->
    sendRequest 'clients.json' + paramsString
    .then (clients) ->
      clients

  getOneClient: () ->
    bidsketchAPI.getClients '?per_page=2'
    .then (clients) ->
      clients?[0]

module.exports =
  init: (_app, propertyName) ->
    app = _app
    _app[propertyName] = bidsketchAPI