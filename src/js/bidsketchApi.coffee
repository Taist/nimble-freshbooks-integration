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
      data: JSON.stringify requestData
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

bidsketchAPIServer = null

bidsketchAPI =
  setCreds: (creds) ->
    app.exapi.setCompanyData 'bidsketchCreds', creds

  getCreds: ->
    app.exapi.getCompanyData 'bidsketchCreds'
    .then (creds) ->
      if creds and not bidsketchAPIServer
        bidsketchAPIServer = creds.url
      creds

  getProposalFeesLink: (id) ->
    if not id or not bidsketchAPIServer
      return null
    "#{bidsketchAPIServer}/proposal_fees/#{id}"

  getClients: (paramsString = '') ->
    sendRequest 'clients.json' + paramsString

  getOneClient: () ->
    bidsketchAPI.getClients '?per_page=1'
    .then (clients) ->
      clients?[0]

  createProposal: (data) ->
    console.log data
    sendRequest 'proposals.json', data, 'POST'

module.exports =
  init: (_app, propertyName) ->
    app = _app
    _app[propertyName] = bidsketchAPI
