public with sharing class SObjectUnitOfWork {
	private Map<sObjectType, List<SObject>> newListByType = new Map<sObjectType, List<SObject>>();
	private Map<sObjectType, Map<Id, SObject>> dirtyMapByType = new Map<sObjectType, Map<Id, SObject>>();

	public SObjectUnitOfWork(List<SObjectType> sObjectTypes) {
		for (SObjectType sObjectType : sObjectTypes) {
			newListByType.put(sObjectType, new List<SObject>());
			dirtyMapByType.put(sObjectType, new Map<Id, SObject>());
		}
	}

	/**
	 * Insertするレコードを登録
	 */
	public void registerNew(SObject record) {
		sObjectType sObjectType = record.getSObjectType();

		newListByType.get(sObjectType).add(record);
	}

	/**
	 * Updateするレコードを登録
	 */
	public void registerDirty(SObject record) {
		registerDirty(record, new List<SObjectField>());
	}

	/**
	 * Updateするレコードを登録, すでに登録されているレコードは指定されたフィールドのみ更新
	 */
	public void registerDirty(SObject record, List<SObjectField> dirtyFields) {
		sObjectType sObjectType = record.getSObjectType();
		if (
			!dirtyMapByType.get(sObjectType).containsKey(record.Id) ||
			dirtyFields.isEmpty()
		) {
			dirtyMapByType.get(sObjectType).put(record.Id, record);
		} else {
			SObject registeredRecord = dirtyMapByType.get(sObjectType).get(record.Id);

			for (SObjectField dirtyField : dirtyFields) {
				registeredRecord.put(dirtyField, record.get(dirtyField));
			}

			dirtyMapByType.get(sObjectType).put(record.Id, registeredRecord);
		}
	}

	/**
	 * DMLを実行する
	 */
	public void commitWork() {
		// TODO:
	}
}
