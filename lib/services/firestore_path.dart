/*
This class defines all the possible read/write locations from the FirebaseFirestore database.
In future, any new path can be added here.
This class work together with FirestoreService and FirestoreDatabase.
 */

class FirestorePath {
  static String todo(String uid, String todoId) => 'users/$uid/todos/$todoId';
  static String todos(String uid) => 'users/$uid/todos';

  static String masjid(String masjidId) => 'masjids/$masjidId';
  static String masjids() => 'masjids';
  static String myMasjid(String uid, String masjidId) =>
      'users/$uid/my_masjids/$masjidId';
  static String myMasjids(String uid) => 'users/$uid/my_masjids';
  static String user(String uId) => 'uers/$uId';
  static String masjidsCreatedByMe(String uid) => 'masjids';
}
