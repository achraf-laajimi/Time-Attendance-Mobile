import 'package:shared_preferences/shared_preferences.dart';
class NavigationItem {
  final String key;
  final String label;
  final int index;

  NavigationItem({
    required this.key,
    required this.label,
    required this.index,
  });

}

class RoleHelper {
  static  List<NavigationItem> employeeNavItems = [
    NavigationItem(key: 'home', label: 'Home', index: 0),
    NavigationItem(key: 'vacation', label: 'Vacation', index: 2),
    NavigationItem(key: 'holidays', label: 'holidays', index: 6),
    NavigationItem(key: 'profile', label: 'Profile', index: 4),
    NavigationItem(key: 'remote_attendance', label: 'Remote Attendance', index: 7),
    NavigationItem(key: 'settings', label: 'Settings', index: 8),

  ];

  static  List<NavigationItem> managerNavItems = [
    NavigationItem(key: 'home', label: 'Home', index: 0),
    NavigationItem(key: 'employees', label: 'Employees', index: 1),
    NavigationItem(key: 'vacation', label: 'Vacation', index: 2),
    NavigationItem(key: 'attendance', label: 'Attendance', index: 3),
    NavigationItem(key: 'profile', label: 'Profile', index: 4),
    NavigationItem(key: 'departments', label: 'Departments', index: 5),
    NavigationItem(key: 'remote_attendance', label: 'Remote Attendance', index: 7),
    NavigationItem(key: 'settings', label: 'Settings', index: 8),
  ];

  static  List<NavigationItem> adminNavItems = [
    NavigationItem(key: 'home', label: 'Home', index: 0),
    NavigationItem(key: 'employees', label: 'Employees', index: 1),
    NavigationItem(key: 'vacation', label: 'Vacation', index: 2),
    NavigationItem(key: 'attendance', label: 'Attendance', index: 3),
    NavigationItem(key: 'profile', label: 'Profile', index: 4),
    NavigationItem(key: 'departments', label: 'Departments', index: 5),
    NavigationItem(key: 'holidays', label: 'Holidays', index: 6),
    NavigationItem(key: 'remote_attendance', label: 'Remote Attendance', index: 7),
    NavigationItem(key: 'settings', label: 'Settings', index: 8),
  ];

  static  List<NavigationItem> hrNavItems = [
    NavigationItem(key: 'home', label: 'Home', index: 0),
    NavigationItem(key: 'employees', label: 'Employees', index: 1),
    NavigationItem(key: 'vacation', label: 'Vacation', index: 2),
    NavigationItem(key: 'attendance', label: 'Attendance', index: 3),
    NavigationItem(key: 'profile', label: 'Profile', index: 4),
    NavigationItem(key: 'departments', label: 'Departments', index: 5),
    NavigationItem(key: 'holidays', label: 'Holidays', index: 6),
    NavigationItem(key: 'remote_attendance', label: 'Remote Attendance', index: 7),
    NavigationItem(key: 'settings', label: 'Settings', index: 8),
  ];

  static Future<String> getUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_role') ?? 'USER';
    } catch (e) {
      print('Error getting user role: $e');
      return 'USER';
    }
  }

  static Future<void> setUserRole(String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', role.toUpperCase());
    } catch (e) {
      print('Error setting user role: $e');
    }
  }

  static Future<bool> hasPermission(String permission) async {
    final role = await getUserRole();

    switch (permission.toLowerCase()) {
      case 'manage_employees':
        return ['ADMIN', 'MANAGER', 'HR'].contains(role.toUpperCase());
      case 'manage_departments':
        return ['ADMIN', 'MANAGER'].contains(role.toUpperCase());
      case 'manage_holidays':
        return ['ADMIN', 'HR'].contains(role.toUpperCase());
      case 'view_all_attendance':
        return ['ADMIN', 'MANAGER', 'HR'].contains(role.toUpperCase());
      case 'manage_vacations':
        return ['ADMIN', 'MANAGER', 'HR'].contains(role.toUpperCase());
      case 'system_settings':
        return ['ADMIN'].contains(role.toUpperCase());
      default:
        return false;
    }
  }

  static Future<List<NavigationItem>> getNavigationItems() async {
    final role = await getUserRole();

    switch (role.toUpperCase()) {
      case 'ADMIN':
        return adminNavItems;
      case 'MANAGER':
        return managerNavItems;
      case 'HR':
        return hrNavItems;
      case 'USER':
      default:
        return employeeNavItems;
    }
  }

  static Future<bool> isUserAdmin() async {
    final role = await getUserRole();
    return role.toUpperCase() == 'ADMIN';
  }

  static Future<bool> isUserManager() async {
    final role = await getUserRole();
    return ['ADMIN', 'MANAGER'].contains(role.toUpperCase());
  }

  static Future<bool> isUserHR() async {
    final role = await getUserRole();
    return ['ADMIN', 'HR'].contains(role.toUpperCase());
  }

  static Future<bool> isUserEmployee() async {
    final role = await getUserRole();
    return role.toUpperCase() == 'USER';
  }

  static String getRoleDisplayName(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return 'Administrator';
      case 'MANAGER':
        return 'Manager';
      case 'HR':
        return 'Human Resources';
      case 'USER':
        return 'Employee';
      default:
        return 'Unknown Role';
    }
  }

  static Future<bool> canAccessScreen(String screenKey) async {
    final navigationItems = await getNavigationItems();
    return navigationItems.any((item) => item.key == screenKey);
  }

  static Future<void> clearUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_role');
    } catch (e) {
      print('Error clearing user role: $e');
    }
  }
}