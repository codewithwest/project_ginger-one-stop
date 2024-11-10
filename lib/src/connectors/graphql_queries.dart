class YouTubeDownloadQueries {
  String getDownloadLinkQuery() {
    return """
      query getYouTubeVideoDownloadData(\$link: String!) {
        getYouTubeVideoDownloadData(link: \$link) {
          title
          video_duration
          ext
          filesize_approx
          highest_width
          highest_height
          highest_resolution
          webpage_url
          formats {
            ext
            format
            resolution
            width
            height
            video_extension
            audio_extension
            filesize_approx
            filesize
            manifest_url
            url
          }
        }
      }
    """;
  }
}
