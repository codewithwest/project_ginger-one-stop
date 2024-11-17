import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_ginger_one_stop/src/schemas/graphql_mutations.dart';
import 'package:project_ginger_one_stop/src/schemas/graphql_queries.dart';
import 'package:project_ginger_one_stop/src/utilities/config.dart';

class ApiService {
  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();
  GraphqlQueries allQueries = GraphqlQueries();

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
        return null;
      }
      var response = result.data;
      // final map = response as Map<String, dynamic>;
      // Data mappedResult = Data.fromJson(map);
      return response?['getYouTubeVideoDownloadData']?[0];
    } catch (e) {
      return null;
    }
  }

  Future getConvertedAndResizedImage(File uploadedImage) async {
    var byteData = uploadedImage.readAsBytesSync();

    var multipartFile = MultipartFile.fromBytes(
      'photo',
      byteData,
      filename: '${DateTime.now().second}.png',
      contentType: MediaType("image", "png"),
    );

    var opts = MutationOptions(
      document: gql(GraphqlMutations().uploadImageMutation()),
      variables: {
        "file": multipartFile,
      },
    );

    GraphQLClient client = graphQLConfiguration.clientToQuery();
    try {
      var results = await client.mutate(opts);
      var base64Image = results.data?['base64Image'];

      // Decode the base64 string into bytes
      Uint8List bytes = base64Decode(base64Image);

      // Get the directory to save the image
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/image.png';

      // Save the image to the specified path
      File file = File(path);
      await file.writeAsBytes(bytes);

      // You can now use the saved image path to display it or perform other actions
      print('Image saved to: $path');

      return results.hasException
          ? null //'${results.errors.join(", ")}'
          : results.data?["uploadImageMutation"][0];
    } catch (exception) {
      throw ("Oops something went wrong!");
    }
  }
}
