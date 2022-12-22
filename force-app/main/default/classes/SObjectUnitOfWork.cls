public with sharing class SObjectUnitOfWork {
	private List<SObjectType> sObjectTypes;
	private Map<sObjectType, List<SObject>> newListByType;
	private Map<sObjectType, Map<Id, SObject>> dirtyMapByType;

	public SObjectUnitOfWork(List<SObjectType> sObjectTypes) {
		this.sObjectTypes = sObjectTypes;
		beginWork();
	}

	/**
	 * 作業を開始する
	 */
	public void beginWork() {
		this.newListByType = new Map<sObjectType, List<SObject>>();
		this.dirtyMapByType = new Map<sObjectType, Map<Id, SObject>>();
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
		this.insertDmlByType();
		this.updateDmlByType();
	}

	private void insertDmlByType() {
		for (SObjectType sObjectType : newListByType.keySet()) {
			insert this.newListByType.get(sObjectType);
		}
	}

	private void updateDmlByType() {
		for (SObjectType sObjectType : dirtyMapByType.keySet()) {
			update this.dirtyMapByType.get(sObjectType).values();
		}
	}
}
