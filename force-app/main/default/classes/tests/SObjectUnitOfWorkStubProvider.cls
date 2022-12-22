@IsTest
public class SObjectUnitOfWorkStubProvider implements System.StubProvider {
	public Map<sObjectType, List<SObject>> newListByType = new Map<sObjectType, List<SObject>>();
	public Map<sObjectType, Map<Id, SObject>> dirtyMapByType = new Map<sObjectType, Map<Id, SObject>>();
	public Object createStub() {
		return Test.createStub(SObjectUnitOfWork.class, this);
	}

	public Object handleMethodCall(
		Object stubbedObject,
		String stubbedMethodName,
		Type returnType,
		List<Type> listOfParamTypes,
		List<String> listOfParamNames,
		List<Object> listOfArgs
	) {
		if (stubbedMethodName == 'registerNew') {
			sObject record = (sObject) listOfArgs[0];
			return this.newListByType.get(record.getSObjectType()).add(record);
		} else if (stubbedMethodName == 'registerDirty') {
			sObject record = (sObject) listOfArgs[0];
			return this.dirtyMapByType.get(record.getSObjectType())
				.put(record.Id, record);
		}
		return null;
	}

	public void addSObjectType(sObjectType sObjectType) {
		this.newListByType.put(sObjectType, new List<sObject>());
		this.dirtyMapByType.put(sObjectType, new Map<Id, sObject>());
	}
}
