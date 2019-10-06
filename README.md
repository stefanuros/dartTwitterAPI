# Dart Twitter API

A Project that was made to make using the Twitter API from flutter and dart a bit
easier.

This package contains a high level functionality for connecting to the Twitter 
API. Provice the secret and public keys, and then make the request to Twitter. The
package will handle all of the authentication. This only works for application
authentication. User authentication is not implemented and is not planned for 
the future.

# How to Use

Below is an example of how the package would be used.
```dart
import 'package:twitter_api/twitter_api.dart';

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
Response res = await twitterRequest;

// Print off the response
print(res.statusCode); 
print(res.body);
```

## Requests
Only application authentication is supported by this package.

There are two different types of paramters that will be needed. Depoendant and Independant

The first type is the independant paramters. These are things that every single 
request will need, no matter the content you are trying to get.
These values include:
* A consumer API key
* A consumer API secret key
* An access token
* A secret access token

These are the keys that are used to authenticate your request. Make sure they are
correctly entered. You should keep these secret and private.

Next are the dependant variables. These are things that depend on the type of 
request you are trying to make.
These values include: 
* method: HTTP Method
  * This is a required parameter of type String
  * GET or POST
* url: The endpoint you are trying to reach
  * This is a required paramter of type String
  * Some examples on the twitter website include /1.1/ but do not include that
  when making requests here. That part is already added internally
* options: The parameters of the request you are trying to make
  * This is an optional paramter of type Map<String, String>
  * These are things like which user you are trying to view, how many tweets you
  are trying to get, whether to strip user info from the response or not
  * The full list of these parameters can be found at the [Twitter Developer Website](https://developer.twitter.com/en/docs/api-reference-index)

## Response
Below is a truncated example of the data that is returned from the above example.
It is initially sent as a string and needs to be parsed to get to this state.

To convert it from a string to a List of Maps:
```dart
import 'dart:convert';
var tweets = json.decode(res.body);
```

The data that comes out of the request after converting it:
```dart
var resBody = [
  {
    "created_at": "Wed Oct 02 23:28:13 +0000 2019",
    "id": 1179538608740556800,
    "id_str": "1179538608740556800",
    "full_text":
        "52 Lawrence West and 952 Lawrence West Express: Detour westbound via Culford Rd, Maple Leaf Dr and Jane St due to emergency sewer repair.\nhttps:\/\/t.co\/jPSDy5TW8Q",
    "truncated": false,
    "display_text_range": [0, 161],
    "entities": {
      "hashtags": [],
      "symbols": [],
      "user_mentions": [],
      "urls": [
        {
          "url": "https:\/\/t.co\/jPSDy5TW8Q",
          "expanded_url":
              "https:\/\/twitter.com\/TTCnotices\/status\/1179537904022016000",
          "display_url": "twitter.com\/TTCnotices\/sta\u2026",
          "indices": [138, 161]
        }
      ]
    },
    "source":
        "\u003ca href=\"https:\/\/www.hootsuite.com\" rel=\"nofollow\"\u003eHootsuite Inc.\u003c\/a\u003e",
    "in_reply_to_status_id": null,
    "in_reply_to_status_id_str": null,
    "in_reply_to_user_id": null,
    "in_reply_to_user_id_str": null,
    "in_reply_to_screen_name": null,
    "user": {"id": 19025957, "id_str": "19025957"},
    "geo": null,
    "coordinates": null,
    "place": null,
    "contributors": null,
    "is_quote_status": true,
    "quoted_status_id": 1179537904022016000,
    "quoted_status_id_str": "1179537904022016000",
    "quoted_status_permalink": {
      "url": "https:\/\/t.co\/jPSDy5TW8Q",
      "expanded":
          "https:\/\/twitter.com\/TTCnotices\/status\/1179537904022016000",
      "display": "twitter.com\/TTCnotices\/sta\u2026"
    },
    "quoted_status": {
      "created_at": "Wed Oct 02 23:25:25 +0000 2019",
      "id": 1179537904022016000,
      "id_str": "1179537904022016000",
      "full_text":
          "52 Lawrence West and 952 Lawrence West Express: Detour westbound via Culford Rd, Maple Leaf Dr and Jane St due to a collision.",
      "truncated": false,
      "display_text_range": [0, 126],
      "entities": {
        "hashtags": [],
        "symbols": [],
        "user_mentions": [],
        "urls": []
      },
      "source":
          "\u003ca href=\"https:\/\/www.hootsuite.com\" rel=\"nofollow\"\u003eHootsuite Inc.\u003c\/a\u003e",
      "in_reply_to_status_id": null,
      "in_reply_to_status_id_str": null,
      "in_reply_to_user_id": null,
      "in_reply_to_user_id_str": null,
      "in_reply_to_screen_name": null,
      "user": {"id": 19025957, "id_str": "19025957"},
      "geo": null,
      "coordinates": null,
      "place": null,
      "contributors": null,
      "is_quote_status": false,
      "retweet_count": 1,
      "favorite_count": 1,
      "favorited": false,
      "retweeted": false,
      "lang": "en"
    },
    "retweet_count": 0,
    "favorite_count": 0,
    "favorited": false,
    "retweeted": false,
    "possibly_sensitive": false,
    "lang": "en"
  },
]
```
