import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;
import '../../models/quote/quote.dart';
part 'quote_provider.g.dart';

@Riverpod(keepAlive: true)
Future<Quote> getQuote(Ref ref) async {
  final url = Uri.parse('https://quotes-api-self.vercel.app/quote');
  final client = http.Client();
  final response = await client.get(url);
  if (response.statusCode == 200) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return Quote.fromJson(body);
  } else {
    throw Exception('Failed to load quote');
  }
}
