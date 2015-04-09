app = null

Q = require 'q'

sendNimbleRequest = (path) ->
  if app.options.nimbleToken
    Q.when $.ajax
      url: path
      dataType: "json"
      headers:
        Authorization: "Nimble token=\"#{app.options.nimbleToken}\""
  else
    console.log 'Nimble token is null'
    deferred = Q.defer()

    setTimeout ->
      sendNimbleRequest path
      .then (response) ->
        deferred.resolve response
    , 500

    deferred.promise

nimbleAPI =
  getDealIdFromUrl: ->
    matches = location.hash.match /deals\/[^?]+\?id=([0-9a-f]{24})/
    if matches then matches[1] else null

  getDealInfo: () ->
    if dealId = nimbleAPI.getDealIdFromUrl()
      sendNimbleRequest "/api/deals/#{dealId}"

  getContactById: (contactId) ->
    sendNimbleRequest "/api/v1/contacts/detail/?id=#{contactId}"

module.exports =
  init: (_app, propertyName) ->
    app = _app
    _app[propertyName] = nimbleAPI
