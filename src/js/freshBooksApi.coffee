app = null

Q = require 'q'
XMLMapping = require 'xml-mapping'

parseFBResponse = (result) ->
  json = XMLMapping.load(result, throwErrors: true)
  json.response

sendFBRequestStub = () ->
  Q.resolve 'FB_PROXY_ERROR'

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
    #Use stub instead of real function
    sendFBRequest = sendFBRequestStub
    'FB_PROXY_ERROR'

sendFBRequest = sendFBRequestByProxy if location.host.match /nimble\.com/i

fbAPIServer = null

freshBooksAPI =
  setCreds: (creds) ->
    app.exapi.setUserData 'freshBooksCreds', creds

  getCreds: ->
    app.exapi.getUserData 'freshBooksCreds'
    .then (creds) ->
      if creds and not fbAPIServer
        ( a = document.createElement 'a' ).href = creds.url
        fbAPIServer = "#{a.protocol}//#{a.host}"
      creds

  getClientLink: (clientId) ->
    if not clientId or not fbAPIServer
      return null
    "#{fbAPIServer}/showUser?userid=#{clientId}"

  getEstimateLink: (estimateId) ->
    if not estimateId or not fbAPIServer
      return null
    "#{fbAPIServer}/updateEstimate?estimateid=#{estimateId}"

  getClients: ->
    sendFBRequest
      request:
        method: 'client.list'
    .then (clients) ->
      console.log clients
      clients

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

  getEstimate: (estimateId) ->
    sendFBRequest
      request:
        method: 'estimate.get'
        estimate_id: $t: estimateId
    .catch (error) ->
      # Suppres access error
      Q.resolve error

module.exports =
  init: (_app, propertyName) ->
    app = _app
    _app[propertyName] = freshBooksAPI
