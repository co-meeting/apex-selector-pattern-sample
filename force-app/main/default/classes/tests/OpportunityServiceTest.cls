@IsTest
private class OpportunityServiceTest {
	@IsTest
	static void applyDiscounts() {
		SObjectSelectorFactoryStubProvider sObjectSelector = new SObjectSelectorFactoryStubProvider();
		Id[] opportunityIds = new List<Id>{
			'0066D000006uNQWQA2',
			'006N000000JHYgGIAX'
		};
		sObjectSelector.addQueryResult(
			new List<Opportunity>{
				new Opportunity(
					Id = opportunityIds[0],
					Name = 'GenePoint Lab Generators',
					Amount = 80000,
					StageName = 'Closed Won',
					CloseDate = Date.today()
				),
				new Opportunity(
					Id = opportunityIds[1],
					Name = 'Edge SLA',
					Amount = 60000,
					StageName = 'Closed Won',
					CloseDate = Date.today()
				)
			}
		);

		SObjectUnitOfWorkStubProvider unitOfWork = new SObjectUnitOfWorkStubProvider();
		unitOfWork.addSObjectType(Opportunity.getSObjectType());

		Test.startTest();
		OpportunityService service = new OpportunityService(
			(SObjectSelectorFactory) sObjectSelector.createStub(),
			(SObjectUnitOfWork) unitOfWork.createStub()
		);
		service.applyDiscounts(new Set<Id>(opportunityIds), 20);
		Test.stopTest();

		Opportunity result1 = (Opportunity) unitOfWork.dirtyMapByType.get(
				Opportunity.getSObjectType()
			)
			.get(opportunityIds[0]);
		Assert.areEqual(80000 * 0.8, result1.Amount);
		Opportunity result2 = (Opportunity) unitOfWork.dirtyMapByType.get(
				Opportunity.getSObjectType()
			)
			.get(opportunityIds[1]);
		Assert.areEqual(60000 * 0.8, result2.Amount);
	}
}
