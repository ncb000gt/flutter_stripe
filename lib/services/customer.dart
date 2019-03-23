part of stripe;

class Customer {
	Customer({this.email});

	String email = null;

	Future<dynamic> create() async {
		return await StripeService.request('POST', 'customers', toJson());
	}

	Future<dynamic> attachSource(customerId, sourceId) async {
		return await StripeService.request(
			'POST',
			'customers/$customerId/sources',
			{ "source": sourceId }
		);
	}

	Map<String, dynamic> toJson() {
		Map<String, dynamic> m = new HashMap<String, dynamic>();
		m['email'] = email;

		return m;
	}
}
