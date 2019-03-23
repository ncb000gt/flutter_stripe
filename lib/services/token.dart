part of stripe;

class Token {
	Token({this.type: 'card', this.currency: 'usd', this.card, this.owner});

	final String type;
	final String currency;
	final Map<String, String> card;
	final Map<String, dynamic> owner;

	Future<dynamic> create() async {
		return await StripeService.request('POST', 'tokens', toJson());
	}

	Map<String, dynamic> toJson() {
		Map<String, dynamic> m = new HashMap<String, dynamic>();
		m['type'] = type;
		m['currency'] = currency;
		m['card'] = card;
		if (owner != null) {
			m['owner'] = owner;
		}

		return m;
	}
}
