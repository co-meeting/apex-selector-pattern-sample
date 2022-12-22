public with sharing class SObjectSelectorFactory {
	public SObjectSelectorFactory() {
	}

	public SObjectSelector newSObjectSelector(String sObjectName) {
		return new SObjectSelector(sObjectName);
	}
}
