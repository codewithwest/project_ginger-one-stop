class GraphqlMutations {
  String uploadImageMutation() {
    return r"""
      mutation uploadImage($file: Upload!) {
        uploadImage(file: $file){
          filename
          base64Image
          message
        }
      }
""";
  }
}
