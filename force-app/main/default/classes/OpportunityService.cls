public with sharing class OpportunityService {
	@TestVisible
	private SObjectSelectorFactory selectorFactory;
	private SObjectUnitOfWork unitOfWork;
	public OpportunityService() {
		this.selectorFactory = new SObjectSelectorFactory();
		this.unitOfWork = new SObjectUnitOfWork(
			new List<SObjectType>{ Opportunity.getSObjectType() }
		);
	}

	@TestVisible
	public OpportunityService(
		SObjectSelectorFactory selectorFactory,
		SObjectUnitOfWork unitOfWork
	) {
		this.selectorFactory = selectorFactory;
		this.unitOfWork = unitOfWork;
	}

	public void applyDiscounts(
		Set<Id> opportunityIds,
		Decimal discountPercentage
	) {
		// TODO: この実装方法ではunitOfWorkは初期化する必要がある
		// this.unitOfWork.beginWork(); など

		// Validate parameters
		if (opportunityIds == null || opportunityIds.size() == 0)
			throw new OpportunityServiceException('Opportunities not specified.');
		if (discountPercentage < 0 || discountPercentage > 100)
			throw new OpportunityServiceException('Invalid discount to apply.');
		// Query Opportunities and Lines (SOQL inlined for this example, see Selector pattern in later module)
		List<Opportunity> opportunities = this.getOpportunities(opportunityIds);
		// Update Opportunities and Lines (if present)
		List<Opportunity> oppsToUpdate = new List<Opportunity>();
		List<OpportunityLineItem> oppLinesToUpdate = new List<OpportunityLineItem>();
		Decimal factor =
			1 - (discountPercentage == null ? 0 : discountPercentage / 100);
		for (Opportunity opportunity : opportunities) {
			// Apply to Opportunity Amount
			if (
				opportunity.OpportunityLineItems != null &&
				opportunity.OpportunityLineItems.size() > 0
			) {
				for (
					OpportunityLineItem oppLineItem : opportunity.OpportunityLineItems
				) {
					oppLineItem.UnitPrice = oppLineItem.UnitPrice * factor;
					this.unitOfWork.registerDirty(oppLineItem);
				}
			} else {
				opportunity.Amount = opportunity.Amount * factor;
				this.unitOfWork.registerDirty(opportunity);
			}
		}

		this.unitOfWork.commitWork();
	}

	/**
	 * 正しくクエリーが発行されるかのみをテストするために
	 * レコード取得ロジックはプライベートメソッドとして切り出す
	 *
	 * @param opportunityIds 商談のIdリスト
	 * @return 商談レコードのリスト
	 */
	@TestVisible
	private Opportunity[] getOpportunities(Set<Id> opportunityIds) {
		SObjectSelector selector = this.selectorFactory.newSObjectSelector('Lead');
		selector.addSelectField('Amount');
		selector.addSelectField('(SELECT UnitPrice FROM OpportunityLineItems)');
		selector.addCondition('Id IN :opportunityIds');
		return selector.query();
	}

	public class OpportunityServiceException extends Exception {
	}
}
