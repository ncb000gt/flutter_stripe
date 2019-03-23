part of stripe;

class Source {
	Source({this.type: 'card', this.currency: 'usd', this.card, this.owner, this.usage: 'reusable'});

	final String type;
	final String currency;
	final Map<String, String> card;
	final Map<String, dynamic> owner;
	final String usage;

	Future<dynamic> create() async {
		return await StripeService.request('POST', 'sources', toJson());
	}

	Map<String, dynamic> toJson() {
		Map<String, dynamic> m = new HashMap<String, dynamic>();
		m['type'] = type;
		m['currency'] = currency;
		m['card'] = card;
		if (owner != null) {
			m['owner'] = owner;
		}
		m['usage'] = usage;

		return m;
	}
}
