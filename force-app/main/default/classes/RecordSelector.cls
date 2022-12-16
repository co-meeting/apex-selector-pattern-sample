public with sharing class RecordSelector {
	public class RecordSelectorException extends Exception {
	}
	private static final Integer MAX_OFFSET = 2000;
	private Boolean isSecurityEnforced = false;
	private Boolean isUserMode = false;

	private String sObjectName;
	private Set<String> selectExpresions = new Set<String>();
	private RecordSelector[] subQueries = new List<RecordSelector>();
	private String[] conditions = new List<String>();
	private String[] orders = new List<String>();
	private String[] groupBys = new List<String>();
	private Integer limitCount;
	private Integer offset;
	private Boolean isAllRows = false;
	public RecordSelector(String sObjectName) {
		this.sObjectName = sObjectName;
	}

	public void setSecurityEnforce(Boolean isSecurityEnforced) {
		this.isSecurityEnforced = isSecurityEnforced;
	}

	public void setUserMode(Boolean isUserMode) {
		this.isUserMode = isUserMode;
	}

	// factory.addSelectField('Name')
	//        .addSelectField('Id');
	public void addSelectField(String fieldName) {
		this.selectExpresions.add(fieldName);
	}

	public void addSelectFields(Set<String> fieldNames) {
		this.selectExpresions.addAll(fieldNames);
	}

	public void addSelectField(Schema.SObjectField field) {
		this.selectExpresions.add(field.getDescribe().getName());
	}
	public void addSelectFields(Set<Schema.SObjectField> fields) {
		for (SObjectField field : fields) {
			this.selectExpresions.add(field.getDescribe().getName());
		}
	}

	public void addSubQuery(RecordSelector subQuery) {
		this.subQueries.add(subQuery);
	}

	public void addCondition(String clause) {
		conditions.add(clause);
	}

	public void addOrder(String order) {
		orders.add(order);
	}

	public void addGroupBy(String groupBy) {
		groupBys.add(groupBy);
	}

	public void setLimit(Integer limitCount) {
		this.limitCount = limitCount;
	}

	public void setOffset(Integer offset) {
		if (offset > MAX_OFFSET) {
			throw new RecordSelectorException('offsetは2000が最大です');
		}
		this.offset = offset;
	}

	public String toSoql() {
		String query =
			'SELECT ' + String.join(new List<String>(this.selectExpresions), ',');
		if (this.subQueries.size() > 0) {
			for (RecordSelector subQuery : this.subQueries) {
				query += ', (' + subQuery.toSoql() + ')';
			}
		}
		query += ' FROM ' + this.sObjectName;
		if (!conditions.isEmpty()) {
			query += ' WHERE ' + String.join(conditions, ' AND ');
		}
		if (!orders.isEmpty()) {
			query += ' ORDER BY ' + String.join(orders, ', ');
		}
		if (limitCount != null) {
			query += ' LIMIT ' + limitCount;
		}
		if (offset != null) {
			query += ' OFFSET ' + offset;
		}
		if (isAllRows) {
			query += ' ALL ROWS';
		}
		if (isSecurityEnforced) {
			query += ' WITH SECURITY_ENFORCED';
		}
		if (isUserMode) {
			query += ' WITH USER_MODE';
		}
		return query;
	}

	/**
	 * クエリーを実行してsObjectレコードを取得
	 *
	 * @return sObjectレコードのリスト
	 */
	public sObject[] query() {
		return Database.query(toSoql());
	}
}
