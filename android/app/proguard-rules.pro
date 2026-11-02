# Google Mobile Ads pulls in WorkManager 2.7.0 and with it Room 2.2.5, whose
# rule keeps generated databases but not their constructors. R8 full mode
# then strips WorkDatabase_Impl's constructor, which Room calls by reflection,
# and release builds crash at launch opening WorkManager's database.
-keep class * extends androidx.room.RoomDatabase { <init>(); }
