@IsTest
public class SObjectSelectorFactoryStubProvider implements System.StubProvider {
	private SObjectSelector[] selectors = new List<SObjectSelector>{};

	public Object createStub() {
		return Test.createStub(SObjectSelectorFactory.class, this);
	}

	public Object handleMethodCall(
		Object stubbedObject,
		String stubbedMethodName,
		Type returnType,
		List<Type> listOfParamTypes,
		List<String> listOfParamNames,
		List<Object> listOfArgs
	) {
		if (stubbedMethodName == 'newSObjectSelector') {
			return this.selectors.remove(0);
		}
		return null;
	}

	public void addQueryResult(sObject[] records) {
		SObjectSelectorStubProvider provider = new SObjectSelectorStubProvider();
		provider.setQueryResult(records);
		this.selectors.add((SObjectSelector) provider.createStub());
	}
}
