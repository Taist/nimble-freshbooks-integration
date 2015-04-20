app = require '../app'

Q = require 'q'

prepareFee = (fee, type) ->
  name: fee.name.$t
  description: fee.description.$t ? fee.name.$t
  feetype: type
  amount: fee.unit_cost.$t
  quantity: fee.quantity.$t
  unit: 'Product' if type is 'custom'

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

    fees = deal.fees.item.map (fee) ->
      -> app.bidsketchAPI.createFee proposal.id, prepareFee fee, 'custom'

    fees = fees.concat deal.fees.time.map (fee) ->
      -> app.bidsketchAPI.createFee proposal.id, prepareFee fee, 'hourly'

    Q.all( fees.map (f) -> f() )
    .then () ->
      dealId = app.nimbleAPI.getDealIdFromUrl()
      deal.info.bidsketchProposalId = proposal.id
      app.exapi.setCompanyData dealId, deal.info

      proposal

  .then (proposal) ->
    window.open app.bidsketchAPI.getProposalOpeningSectionsLink(proposal.id), '_blank'

module.exports = onCreateProposal
