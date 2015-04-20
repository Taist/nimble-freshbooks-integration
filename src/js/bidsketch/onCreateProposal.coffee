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
    unless proposal?.id?
      return Q.reject proposal

    console.log 'onCreateProposal', proposal

    dealId = app.nimbleAPI.getDealIdFromUrl()
    deal.info.bidsketchProposalId = proposal.id
    app.exapi.setCompanyData dealId, deal.info

    proposal

  .then (proposal) ->
    window.open app.bidsketchAPI.getProposalOpeningSectionsLink(proposal.id), '_blank'

module.exports = onCreateProposal
