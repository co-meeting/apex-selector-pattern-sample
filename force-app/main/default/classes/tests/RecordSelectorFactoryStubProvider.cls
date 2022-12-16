@IsTest
public class RecordSelectorFactoryStubProvider implements System.StubProvider {
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
