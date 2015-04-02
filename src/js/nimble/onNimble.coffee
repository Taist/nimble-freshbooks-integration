app = require '../app'
proxy = require '../helpers/xmlHttpProxy'

onDealView = ->
  app.observer.waitElement '.DealView .profileInfoWrapper td.generalInfo', (elem) ->
    container = document.createElement 'div'
    elem.appendChild container
    container.innerHTML = 'PUT BUTTON HERE'

routesByHashes =
  '^app/deals/view': onDealView

setRoutes = ->
  for hashRegexp, routeProcessor of routesByHashes
    do (hashRegexp, routeProcessor) =>
      app.api.hash.when hashRegexp, routeProcessor

extractNimbleAuthTokenFromRequest = ->
  proxy.onRequestFinish (request) ->
    url = request.responseURL
    tokenMatches = url.match /\/api\/sessions\/([0-9abcdef-]{36})\?/
    if tokenMatches?
      app.options.nimbleToken = tokenMatches[1]

module.exports = ->
  setRoutes()
  extractNimbleAuthTokenFromRequest()
