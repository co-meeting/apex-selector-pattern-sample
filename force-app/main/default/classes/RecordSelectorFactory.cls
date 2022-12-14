public with sharing class RecordSelectorFactory {
    public RecordSelectorFactory() {}

    public RecordSelector newRecordSelector(String sObjectName) {
        return new RecordSelector(sObjectName);
    }
}
