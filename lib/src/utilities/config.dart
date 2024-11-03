import "package:graphql_flutter/graphql_flutter.dart";

class GraphQLConfiguration {
  GraphQLConfiguration();

  final HttpLink httpLink = HttpLink(
    'http://127.0.0.1:5000/graphql',
    defaultHeaders: {
      'Content-Type': 'application/json',
      // 'Access-Control-Allow-Origin': '*',
      // 'Accept-Charset': 'utf-8',
      // 'authKey': 'YOUR_AUTH_KEY',
      // 'apiAuthType': 'API_AUTH_TYPE',
      // 'token': 'DEVICE_TOKEN',
    },
  );

  // final AuthLink authLink = AuthLink(
  // 'Content-Type': 'application/json'
  //   // OR
  //   // getToken: () => 'Bearer <YOUR_PERSONAL_ACCESS_TOKEN>',
  // );
//
  // final Link link = authLink.concat(httpLink);

  // ValueNotifier<GraphQLClient> client = ValueNotifier(
  //   GraphQLClient(
  //     link: link,
  //     // The default store is the InMemoryStore, which does NOT persist to disk
  //     cache: GraphQLCache(store: HiveStore()),
  //   ),
  GraphQLClient clientToQuery() {
    return GraphQLClient(
      cache: GraphQLCache(store: HiveStore()),
      link: httpLink,
    );
  }
}
