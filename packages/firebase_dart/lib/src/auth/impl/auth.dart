import 'dart:async';
import 'dart:collection';

import 'package:firebase_dart/core.dart';
import 'package:firebase_dart/implementation/pure_dart.dart';
import 'package:firebase_dart/src/auth/auth_mixin.dart';
import 'package:firebase_dart/src/auth/authhandlers.dart';
import 'package:firebase_dart/src/auth/rpc/http_util.dart';
import 'package:firebase_dart/src/core/impl/app.dart';
import 'package:firebase_dart/src/implementation.dart';
import 'package:firebase_dart/src/implementation/dart.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:openid_client/openid_client.dart' as openid;
import 'package:rxdart/rxdart.dart';

import '../auth.dart';
import '../multi_factor.dart';
import '../rpc/rpc_handler.dart';
import '../usermanager.dart';
import 'user.dart';

/// The entry point of the Firebase Authentication SDK.
class FirebaseAuthImpl extends FirebaseService with FirebaseAuthMixin {
  late final RpcHandler rpcHandler =
      RpcHandler(app.options.apiKey, httpClient: httpClient);

  late final UserManager userStorageManager = UserManager(this);

  /// Completes when latest logged in user is loaded from storage
  late final Future<void> _onReady;

  late StreamSubscription _storageManagerUserChangedSubscription;

  final BehaviorSubject<FirebaseUserImpl?> _currentUser = BehaviorSubject();

  final MetadataClient httpClient;

  late StreamSubscription _userChangedSubscription;

  FirebaseAuthImpl(FirebaseApp app, {Client? httpClient})
      : httpClient = MetadataClient(httpClient ?? Client(),
            firebaseAppId: app.options.appId),
        super(app) {
    _onReady = _init();
    getRedirectResult().timeout(Duration(seconds: 5)).ignore();
  }

  Future<void> _init() async {
    _currentUser.add((await userStorageManager.getCurrentUser())
      ?..initializeProactiveRefresh());

    _storageManagerUserChangedSubscription =
        userStorageManager.onCurrentUserChanged.listen((user) {
      if (_currentUser.value?.uid != user?.uid) {
        _currentUser.value?.destroy();
        user?.initializeProactiveRefresh();
        _currentUser.add(user);
      }
    });

    _userChangedSubscription = userChanges().listen((v) {
      userStorageManager.setCurrentUser(v);
    });
  }

  @override
  Future<UserCredential> signInAnonymously() async {
    await _onReady;

    var user = currentUser;

    // If an anonymous user is already signed in, no need to sign him again.
    if (user != null && user.isAnonymous) {
      var additionalUserInfo = createAdditionalUserInfo(isNewUser: false);
      return UserCredentialImpl(
          // Return the signed in user reference.
          user: user,
          // Do not return credential for anonymous user.
          credential: null,
          // Return any additional IdP data.
          additionalUserInfo: additionalUserInfo,
          // Sign in operation type.
          operationType: UserCredentialImpl.operationTypeSignIn);
    } else {
      // No anonymous user currently signed in.
      return await _handleSignInResult(await rpcHandler.signInAnonymously(),
          isNewUser: true);
    }
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    String? password,
  }) async {
    return await _handleSignInResult(
        await rpcHandler.signInWithPassword(email, password),
        isNewUser: false);
  }

  /// Handles user state changes.
  Future<void> _handleUserStateChange(User? user) async {
    await userStorageManager.setCurrentUser(user);
  }

  Future<UserCredential> _handleSignInResult(SignInResult signInResult,
      {String? provider, AuthCredential? credential, bool? isNewUser}) async {
    if (signInResult.mfaPendingCredential != null) {
      throw FirebaseAuthMultiFactorException(MultiFactorResolverImpl(
        this,
        mfaPendingCredential: signInResult.mfaPendingCredential!,
        hints: signInResult.mfaInfo!,
      ));
    }

    var openidCredential = signInResult.credential;
    // Get additional IdP data if available in the response.
    var additionalUserInfo = createAdditionalUserInfo(
        credential: openidCredential,
        providerId: provider,
        isNewUser: isNewUser);

    // When custom token is exchanged for idToken, continue sign in with
    // ID token and return firebase Auth user.
    await _signInWithIdTokenResponse(openidCredential);

    // Resolve promise with a readonly user credential object.
    return UserCredentialImpl(
      // Return the current user reference.
      user: currentUser,
      // Return any credential passed from the backend.
      credential: credential,
      // Return any additional IdP data passed from the backend.
      additionalUserInfo: additionalUserInfo,
      // Sign in operation type.
      operationType: UserCredentialImpl.operationTypeSignIn,
    );
  }

  /// Completes the headless sign in with the server response containing the STS
  /// access and refresh tokens, and sets the Auth user as current user while
  /// setting all listeners to it and saving it to storage.
  Future<void> _signInWithIdTokenResponse(openid.Credential credential) async {
    // Wait for state to be ready.
    await _onReady;

    // Initialize an Auth user using the provided ID token response.
    var user =
        await FirebaseUserImpl.initializeFromOpenidCredential(this, credential);

    // Check if the same user is already signed in.
    if (currentUser != null && user.uid == currentUser!.uid) {
      // Same user signed in. Update user data and notify Auth listeners.
      // No need to resubscribe to user events.
      user = currentUser!..copy(user as FirebaseUserImpl?);
      return _handleUserStateChange(currentUser);
    }

    await _handleUserStateChange(user);
  }

  @override
  Future<void> confirmPasswordReset(String oobCode, String newPassword) async {
    await rpcHandler.confirmPasswordReset(oobCode, newPassword);
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword(
      {required String email, String? password}) async {
    await _onReady;

    return await _handleSignInResult(await rpcHandler.signUp(email, password),
        isNewUser: true);
  }

  @override
  FirebaseUserImpl? get currentUser => _currentUser.valueOrNull;

  @override
  Future<List<String>> fetchSignInMethodsForEmail(String email) {
    return rpcHandler.fetchSignInMethodsForIdentifier(email);
  }

  @override
  bool isSignInWithEmailLink(String link) {
    return getActionCodeUrlFromSignInEmailLink(link) != null;
  }

  @override
  Stream<User?> authStateChanges() => _currentUser.distinct().cast();

  @override
  Future<void> sendPasswordResetEmail(
      {required String email, ActionCodeSettings? actionCodeSettings}) {
    return rpcHandler.sendPasswordResetEmail(
        email: email, actionCodeSettings: actionCodeSettings);
  }

  @override
  Future<void> sendSignInLinkToEmail(
      {required String email,
      required ActionCodeSettings actionCodeSettings}) async {
    if (actionCodeSettings.url.isEmpty) {
      throw FirebaseAuthException.invalidContinueUri();
    }

    if (actionCodeSettings.handleCodeInApp == false) {
      throw FirebaseAuthException.argumentError(
          'handleCodeInApp true when sending sign in link to email.');
    }

    var box = await userStorageManager.storage;
    await box.put('emailForSignIn', email);

    await rpcHandler.sendSignInLinkToEmail(
        email: email, actionCodeSettings: actionCodeSettings);
  }

  @override
  Future<UserCredential?> trySignInWithEmailLink(
      {Future<String?> Function()? askUserForEmail}) async {
    var url = FirebaseDart.baseUrl;
    if (!isSignInWithEmailLink(url.toString())) {
      return null;
    }
    var email = url.queryParameters['email'] ??
        (await userStorageManager.storage).get('emailForSignIn');
    if (email == null && askUserForEmail != null) {
      email = await askUserForEmail();
    }
    if (email == null) return null;

    return signInWithEmailLink(email: email, emailLink: url.toString());
  }

  @override
  Future<void> setLanguageCode(String language) async {
    httpClient.locale = language;
  }

  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    await _onReady;

    if (credential is PhoneAuthCredential) {
      return _handleSignInResult(
        await rpcHandler.signInWithPhoneNumber(
            sessionInfo: credential.verificationId, code: credential.smsCode),
        credential: credential,
        isNewUser: false,
        provider: credential.providerId,
      );
    }

    if (credential is OAuthCredential) {
      var result = await rpcHandler.signInWithIdp(
          postBody: Uri(queryParameters: {
            if (credential.idToken != null) 'id_token': credential.idToken,
            if (credential.accessToken != null)
              'access_token': credential.accessToken,
            if (credential.secret != null)
              'oauth_token_secret': credential.secret,
            'providerId': credential.providerId,
            if (credential.rawNonce != null) 'nonce': credential.rawNonce
          }).query,
          requestUri: 'http://localhost');
      return _handleSignInResult(
        result,
        credential: credential,
        isNewUser: false,
        provider: credential.providerId,
      );
    }

    if (credential is EmailAuthCredential) {
      if (credential.password != null) {
        return signInWithEmailAndPassword(
            email: credential.email, password: credential.password);
      } else {
        return signInWithEmailLink(
            email: credential.email, emailLink: credential.emailLink);
      }
    }

    if (credential is FirebaseAppAuthCredential) {
      var result = await rpcHandler.signInWithIdp(
          sessionId: credential.sessionId, requestUri: credential.link);

      return _handleSignInResult(
        result,
        isNewUser: false,
      );
    }

    throw UnimplementedError();
  }

  @override
  Future<UserCredential> signInWithCustomToken(String token) async {
    // Wait for the redirect state to be determined before proceeding. If critical
    // errors like web storage unsupported are detected, fail before RPC, instead
    // of after.
    await _onReady;
    return await _handleSignInResult(
        await rpcHandler.signInWithCustomToken(token),
        isNewUser: false);
  }

  @override
  Future<void> signOut() async {
    await _onReady;
    // Ignore if already signed out.
    if (currentUser == null) {
      return;
    }
    await PureDartFirebaseImplementation.installation.authHandler
        .signOut(app, currentUser!);

    // Detach all event listeners.
    currentUser!.destroy();
    // Set current user to null.
    await userStorageManager.removeCurrentUser();
  }

  @override
  Future<void> verifyPhoneNumber({
    String? phoneNumber,
    PhoneMultiFactorInfo? multiFactorInfo,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    @visibleForTesting String? autoRetrievedSmsCodeForTesting,
    Duration timeout = const Duration(seconds: 30),
    int? forceResendingToken,
    MultiFactorSession? multiFactorSession,
    RecaptchaVerifier? verifier,
  }) async {
    var impl =
        FirebaseImplementation.installation as PureDartFirebaseImplementation;
    var appSignatureHash = await impl.smsRetriever.getAppSignatureHash();

    var smsFuture = impl.smsRetriever.retrieveSms();

    String verificationId;

    Future<String> requestVerificationId(
        ApplicationVerificationResult assertion) async {
      if (multiFactorSession != null) {
        if ((multiFactorSession as MultiFactorSessionImpl).type ==
            MultiFactorSessionType.enrollment) {
          return await rpcHandler.startMultiFactorEnrollment(
            idToken: multiFactorSession.credential,
            phoneNumber: phoneNumber,
            appSignatureHash: appSignatureHash,
            recaptchaToken:
                assertion.type == 'recaptcha' ? assertion.token : null,
            playIntegrityToken:
                assertion.type == 'playintegrity' ? assertion.token : null,
            iosReceipt: assertion.type == 'apns'
                ? assertion.token.split(':').first
                : null,
            iosSecret: assertion.type == 'apns'
                ? assertion.token.split(':').last
                : null,
          );
        } else {
          return await rpcHandler.startMultiFactorSignIn(
            mfaPendingCredential: multiFactorSession.credential,
            mfaEnrollmentId: multiFactorInfo!.uid,
            appSignatureHash: appSignatureHash,
            recaptchaToken:
                assertion.type == 'recaptcha' ? assertion.token : null,
            playIntegrityToken:
                assertion.type == 'playintegrity' ? assertion.token : null,
            iosReceipt: assertion.type == 'apns'
                ? assertion.token.split(':').first
                : null,
            iosSecret: assertion.type == 'apns'
                ? assertion.token.split(':').last
                : null,
          );
        }
      } else {
        return await rpcHandler.sendVerificationCode(
          phoneNumber: phoneNumber,
          appSignatureHash: appSignatureHash,
          recaptchaToken:
              assertion.type == 'recaptcha' ? assertion.token : null,
          playIntegrityToken:
              assertion.type == 'playintegrity' ? assertion.token : null,
          iosReceipt: assertion.type == 'apns'
              ? assertion.token.split(':').first
              : null,
          iosSecret:
              assertion.type == 'apns' ? assertion.token.split(':').last : null,
        );
      }
    }

    try {
      var assertion = await (verifier
              ?.verify()
              .then((v) => ApplicationVerificationResult(verifier.type, v)) ??
          impl.applicationVerifier
              .verify(this, phoneNumber ?? multiFactorInfo?.phoneNumber ?? ''));

      verificationId = await requestVerificationId(assertion);
    } catch (e) {
      var assertion = await impl.applicationVerifier.verify(
          this, phoneNumber ?? multiFactorInfo?.phoneNumber ?? '',
          forceRecaptcha: true);
      verificationId = await requestVerificationId(assertion);
    }

    codeSent(verificationId, 0 /*TODO*/);

    smsFuture.timeout(timeout, onTimeout: () {
      codeAutoRetrievalTimeout(verificationId);
      return null;
    }).then((v) async {
      if (v == null) return;
      var code = RegExp(r'(?<!\d)\d{6}(?!\d)').firstMatch(v)!.group(0)!;
      var credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: code);

      verificationCompleted(credential);
    }).ignore();
  }

  @override
  Future<void> applyActionCode(String code) async {
    await rpcHandler.applyActionCode(code);
  }

  @override
  Future<ActionCodeInfo> checkActionCode(String code) async {
    var response = await rpcHandler.checkActionCode(code);

    var email = response.email;
    var newEmail = response.newEmail;
    var operation = ActionCodeInfoImpl.parseOperation(response.requestType);

    // The multi-factor info for revert second factor addition.
    var mfaInfo = response.mfaInfo;

    // Email could be empty only if the request type is EMAIL_SIGNIN or
    // VERIFY_AND_CHANGE_EMAIL.
    // New email should not be empty if the request type is
    // VERIFY_AND_CHANGE_EMAIL.
    // Multi-factor info could not be empty if the request type is
    // REVERT_SECOND_FACTOR_ADDITION.
    if (operation == ActionCodeInfoOperation.unknown ||
        (operation != ActionCodeInfoOperation.emailSignIn &&
            operation != ActionCodeInfoOperation.verifyAndChangeEmail &&
            email == null) ||
        (operation == ActionCodeInfoOperation.verifyAndChangeEmail &&
            newEmail == null) ||
        (operation == ActionCodeInfoOperation.revertSecondFactorAddition &&
            mfaInfo == null)) {
      throw FirebaseAuthException.internalError(
          'Invalid checkActionCode response!');
    }

    Map<String, dynamic> data;
    if (operation == ActionCodeInfoOperation.verifyAndChangeEmail) {
      data = {'fromEmail': email, 'previousEmail': email, 'email': newEmail};
    } else {
      data = {'fromEmail': newEmail, 'previousEmail': newEmail, 'email': email};
    }
    data['multiFactorInfo'] = mfaInfo;
    return ActionCodeInfoImpl(
        operation: operation, data: UnmodifiableMapView(data));
  }

  Future<UserCredential>? _redirectResult;

  @override
  Future<UserCredential> getRedirectResult() {
    if (_redirectResult != null) return _redirectResult!;
    Future<UserCredential>? v;
    v = Future.microtask(() async {
      var credential = await PureDartFirebaseImplementation
          .installation.authHandler
          .getSignInResult(app);

      if (_redirectResult != v) return UserCredentialImpl();
      if (credential == null) {
        return UserCredentialImpl();
      }

      return signInWithCredential(credential);
    });
    return _redirectResult = v;
  }

  @override
  Stream<User?> idTokenChanges() {
    return authStateChanges().switchMap((user) {
      if (user == null) return Stream.value(user);
      return (user as FirebaseUserImpl).accessTokenChanged.map((_) => user);
    });
  }

  @override
  // TODO: implement languageCode
  String get languageCode => throw UnimplementedError();

  @override
  Future<void> setPersistence(Persistence persistence) {
    // TODO: implement setPersistence
    throw UnimplementedError();
  }

  Future<UserCredential> signInWithMultiFactorAssertion(
      MultiFactorAssertion assertion, MultiFactorSession session) async {
    var phoneCredential = (assertion as PhoneMultiFactorAssertion).credential;
    var r = await rpcHandler.finalizeMultiFactorSignIn(
        mfaPendingCredential: (session as MultiFactorSessionImpl).credential,
        code: phoneCredential.smsCode,
        phoneNumber: phoneCredential.phoneNumber,
        sessionInfo: phoneCredential.verificationId);

    return _handleSignInResult(r, isNewUser: false);
  }

  @override
  Future<UserCredential> signInWithEmailLink(
      {String? email, String? emailLink}) async {
    if (emailLink == null) {
      var platform = Platform.current;
      if (platform is WebPlatform) {
        emailLink = platform.currentUrl;
      }
    }
    // Check if the tenant ID in the email link matches the tenant ID on Auth
    // instance.
    var actionCodeUrl = getActionCodeUrlFromSignInEmailLink(emailLink!);
    if (actionCodeUrl == null) {
      throw FirebaseAuthException.argumentError('Invalid email link!');
    }
/* TODO:    if (actionCodeUrl.tenantId != this.tenantId) {
      throw FirebaseAuthException.tenantIdMismatch();
    }
 */
    return await _handleSignInResult(
        await rpcHandler.signInWithEmailLink(email!, actionCodeUrl.code),
        isNewUser: false);
  }

  Future<void> _signIn(AuthProvider provider, bool isPopup) async {
    _redirectResult = null;
    var v = await PureDartFirebaseImplementation.installation.authHandler
        .signIn(app, provider, isPopup: isPopup);

    if (!v) {
      throw FirebaseAuthException.internalError(
          'Auth handler cannot handle provider $provider');
    }
  }

  @override
  Future<UserCredential> signInWithPopup(AuthProvider provider) async {
    await _signIn(provider, true);
    return getRedirectResult();
  }

  @override
  Future<void> signInWithRedirect(AuthProvider provider) async {
    await _signIn(provider, false);
  }

  @override
  Stream<User?> userChanges() {
    return idTokenChanges().switchMap((value) =>
        (value as FirebaseUserImpl?)?.userChanged ?? Stream.value(null));
  }

  @override
  Future<String> verifyPasswordResetCode(String code) async {
    var info = await checkActionCode(code);
    return info.data['email'];
  }

  @override
  String toString() {
    return 'FirebaseAuth(app: ${app.name})';
  }

  @override
  Future<void> delete() async {
    await _onReady;
    currentUser?.destroy();
    await userStorageManager.close();
    await _storageManagerUserChangedSubscription.cancel();
    await _userChangedSubscription.cancel();
    await _currentUser.close();
    await super.delete();
  }

  @override
  Future<UserCredential> signInWithAuthProvider(AuthProvider provider) {
    // TODO: implement signInWithAuthProvider
    throw UnimplementedError();
  }
}

class UserCredentialImpl extends UserCredential {
  /// Operation involving signing in a user.
  static const operationTypeSignIn = 'signIn';

  /// Operation involving using a provider to reauthenticate an already signed-in user.
  static const operationTypeReauthenticate = 'reauthenticate';

  /// Operation involving linking an additional provider to an already signed-in user.
  static const operationTypeLink = 'link';

  @override
  final User? user;

  @override
  final AdditionalUserInfo? additionalUserInfo;

  @override
  final AuthCredential? credential;

  /// Returns the operation type.
  final String? operationType;

  UserCredentialImpl(
      {this.user,
      this.additionalUserInfo,
      this.credential,
      this.operationType});
}

class ActionCodeInfoImpl extends ActionCodeInfo {
  @override
  final Map<String, dynamic> data;

  @override
  final ActionCodeInfoOperation operation;

  ActionCodeInfoImpl({required this.data, required this.operation});

  static ActionCodeInfoOperation parseOperation(String? requestType) {
    switch (requestType) {
      case 'EMAIL_SIGNIN':
        return ActionCodeInfoOperation.emailSignIn;
      case 'PASSWORD_RESET':
        return ActionCodeInfoOperation.passwordReset;
      case 'RECOVER_EMAIL':
        return ActionCodeInfoOperation.recoverEmail;
      case 'REVERT_SECOND_FACTOR_ADDITION':
        return ActionCodeInfoOperation.revertSecondFactorAddition;
      case 'VERIFY_AND_CHANGE_EMAIL':
        return ActionCodeInfoOperation.verifyAndChangeEmail;
      case 'VERIFY_EMAIL':
        return ActionCodeInfoOperation.verifyEmail;
    }
    return ActionCodeInfoOperation.unknown;
  }
}

ActionCodeURL? getActionCodeUrlFromSignInEmailLink(String emailLink) {
  emailLink = DynamicLink.parseDeepLink(emailLink);
  var actionCodeUrl = ActionCodeURL.parseLink(emailLink);
  if (actionCodeUrl != null &&
      (actionCodeUrl.operation == ActionCodeInfoOperation.emailSignIn)) {
    return actionCodeUrl;
  }
  return null;
}

class ActionCodeURL {
  /// Returns an ActionCodeURL instance if the link is valid, otherwise null.
  static ActionCodeURL? parseLink(String actionLink) {
    try {
      var uri = Uri.parse(actionLink);
      var apiKey = uri.queryParameters['apiKey'];
      var code = uri.queryParameters['oobCode'];
      var mode = uri.queryParameters['mode'];
      var operation = getOperation(mode);
      // Validate API key, code and mode.
      if (apiKey == null ||
          code == null ||
          operation == ActionCodeInfoOperation.unknown) {
        throw FirebaseAuthException.argumentError(
            'apiKey, oobCode and mode are required in a valid action code URL.');
      }
      return ActionCodeURL(
        apiKey: apiKey,
        operation: operation,
        code: code,
        continueUrl: uri.queryParameters['continueUrl'],
        languageCode: uri.queryParameters['languageCode'],
        tenantId: uri.queryParameters['tenantId'],
      );
    } catch (e) {
      return null;
    }
  }

  /// Maps the mode string in action code URL to Action Code Info operation.
  static ActionCodeInfoOperation getOperation(String? mode) {
    switch (mode) {
      case 'recoverEmail':
        return ActionCodeInfoOperation.recoverEmail;
      case 'resetPassword':
        return ActionCodeInfoOperation.passwordReset;
      case 'revertSecondFactorAddition':
        return ActionCodeInfoOperation.revertSecondFactorAddition;
      case 'signIn':
        return ActionCodeInfoOperation.emailSignIn;
      case 'verifyAndChangeEmail':
        return ActionCodeInfoOperation.verifyAndChangeEmail;
      case 'verifyEmail':
        return ActionCodeInfoOperation.verifyEmail;
    }
    return ActionCodeInfoOperation.unknown;
  }

  final String apiKey;

  final ActionCodeInfoOperation operation;

  final String code;

  final String? continueUrl;

  final String? languageCode;

  final String? tenantId;

  ActionCodeURL(
      {required this.apiKey,
      required this.operation,
      required this.code,
      this.continueUrl,
      this.languageCode,
      this.tenantId});
}

class DynamicLink {
  static String parseDeepLink(String url) {
    var uri = Uri.parse(url);
    // iOS custom scheme links.
    var iOSdeepLink = uri.queryParameters['deep_link_id'];
    if (iOSdeepLink != null) {
      var iOSDoubledeepLink = Uri.parse(iOSdeepLink).queryParameters['link'];
      return iOSDoubledeepLink ?? iOSdeepLink;
    }

    var link = uri.queryParameters['link'];

    if (link != null) {
      // Double link case (automatic redirect).
      var doubleDeepLink = Uri.parse(link).queryParameters['link'];
      return doubleDeepLink ?? link;
    }
    return url;
  }
}
