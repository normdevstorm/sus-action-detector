import 'dart:convert';

import 'package:firebaseapis/identitytoolkit/v1.dart';
import 'package:firebaseapis/identitytoolkit/v1.dart' as id;
import 'package:firebaseapis/identitytoolkit/v2.dart' as v2;

import 'package:http/http.dart' as http;
import 'package:_discoveryapis_commons/_discoveryapis_commons.dart' as commons;

import '../../../implementation/pure_dart.dart';
import '../error.dart';
import 'error.dart';

export 'package:firebaseapis/identitytoolkit/v1.dart';

class _MyApiRequester extends commons.ApiRequester {
  _MyApiRequester(http.Client httpClient, String rootUrl, String basePath)
      : super(httpClient, rootUrl, basePath, {});

  final Duration _shortTimeout = Duration(seconds: 30);
  final Duration _longTimeout = Duration(seconds: 60);

  static const _offlineTimeout = Duration(seconds: 5);

  Duration get timeoutDuration {
    // navigator.onLine is unreliable in some cases.
    // Failing hard in those cases may make it impossible to recover for end user.
    // Waiting for the regular full duration when there is no network can result
    // in a bad experience.
    // Instead return a short timeout duration. If there is no network connection,
    // the user would wait 5 seconds to detect that. If there is a connection
    // (false alert case), the user still has the ability to try to send the
    // request. If it fails (timeout too short), they can still retry.
    if (!Platform.current.isOnline) {
      // Pick the shorter timeout.
      return _offlineTimeout < _shortTimeout ? _offlineTimeout : _shortTimeout;
    }
    // If running in a mobile environment, return the long delay, otherwise
    // return the short delay.
    // This could be improved in the future to dynamically change based on other
    // variables instead of just reading the current environment.
    return Platform.current.isMobile ? _longTimeout : _shortTimeout;
  }

  @override
  Future request(String requestUrl, String method,
      {String? body,
      Map<String, List<String>>? queryParams,
      commons.Media? uploadMedia,
      commons.UploadOptions? uploadOptions,
      commons.DownloadOptions? downloadOptions =
          commons.DownloadOptions.metadata}) async {
    queryParams ??= {};
    try {
      var fields = queryParams.remove('fields') ?? [];

      return await super
          .request(requestUrl, method,
              body: body,
              queryParams: {
                ...queryParams,
                if (fields.isNotEmpty)
                  ...Uri.splitQueryString(fields.first)
                      .map((k, v) => MapEntry(k, [v])),
              },
              uploadMedia: uploadMedia,
              uploadOptions: uploadOptions,
              downloadOptions: downloadOptions)
          .timeout(timeoutDuration,
              onTimeout: () =>
                  throw FirebaseAuthException.networkRequestFailed());
    } on commons.DetailedApiRequestError catch (e) {
      var errorCode = e.message;
      String? errorMessage;
      FirebaseAuthException? error;
      if (errorCode != null) {
        // Get detailed message if available.
        var match = RegExp(r'^([^\s]+)\s*:\s*(.*)$').firstMatch(errorCode);
        if (match != null) {
          errorCode = match.group(1);
          errorMessage = match.group(2);
        }

        error = authErrorFromServerErrorCode(errorCode!);
      }
      if (error == null) {
        error = FirebaseAuthException.internalError();
        errorMessage ??= json.encode(e.jsonResponse);
      }
      throw error.replace(message: errorMessage);
    }
  }
}

class IdentityToolkitApi implements id.IdentityToolkitApi {
  final commons.ApiRequester _requester;

  @override
  AccountsResource get accounts => AccountsResource(_requester);
  @override
  ProjectsResource get projects => ProjectsResource(_requester);
  @override
  V1Resource get v1 => V1Resource(_requester);

  v2.AccountsMfaEnrollmentResource get mfaEnrollment =>
      v2.AccountsMfaEnrollmentResource(_requester);
  v2.AccountsMfaSignInResource get mfaSignIn =>
      v2.AccountsMfaSignInResource(_requester);

  IdentityToolkitApi(http.Client client,
      {String rootUrl = 'https://identitytoolkit.googleapis.com/',
      String servicePath = ''})
      : _requester = _MyApiRequester(client, rootUrl, servicePath);
}

// The classes below override the generated classes to add new fields as these
// are not available in the firebaseapis package version <0.2.0. Once we no longer
// support dart 2, we can upgrade to firebaseapis version >=0.2.0 and remove these
// overrides.

class V1Resource extends id.V1Resource {
  final commons.ApiRequester _requester;

  V1Resource(commons.ApiRequester client)
      : _requester = client,
        super(client);

  @override
  Future<GoogleCloudIdentitytoolkitV1GetRecaptchaParamResponse>
      getRecaptchaParams({
    String? $fields,
  }) async {
    final queryParams = <String, List<String>>{
      if ($fields != null) 'fields': [$fields],
    };

    const url = 'v1/recaptchaParams';

    final response = await _requester.request(
      url,
      'GET',
      queryParams: queryParams,
    );
    return GoogleCloudIdentitytoolkitV1GetRecaptchaParamResponse.fromJson(
        response as Map<String, dynamic>);
  }
}

class GoogleCloudIdentitytoolkitV1GetRecaptchaParamResponse
    extends id.GoogleCloudIdentitytoolkitV1GetRecaptchaParamResponse {
  String? producerProjectNumber;

  GoogleCloudIdentitytoolkitV1GetRecaptchaParamResponse.fromJson(Map json)
      : producerProjectNumber = json.containsKey('producerProjectNumber')
            ? json['producerProjectNumber'] as String
            : null,
        super(
          kind: json.containsKey('kind') ? json['kind'] as String : null,
          recaptchaSiteKey: json.containsKey('recaptchaSiteKey')
              ? json['recaptchaSiteKey'] as String
              : null,
          recaptchaStoken: json.containsKey('recaptchaStoken')
              ? json['recaptchaStoken'] as String
              : null,
        );
}

class GoogleCloudIdentitytoolkitV2StartMfaPhoneRequestInfo
    extends v2.GoogleCloudIdentitytoolkitV2StartMfaPhoneRequestInfo {
  String? playIntegrityToken;

  GoogleCloudIdentitytoolkitV2StartMfaPhoneRequestInfo();

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        if (playIntegrityToken != null)
          'playIntegrityToken': playIntegrityToken!,
      };
}

class GoogleCloudIdentitytoolkitV1SendVerificationCodeRequest
    extends id.GoogleCloudIdentitytoolkitV1SendVerificationCodeRequest {
  String? playIntegrityToken;

  GoogleCloudIdentitytoolkitV1SendVerificationCodeRequest();

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        if (playIntegrityToken != null)
          'playIntegrityToken': playIntegrityToken!,
      };
}
