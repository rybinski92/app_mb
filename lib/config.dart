class Config {
  static String apiKey1 = const String.fromEnvironment(
    'APPSHEET_API_KEY_1', 
    defaultValue: 'default_key_1'
  );
  static String apiKey2 = const String.fromEnvironment(
    'APPSHEET_API_KEY_2', 
    defaultValue: 'default_key_2'
  );
  static String apiKey3 = const String.fromEnvironment(
    'APPSHEET_API_KEY_3', 
    defaultValue: 'default_key_3'
  );
  static String apiKey4 = const String.fromEnvironment(
    'APPSHEET_API_KEY_4', 
    defaultValue: 'default_key_4'
  );
}