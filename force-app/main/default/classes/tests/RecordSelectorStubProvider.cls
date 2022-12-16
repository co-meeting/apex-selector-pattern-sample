@IsTest
public class RecordSelectorStubProvider implements System.StubProvider {
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
}
