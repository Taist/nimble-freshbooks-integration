app = null

Q = require 'q'

getDealIdFromUrl = ->
  matches = location.hash.match /deals\/[^?]+\?id=([0-9a-f]{24})/
  if matches then matches[1] else null

sendNimbleRequest = (path) ->
  Q.when $.ajax
    url: path
    dataType: "json"
    headers:
      Authorization: "Nimble token=\"#{app.options.nimbleToken}\""

nimbleAPI =
  getDealContact: () ->
    if dealId = getDealIdFromUrl()
      sendNimbleRequest "/api/deals/#{dealId}"
      .then (deal) ->
        if contactId = Object.keys(deal?.contacts)?[0]
          Q.resolve deal.contacts[contactId]
      .catch (error) ->
        console.log error

module.exports =
  init: (_app, propertyName) ->
    app = _app
    _app[propertyName] = nimbleAPI
