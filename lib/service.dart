part of stripe;

class StripeService {
	static String host = 'api.stripe.com';
	static String apiKey = null;
	static String apiVersion = 'v1';

	static Future<dynamic> request(String method, String path, Map<String, dynamic> data) async {
		if (apiKey == null && !apiKey.startsWith('pk_')) {
			String message = 'Please specify the publishable apikey using `StripeService.apiKey = "pk_test_..."`.';
			throw new Exception(message);
		}

		path = '/$apiVersion/$path';

		var client = new http.Client();

		Uri uri;
		var hostToUse = host;
		if (method == 'GET' && data != null) {
			uri = new Uri(
				scheme: 'https',
				host: hostToUse,
				path: path,
				query: encodeMap(data),
				userInfo: '${apiKey}:'
			);
		} else {
			uri = new Uri(
				scheme: 'https',
				host: hostToUse,
				path: path,
				userInfo: '${apiKey}:'
			);
		}

		int responseStatusCode;
		var request = await http.Request(method, uri);

		if (method == 'POST' && data != null) {
			// Now convert the params to a list of UTF8 encoded bytes of a uri encoded
			// string and add them to the request
			var encodedData = encodeMap(data);
			request.body = encodedData;
			request.headers['content-type'] = 'application/x-www-form-urlencoded';
		}

		var response = await client.send(request);
		responseStatusCode = response.statusCode;
		var bodyData = await response.stream.transform(utf8.decoder).toList();
		var body = bodyData.join('');

		Map map;
		try {
			map = await jsonDecode(body);
		} on Error {
			throw new Exception('The JSON returned was unparsable (${body}).');
			// throw new InvalidRequestErrorException('The JSON returned was unparsable (${body}).');
		}

		if (responseStatusCode != 200) {
			if (map['error'] == null) {
				throw new Exception(
					'The status code returned was ${responseStatusCode} but no error was provided.');
				// throw new InvalidRequestErrorException(
				// 	'The status code returned was ${responseStatusCode} but no error was provided.');
			}
			Map error = map['error'];
			switch (error['type']) {
				case 'invalid_request_error':
					throw new Exception(error['message']);
					// throw new InvalidRequestErrorException(error['message']);
					break;
				case 'api_error':
					throw new Exception(error['message']);
					// throw new ApiErrorException(error['message']);
					break;
				case 'card_error':
					print(
							"${error['message']}, ${error['code']}, ${error['param']}");
					throw new Exception(
							error['message']);//, error['code'], error['param']);
					// throw new CardErrorException(
					// 		error['message'], error['code'], error['param']);
					break;
				default:
					throw new Exception(
							'The status code returned was ${responseStatusCode} but no error type was provided.');
					// throw new InvalidRequestErrorException(
					// 		'The status code returned was ${responseStatusCode} but no error type was provided.');
			}
		}

		return map;
	}

	static String encodeMap(final Map<String, dynamic> data) {
		List<String> output = [];

		for (String k in data.keys) {
			if (data[k] is Map) {
				var hasProps = false;

				for (String kk in data[k].keys) {
					hasProps = true;
					output.add(
						Uri.encodeComponent('${k}[${kk}]') +
						'=' +
						Uri.encodeComponent(data[k][kk].toString())
					);
				}

				if (!hasProps) {
					output.add(Uri.encodeComponent(k) + '=');
				}
			} else if (data[k] is List) {
				for (String v in data[k]) {
					output.add(Uri.encodeComponent('${k}[]') + '=' + Uri.encodeComponent(v));
				}
			} else if (data[k] is int) {
				output.add(Uri.encodeComponent(k) + '=' + data[k].toString());
			} else {
				output.add(Uri.encodeComponent(k) + '=' + Uri.encodeComponent(data[k]));
			}
		}

		return output.join('&');
	}
}
