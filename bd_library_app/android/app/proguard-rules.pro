# google_mlkit_text_recognition : les modèles CJK / Devanagari sont en compileOnly dans le plugin.
# Sans ces règles, R8 échoue en release avec "Missing class ... ChineseTextRecognizerOptions", etc.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
