import 'dart:math';
import 'dart:core';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart';

/// This class is used to access the twitter api
/// 
/// The link for the implementation rules can be found here:
/// https://developer.twitter.com/en/docs/basics/authentication/guides/authorizing-a-request
class twitterApi {
  // These 7 are the oauth values needed, spelled like they are
  /// This is the consumer key from twitter
  var _oauth_consumer_key; //ignore: non_constant_identifier_names
  /// This is a unique id given to a request that twitter can use to prevent 
  /// the same request from being sent twice. It is automatically generated
  var _oauth_nonce; //ignore: non_constant_identifier_names
  /// This is the request signature twitter requires
  var _oauth_signature; //ignore: non_constant_identifier_names
  /// This is the signature method twitter requires
  final _oauth_signature_method = "HMAC-SHA1"; //ignore: non_constant_identifier_names
  /// This is the timestamp of the request. Old requests are disregarded
  var _oauth_timestamp; //ignore: non_constant_identifier_names
  /// This is the token from twitter
  var _oauth_token; //ignore: non_constant_identifier_names
  /// This is the oauth version twitter requires for a request
  final _oauth_version = "1.0"; //ignore: non_constant_identifier_names

  // These are the api secrets from the twitter developer page
  /// This is the consumer secret for twitter
  var _consumerSecret;
  /// This is the token secret for twitter
  var _tokenSecret;
  /// The base url for the twitter api
  final _baseUrl = "https://api.twitter.com/1.1/";

  /// This is a table of the bytes that do not need to be replaced when percent
  /// encoding. Link can be found here
  /// https://developer.twitter.com/en/docs/basics/authentication/guides/percent-encoding-parameters
  final _percentEncodeValues = [
    0x30, // 0
    0x31, // 1
    0x32, // 2
    0x33, // 3
    0x34, // 4
    0x35, // 5
    0x36, // 6
    0x37, // 7
    0x38, // 8
    0x39, // 9
    0x41, // A
    0x42, // B
    0x43, // C
    0x44, // D
    0x45, // E
    0x46, // F
    0x47, // G
    0x48, // H
    0x49, // I
    0x4A, // J
    0x4B, // K
    0x4C, // L
    0x4D, // M
    0x4E, // N
    0x4F, // O
    0x50, // P
    0x51, // Q
    0x52, // R
    0x53, // S
    0x54, // T
    0x55, // U
    0x56, // V
    0x57, // W
    0x58, // X
    0x59, // Y
    0x5A, // Z
    0x61, // a
    0x62, // b
    0x63, // c
    0x64, // d
    0x65, // e
    0x66, // f
    0x67, // g
    0x68, // h
    0x69, // i
    0x6A, // j
    0x6B, // k
    0x6C, // l
    0x6D, // m
    0x6E, // n
    0x6F, // o
    0x70, // p
    0x71, // q
    0x72, // r
    0x73, // s
    0x74, // t
    0x75, // u
    0x76, // v
    0x77, // w
    0x78, // x
    0x79, // y
    0x7A, // z
    0x2D, // -
    0x2E, // .
    0x5F, // _
    0x7E, // ~
  ];

  /// This class is used to access the twitter api
  /// 
  /// The link for the implementation rules can be found here:
  /// https://developer.twitter.com/en/docs/basics/authentication/guides/authorizing-a-request
  /// 
  /// [consumerKey], [consumerSecret], [token], and [tokenSecret] come from the
  /// link above. They are unique for each app and user. You will need to generate
  /// your own and pass them in when creating the TwitterOauth object.
  twitterApi({consumerKey, consumerSecret, token, tokenSecret}) {
    this._oauth_consumer_key = consumerKey;
    this._oauth_token = token;
    this._consumerSecret = consumerSecret;
    this._tokenSecret = tokenSecret;
  }

  /// This function makes the twitter request based on the options
  /// 
  /// Accepts a String [method] which is the REST method (GET, POST...) of the
  /// request being made. The request is made to a String [url] which is the 
  /// base url of the request. Finally there is a map [options] which holds
  /// all of the [options] of the request being made. [timeout] is the time before
  /// the request is timed out if it is not completed in that time.
  /// 
  /// This is the where the infomartion for this method comes from:
  /// https://developer.twitter.com/en/docs/basics/authentication/guides/creating-a-signature
  /// 
  /// The twitter developer website also goes into detail about [options] that can
  /// be applied. These [options] are of type Map<String, String>.
  getTwitterRequest(String method, String url, {Map<String, String>? options, int timeout = 10}) async {
    if(options == null) options = {};

    // Create the nonce
    _oauth_nonce = _generateNonce();
    // Get the current timestamp. Convert from milliseconds to seconds
    _oauth_timestamp = (new DateTime.now().millisecondsSinceEpoch/1000).floor().toString();
    // Get the signature
    _oauth_signature = _generateSignature(method, url, options);

    // Get the authentication headers
    var authHeader = _getOauthHeader();

    // The response from the request
    Future? response;

    // Add a post and get option
    if(method.toUpperCase() == "GET")
    {
      // Make a request with a payload and a header
      // The payload is an https request with api.twitter.com as the website
      // /1.1/ + url is the path from the base url to the endpoint we're trying 
      // to reach
      // options are the options being sent to the endpoint
      // The headers handle the authentication
      // The timeout makes sure that if something goes wrong, the app doesnt 
      // hang forever
      response = get(
        Uri.https(
          "api.twitter.com", 
          "/1.1/" + url, 
          options
        ), 
        headers: {
          "Authorization": authHeader,
          "Content-Type": "application/json"
        }
      ).timeout(Duration(seconds: timeout));    
    }
    // Repeat for POST
    else if(method.toUpperCase() == "POST")
    {
      response = post(
        Uri.https(
          "api.twitter.com", 
          "/1.1/" + url, 
          options
        ), 
        headers: {
          "Authorization": authHeader,
          "Content-Type": "application/json"
        }
      ).timeout(Duration(seconds: timeout));    
    }

    // Return the future
    return response;
  }


  /// Function to get a completed header for authorising a request to twitter
  _getOauthHeader() {
    var dst = "OAuth ";
    // Add all the key value pairs to the DST
    // If there are key/value pairs remaining, append a comma ‘,’ and a space ‘ ‘ to DST.
    dst += _encodeDstKeyValuePair("oauth_consumer_key", _oauth_consumer_key) + ",";
    dst += _encodeDstKeyValuePair("oauth_nonce", _oauth_nonce) + ",";
    dst += _encodeDstKeyValuePair("oauth_signature", _oauth_signature) + ",";
    dst += _encodeDstKeyValuePair("oauth_signature_method", _oauth_signature_method) + ",";
    dst += _encodeDstKeyValuePair("oauth_timestamp", _oauth_timestamp) + ",";
    dst += _encodeDstKeyValuePair("oauth_token", _oauth_token) + ",";
    dst += _encodeDstKeyValuePair("oauth_version", _oauth_version);

    return dst;
  }

  /// This function takes a key, value pair and applies the proper procedure that
  /// Twitter outlines.
  _encodeDstKeyValuePair(key, value) {
    var singleDST = "";

    // Percent encode the key and append it to DST.
    singleDST += _percentEncode(key);
    // Append the equals character ‘=’ to DST.
    // Append a double quote ‘”’ to DST.
    singleDST += "=\"";
    // Percent encode the value and append it to DST.
    singleDST += _percentEncode(value.toString());
    // Append a double quote ‘”’ to DST.
    singleDST += "\"";

    return singleDST;
  }

  
  /// This function will create a signature for the request
  _generateSignature(method, url, opt) {

    // The list of key-value pairs that will be added to the paramString once sorted
    var paramPairs = [];
    // The param string that will be added to the output
    var paramString = "";

    // The list of parameters that needs to be in the signature
    var params = {
      "oauth_consumer_key": _oauth_consumer_key,
      "oauth_nonce": _oauth_nonce,
      "oauth_signature_method": _oauth_signature_method,
      "oauth_timestamp": _oauth_timestamp,
      "oauth_token": _oauth_token,
      "oauth_version": _oauth_version
    };

    // Join the 2 paramater maps
    params.addAll(opt);

    // Loop through the parameter map and add each pair to paramPairs
    params.forEach((k, v) {
      // For each key/value pair:
      // Percent encode every key and value that will be signed.
      // Append the encoded key to the output string.
      // Append the ‘=’ character to the output string.
      // Append the encoded value to the output string.
      paramPairs.add(_percentEncode(k) + "=" + _percentEncode(v.toString()));
    });

    // Sort the list of parameters alphabetically [1] by encoded key [2].
    // Since encoded key is first in the string, it is what it will be sorted by
    paramPairs.sort();

    // Put all the params together into paramString
    paramString = paramPairs.join("&");

    // Start creating the output string
    // Convert the HTTP Method to uppercase and set the output string equal to this value.
    // Append the ‘&’ character to the output string.
    var output = method.toUpperCase() + "&";
    // Percent encode the URL and append it to the output string.
    // Append the ‘&’ character to the output string.
    output +=  _percentEncode(_baseUrl + url) + "&";
    // Percent encode the parameter string and append it to the output string.
    output +=  _percentEncode(paramString);

    // Now output is the signature base string
    List<int> signatureBaseString = utf8.encode(output);

    // Get a signing key by combining consumer secret and token secret
    List<int> signingKey = utf8.encode(_percentEncode(_consumerSecret) + "&" + _percentEncode(_tokenSecret));

    // Create an Hmac object with the signing key
    var hmacSha1 = new Hmac(sha1, signingKey);
    // Put the signature base string into the hmac object
    var digest = hmacSha1.convert(signatureBaseString);

    // Base64 encode the bites returned from the hmac-sha1 operation
    return base64Url.encode(digest.bytes);
  }

  /// This function will percent encode [val] accoring to twitters rules 
  /// specified here:
  /// https://developer.twitter.com/en/docs/basics/authentication/guides/percent-encoding-parameters
  _percentEncode(String val) {
    // Convert input string to bytes
    List<int> bytes = utf8.encode(val);
    // List<int> output = [];
    String output = "";

    // Loop through each letter in val
    for(var i = 0; i < bytes.length; i++) {
      // Get the individual character
      var char = bytes[i];

      // If the byte is not listed in the table, encode it
      // Otherwise, add it to the output
      if(!_percentEncodeValues.contains(char)) {
        // Add a % to the output
        // output += "%"; 
        output += String.fromCharCode(0x25);
        // convert char to a string representing the hexidecimal of char
        // Get the specific byte of the string that we want to use
        // make it uppercase (required by twitter)
        // Add the string to the output
        output += char.toRadixString(16)[0].toUpperCase();
        output += char.toRadixString(16)[1].toUpperCase();
      }
      else
      {
        // Add the character to the output list of bytes
        output += val[i];
      }
    }

    // Return the fully encoded string
    return output;
  }

  /// This function creates a nonce for the request
  _generateNonce() {
    // This code comes from this tutorial
    // https://www.scottbrady91.com/Dart/Generating-a-Crypto-Random-String-in-Dart
    final random = Random.secure();

    // Generate 32 bytes of random data
    var values = List<int>.generate(32, (i) => random.nextInt(256));
    // Base64 encode the data
    var encodedNonce = base64Url.encode(values);
    // Remove all non-alpha characters
    var strippedNonce = encodedNonce.replaceAll(new RegExp(r'[^a-zA-Z]'), '');

    return strippedNonce;
  }
}
