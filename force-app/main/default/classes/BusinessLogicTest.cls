@IsTest
private class BusinessLogicTest {
	class RecordSelectorStubProvider implements System.StubProvider {
		private sObject[] records;
		public Object createStub() {
			return Test.createStub(RecordSelector.class, this);
		}

		public Object handleMethodCall(
			Object stubbedObject,
			String stubbedMethodName,
			Type returnType,
			List<Type> listOfParamTypes,
			List<String> listOfParamNames,
			List<Object> listOfArgs
		) {
			if (stubbedMethodName == 'query') {
				return this.records;
			}
			return null;
		}

		public void setQueryResult(sObject[] records) {
			this.records = records;
		}
	}

	class RecordSelectorFactoryStubProvider implements System.StubProvider {
		private RecordSelector[] selectors = new List<RecordSelector>{};

		public Object createStub() {
			return Test.createStub(RecordSelectorFactory.class, this);
		}

		public Object handleMethodCall(
			Object stubbedObject,
			String stubbedMethodName,
			Type returnType,
			List<Type> listOfParamTypes,
			List<String> listOfParamNames,
			List<Object> listOfArgs
		) {
			if (stubbedMethodName == 'newRecordSelector') {
				return this.selectors.remove(0);
			}
			return null;
		}

		public void addQueryResult(sObject[] records) {
			RecordSelectorStubProvider provider = new RecordSelectorStubProvider();
			provider.setQueryResult(records);
			this.selectors.add((RecordSelector) provider.createStub());
		}
	}

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
