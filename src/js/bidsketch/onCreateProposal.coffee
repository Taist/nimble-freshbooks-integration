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
    console.log 'onCreateProposal', proposal, app.bidsketchAPI.getProposalFeesLink(proposal.id)
    window.open app.bidsketchAPI.getProposalFeesLink(proposal.id), '_blank'
  .catch (error) ->
    console.log error

module.exports = onCreateProposal
