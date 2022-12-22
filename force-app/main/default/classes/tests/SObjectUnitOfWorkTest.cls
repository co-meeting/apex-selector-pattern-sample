@IsTest
private class SObjectUnitOfWorkTest {
	@IsTest
	static void commitWork() {
		SObjectUnitOfWork unitOfWork = new SObjectUnitOfWork(
			new List<SObjectType>{ Account.getSObjectType() }
		);

		Account result;
		// Test registerNew
		Account acc = new Account(Name = 'Test Account');
		unitOfWork.registerNew(acc);
		unitOfWork.commitWork();
		result = [SELECT Id, Name FROM Account];
		Assert.areEqual(acc.Name, result.Name);

		// Test registerDirty
		unitOfWork = new SObjectUnitOfWork(
			new List<SObjectType>{ Account.getSObjectType() }
		);
		acc.Name = 'Test Updated';
		unitOfWork.registerDirty(acc);
		unitOfWork.commitWork();
		result = [SELECT Id, Name FROM Account];
		Assert.areEqual(acc.Name, result.Name);
	}
}
