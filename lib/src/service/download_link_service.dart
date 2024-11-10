import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:project_ginger_one_stop/src/connectors/graphql_queries.dart';
import 'package:project_ginger_one_stop/src/utilities/config.dart';

class ApiService {
  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();
  YouTubeDownloadQueries allQueries = YouTubeDownloadQueries();

  Future getYouTubeDownloadLink(String downloadLink) async {
    try {
      GraphQLClient client = graphQLConfiguration.clientToQuery();
      QueryResult result = await client.query(
        QueryOptions(
            document: gql(
              allQueries.getDownloadLinkQuery(),
            ),
            variables: {
              "link": downloadLink,
            }),
      );
      if (result.hasException) {
        print(result.exception.toString());
        return null;
      }
      var response = result.data;
      // final map = response as Map<String, dynamic>;
      // Data mappedResult = Data.fromJson(map);
      return response?['getYouTubeVideoDownloadData']?[0];
    } catch (e) {
      print(e);
      return null;
    }
  }
}
