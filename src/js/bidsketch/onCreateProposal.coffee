app = require '../app'

Q = require 'q'

onCreateProposal = (deal) ->
  app.bidsketchAPI.getOneClient()
  .then (client) ->
    app.bidsketchAPI.createProposal {
      name: deal.name
      description: deal.name
      currency: deal.currency
      client_id: client.id
    }
  .then (proposal) ->
    console.log 'onCreateProposal', proposal

module.exports = onCreateProposal
