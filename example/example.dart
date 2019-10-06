import 'package:twitter_api/twitter_api.dart';

// Used for the decode
import 'dart:convert';

Future main() async {

  // Setting placeholder api keys
  String consumerApiKey = "ABC";
  String consumerApiSecret = "ABC";
  String accessToken = "ABC";
  String accessTokenSecret = "ABC";

  // Creating the twitterApi Object with the secret and public keys
  // These keys are generated from the twitter developer page
  // Dont share the keys with anyone
  final _twitterOauth = new twitterApi(
    consumerKey: consumerApiKey,
    consumerSecret: consumerApiSecret,
    token: accessToken,
    tokenSecret: accessTokenSecret
  );

  // Make the request to twitter
  Future twitterRequest = _twitterOauth.getTwitterRequest(
    // Http Method
    "GET", 
    // Endpoint you are trying to reach
    "statuses/user_timeline.json", 
    // The options for the request
    options: {
      "user_id": "19025957",
      "screen_name": "TTCnotices",
      "count": "20",
      "trim_user": "true",
      "tweet_mode": "extended", // Used to prevent truncating tweets
    },
  );

  // Wait for the future to finish
  var res = await twitterRequest;

  // Print off the response
  print(res.statusCode); 
  print(res.body);

  // Convert the string response into something more useable
  var tweets = json.decode(res.body);
  print(tweets);
}
