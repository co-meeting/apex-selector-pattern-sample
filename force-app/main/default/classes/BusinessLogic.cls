public with sharing class BusinessLogic {
	@TestVisible
	private RecordSelectorFactory selectorFactory;
	public BusinessLogic() {
		this.selectorFactory = new RecordSelectorFactory();
	}

	@TestVisible
	public BusinessLogic(RecordSelectorFactory selectorFactory) {
		this.selectorFactory = selectorFactory;
	}

	/**
	 * リードの取引を開始
	 *
	 * @param Id リードのレコードId
	 * @return 作成した取引先レコード
	 */
	public Account converLead(Id leadId) {
		Lead lead = getLead(leadId);

		Account acc = new Account(
			Name = lead.Company,
			BillingPostalCode = lead.PostalCode,
			BillingCountry = lead.Country,
			BillingState = lead.State,
			BillingCity = lead.City,
			BillingStreet = lead.Street,
			Phone = lead.Phone
		);
		insert acc;

		Contact con = new Contact(
			AccountId = acc.Id,
			LastName = lead.LastName,
			FirstName = lead.FirstName,
			Title = lead.Title,
			Phone = lead.Phone
		);
		insert con;

		return acc;
	}

	/**
	 * 正しくクエリーが発行されるかのみをテストするために
	 * レコード取得ロジックはプライベートメソッドとして切り出す
	 *
	 * @param leadId リードId
	 * @return リードレコード 存在しなければ nullを返す
	 */
	@TestVisible
	private Lead getLead(Id leadId) {
		RecordSelector selector = this.selectorFactory.newRecordSelector('Lead');
		selector.addSelectField('Id');
		selector.addSelectField('LastName');
		selector.addSelectField('FirstName');
		selector.addSelectField('Title');
		selector.addSelectField('Phone');
		selector.addSelectField('Company');
		selector.addSelectField('Country');
		selector.addSelectField('PostalCode');
		selector.addSelectField('State');
		selector.addSelectField('City');
		selector.addSelectField('Street');
		sObject[] records = selector.query();
		if (records.isEmpty()) {
			return null;
		} else {
			return (Lead) records[0];
		}
	}
}
