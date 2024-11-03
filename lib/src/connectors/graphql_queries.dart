class YouTubeDownloadQueries {
  String getDownloadLinkQuery() {
    return """
      query getDownloadLink(\$link: String!) {
        getDownloadLink(link: \$link) {
          download_link
          }
        }
    """;
  }
}
