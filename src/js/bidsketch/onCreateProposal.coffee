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
    if proposal is 'BIDSKETCH_PROXY_ERROR'
      return Q.reject 'BIDSKETCH_PROXY_ERROR'

    console.log 'onCreateProposal', proposal, app.bidsketchAPI.getProposalFeesLink(proposal.id)
    window.open app.bidsketchAPI.getProposalFeesLink(proposal.id), '_blank'

module.exports = onCreateProposal
