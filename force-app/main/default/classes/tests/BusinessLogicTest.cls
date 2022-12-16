@IsTest
private class BusinessLogicTest {
	@IsTest
	static void converLead() {
		Lead testLead = new Lead(
			LastName = '山田',
			FirstName = '太郎',
			Title = '部長',
			Phone = '03-1234-5678',
			Company = '株式会社 山田商会',
			Country = 'JP',
			PostalCode = '100-2222',
			State = '東京',
			City = '中央区',
			Street = '築地１丁目１−１'
		);
		RecordSelectorFactoryStubProvider provider = new RecordSelectorFactoryStubProvider();
		provider.addQueryResult(new List<Lead>{ testLead });
		// ビジネスロジック内で複数SOQLを実行する場合の例
		// provider.addQueryResult(new List<Account> {
		//     new Account(Name='Test1')
		// });

		Test.startTest();
		BusinessLogic logic = new BusinessLogic(
			(RecordSelectorFactory) provider.createStub()
		);
		Account acc = logic.converLead(Id.valueOf('0066D000006uNQWQA2'));
		Test.stopTest();

		Assert.areEqual(acc.Name, testLead.Company);
		Assert.areEqual(acc.BillingPostalCode, testLead.PostalCode);
		Assert.areEqual(acc.BillingCountry, testLead.Country);
		Assert.areEqual(acc.BillingState, testLead.State);
		Assert.areEqual(acc.BillingCity, testLead.City);
		Assert.areEqual(acc.BillingStreet, testLead.Street);
		Assert.areEqual(acc.Phone, testLead.Phone);

		Contact con = [
			SELECT Id, LastName, FirstName, Title, Phone
			FROM Contact
			WHERE AccountId = :acc.Id
		];
		Assert.areEqual(con.LastName, testLead.LastName);
		Assert.areEqual(con.FirstName, testLead.FirstName);
		Assert.areEqual(con.Title, testLead.Title);
		Assert.areEqual(con.Phone, testLead.Phone);
	}

	@isTest
	static void getLead() {
		Lead testLead = new Lead(
			LastName = '山田',
			FirstName = '太郎',
			Title = '部長',
			Phone = '03-1234-5678',
			Company = '株式会社 山田商会',
			Country = 'JP',
			PostalCode = '100-2222',
			State = '東京',
			City = '中央区',
			Street = '築地１丁目１−１'
		);
		insert testLead;

		Test.startTest();
		Lead result = new BusinessLogic().getLead(testLead.Id);
		Test.stopTest();

		Assert.areEqual(testLead.LastName, result.LastName);
		Assert.areEqual(testLead.FirstName, result.FirstName);
		Assert.areEqual(testLead.Title, result.Title);
		Assert.areEqual(testLead.Phone, result.Phone);
		Assert.areEqual(testLead.Company, result.Company);
		Assert.areEqual(testLead.PostalCode, result.PostalCode);
		Assert.areEqual(testLead.Country, result.Country);
		Assert.areEqual(testLead.State, result.State);
		Assert.areEqual(testLead.City, result.City);
		Assert.areEqual(testLead.Street, result.Street);
	}
}
