part of firebase_dart;

/// The entry point for accessing a Firebase Database.
///
/// To access a location in the database and read or write data, use `reference()`.
abstract class FirebaseDatabase {
  /// The [FirebaseApp] instance to which this [FirebaseDatabase] belongs.
  ///
  /// If null, the default [FirebaseApp] is used.
  FirebaseApp get app;

  /// The URL to which this [FirebaseDatabase] belongs
  ///
  /// If null, the URL of the specified [FirebaseApp] is used
  String get databaseURL;

  /// Gets an instance of [FirebaseDatabase].
  ///
  /// If app is specified, its options should include a `databaseURL`.
  factory FirebaseDatabase({FirebaseApp? app, String? databaseURL}) {
    return FirebaseImplementation.installation
        .createDatabase(app ?? Firebase.app(), databaseURL: databaseURL);
  }

  /// Gets a DatabaseReference for the root of your Firebase Database.
  DatabaseReference reference();

  /// Resumes our connection to the Firebase Database backend after a previous
  /// [goOffline] call.
  Future<void> goOnline();

  /// Shuts down our connection to the Firebase Database backend until
  /// [goOnline] is called.
  Future<void> goOffline();

  /// The Firebase Database client automatically queues writes and sends them to
  /// the server at the earliest opportunity, depending on network connectivity.
  /// In some cases (e.g. offline usage) there may be a large number of writes
  /// waiting to be sent. Calling this method will purge all outstanding writes
  /// so they are abandoned.
  ///
  /// All writes will be purged, including transactions and onDisconnect writes.
  /// The writes will be rolled back locally, perhaps triggering events for
  /// affected event listeners, and the client will not (re-)send them to the
  /// Firebase Database backend.
  Future<void> purgeOutstandingWrites();

  /// Attempts to sets the database persistence to [enabled].
  ///
  /// This property must be set before calling methods on database references
  /// and only needs to be called once per application. The returned [Future]
  /// will complete with `true` if the operation was successful or `false` if
  /// the persistence could not be set (because database references have
  /// already been created).
  ///
  /// The Firebase Database client will cache synchronized data and keep track
  /// of all writes you’ve initiated while your application is running. It
  /// seamlessly handles intermittent network connections and re-sends write
  /// operations when the network connection is restored.
  ///
  /// However by default your write operations and cached data are only stored
  /// in-memory and will be lost when your app restarts. By setting [enabled]
  /// to `true`, the data will be persisted to on-device (disk) storage and will
  /// thus be available again when the app is restarted (even when there is no
  /// network connectivity at that time).
  Future<bool> setPersistenceEnabled(bool enabled);

  /// Attempts to set the size of the persistence cache.
  ///
  /// By default the Firebase Database client will use up to 10MB of disk space
  /// to cache data. If the cache grows beyond this size, the client will start
  /// removing data that hasn’t been recently used. If you find that your
  /// application caches too little or too much data, call this method to change
  /// the cache size.
  ///
  /// This property must be set before calling methods on database references
  /// and only needs to be called once per application. The returned Future will
  /// complete with true if the operation was successful or false if the value
  /// could not be set (because database references have already been created).
  ///
  /// Note that the specified cache size is only an approximation and the size
  /// on disk may temporarily exceed it at times. Cache sizes smaller than 1 MB
  /// or greater than 100 MB are not supported.
  Future<bool> setPersistenceCacheSizeBytes(int cacheSizeInBytes);
}
