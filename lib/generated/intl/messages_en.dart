// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(name, days) =>
      "Are you sure you want to approve ${name}\'s vacation request for ${days} days?";

  static String m1(name, days) =>
      "Are you sure you want to reject ${name}\'s vacation request for ${days} days?";

  static String m2(name) => "${name}\'s Balance";

  static String m3(days) => "Insufficient balance. Available: ${days} days";

  static String m4(current, total) => "Page ${current} of ${total}";

  static String m5(date) => "Requested on ${date}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "action": MessageLookupByLibrary.simpleMessage("Action"),
        "actions": MessageLookupByLibrary.simpleMessage("Actions"),
        "active": MessageLookupByLibrary.simpleMessage("Active"),
        "activeEmployees":
            MessageLookupByLibrary.simpleMessage("Active Employees"),
        "add": MessageLookupByLibrary.simpleMessage("Add"),
        "addDepartment": MessageLookupByLibrary.simpleMessage("Add Department"),
        "addEmployee": MessageLookupByLibrary.simpleMessage("Add Employee"),
        "addHoliday": MessageLookupByLibrary.simpleMessage("Add Holiday"),
        "addNewEmployee":
            MessageLookupByLibrary.simpleMessage("Add New Employee"),
        "address": MessageLookupByLibrary.simpleMessage("Address"),
        "afternoon": MessageLookupByLibrary.simpleMessage("Afternoon"),
        "allSystemSettings":
            MessageLookupByLibrary.simpleMessage("All System Settings"),
        "allTypes": MessageLookupByLibrary.simpleMessage("All Types"),
        "annualLeave": MessageLookupByLibrary.simpleMessage("Annual Leave"),
        "appearance": MessageLookupByLibrary.simpleMessage("Appearance"),
        "apply": MessageLookupByLibrary.simpleMessage("Apply"),
        "approveRequest":
            MessageLookupByLibrary.simpleMessage("Approve Request"),
        "approved": MessageLookupByLibrary.simpleMessage("Approved"),
        "attendanceOverview":
            MessageLookupByLibrary.simpleMessage("Attendance Overview"),
        "availableDays": MessageLookupByLibrary.simpleMessage("Available Days"),
        "back": MessageLookupByLibrary.simpleMessage("Back"),
        "backupFilesEOD":
            MessageLookupByLibrary.simpleMessage("Backup Files EOD"),
        "calendar": MessageLookupByLibrary.simpleMessage("Calendar"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cancelled": MessageLookupByLibrary.simpleMessage("Cancelled"),
        "checkInTime": MessageLookupByLibrary.simpleMessage("Check-In Time"),
        "checkInTime1": MessageLookupByLibrary.simpleMessage("Check-In 1"),
        "checkInTime2": MessageLookupByLibrary.simpleMessage("Check-In 2"),
        "checkInTime3": MessageLookupByLibrary.simpleMessage("Check-In 3"),
        "checkInTime4": MessageLookupByLibrary.simpleMessage("Check-In 4"),
        "checkOutTime1": MessageLookupByLibrary.simpleMessage("Check-Out 1"),
        "checkOutTime2": MessageLookupByLibrary.simpleMessage("Check-Out 2"),
        "chooseFile": MessageLookupByLibrary.simpleMessage("choose file"),
        "choosePrimaryColor": MessageLookupByLibrary.simpleMessage(
            "Choose your primary app color"),
        "chooseSecondaryColor": MessageLookupByLibrary.simpleMessage(
            "Choose your secondary app color"),
        "city": MessageLookupByLibrary.simpleMessage("City"),
        "clearFilters": MessageLookupByLibrary.simpleMessage("Clear Filters"),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "colorPreview": MessageLookupByLibrary.simpleMessage("Color Preview"),
        "companyHolidayInfo": MessageLookupByLibrary.simpleMessage(
            "This is a company holiday. Regular employees are entitled to a day off. Specific departments may have different arrangements. Please check with your manager."),
        "confirmApprove":
            MessageLookupByLibrary.simpleMessage("Confirm Approve"),
        "confirmApproveMessage": m0,
        "confirmCancel": MessageLookupByLibrary.simpleMessage("Confirm Cancel"),
        "confirmCancelMessage": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to cancel this vacation request?"),
        "confirmDelete": MessageLookupByLibrary.simpleMessage("Confirm Delete"),
        "confirmReject": MessageLookupByLibrary.simpleMessage("Confirm Reject"),
        "confirmRejectMessage": m1,
        "contract": MessageLookupByLibrary.simpleMessage("Contract"),
        "customizeTheme": MessageLookupByLibrary.simpleMessage(
            "Customize how your theme looks on your device"),
        "dark": MessageLookupByLibrary.simpleMessage("Dark"),
        "date": MessageLookupByLibrary.simpleMessage("Date"),
        "dateColon": MessageLookupByLibrary.simpleMessage("Date:"),
        "dateOfBirth": MessageLookupByLibrary.simpleMessage("Date of Birth"),
        "day": MessageLookupByLibrary.simpleMessage("Day"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteHolidayConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete this holiday?"),
        "department": MessageLookupByLibrary.simpleMessage("Department"),
        "departmentAddedSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Department added successfully"),
        "departmentName":
            MessageLookupByLibrary.simpleMessage("Department Name"),
        "departmentNameRequired":
            MessageLookupByLibrary.simpleMessage("Department name is required"),
        "description": MessageLookupByLibrary.simpleMessage("Description"),
        "designation": MessageLookupByLibrary.simpleMessage("Designation"),
        "desktopNotification":
            MessageLookupByLibrary.simpleMessage("Desktop Notification"),
        "desktopPushDescription": MessageLookupByLibrary.simpleMessage(
            "Receive push notification in desktop"),
        "dragAndDrop": MessageLookupByLibrary.simpleMessage("Drag & Drop"),
        "duration": MessageLookupByLibrary.simpleMessage("Duration"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "editVacationRequest":
            MessageLookupByLibrary.simpleMessage("Edit Vacation Request"),
        "ellipsis": MessageLookupByLibrary.simpleMessage("..."),
        "emailAddress": MessageLookupByLibrary.simpleMessage("Email Address"),
        "emailNotifications":
            MessageLookupByLibrary.simpleMessage("Email Notifications"),
        "employeeBalance": m2,
        "employeeId": MessageLookupByLibrary.simpleMessage("Employee ID"),
        "employeeName": MessageLookupByLibrary.simpleMessage("Employee Name"),
        "employeeProfile":
            MessageLookupByLibrary.simpleMessage("Employee Profile"),
        "employeeType": MessageLookupByLibrary.simpleMessage("Employee Type"),
        "employees": MessageLookupByLibrary.simpleMessage("Employees"),
        "endDate": MessageLookupByLibrary.simpleMessage("End Date"),
        "endTime": MessageLookupByLibrary.simpleMessage("End Time"),
        "english": MessageLookupByLibrary.simpleMessage("English"),
        "enterDepartmentName":
            MessageLookupByLibrary.simpleMessage("Enter department name"),
        "enterDescription": MessageLookupByLibrary.simpleMessage(
            "Enter description (optional)"),
        "enterHolidayName":
            MessageLookupByLibrary.simpleMessage("Enter holiday name"),
        "filter": MessageLookupByLibrary.simpleMessage("Filter"),
        "filterByDate": MessageLookupByLibrary.simpleMessage("Filter by Date"),
        "filterByMonth":
            MessageLookupByLibrary.simpleMessage("Filter by Month"),
        "filterByYear": MessageLookupByLibrary.simpleMessage("Filter by Year"),
        "firstName": MessageLookupByLibrary.simpleMessage("First Name"),
        "firstOccurrence":
            MessageLookupByLibrary.simpleMessage("First Occurrence"),
        "french": MessageLookupByLibrary.simpleMessage("French"),
        "fullTime": MessageLookupByLibrary.simpleMessage("Full-time"),
        "gender": MessageLookupByLibrary.simpleMessage("Gender"),
        "holidayAddedSuccessfully":
            MessageLookupByLibrary.simpleMessage("Holiday added successfully"),
        "holidayDate": MessageLookupByLibrary.simpleMessage("Holiday Date"),
        "holidayDeletedSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Holiday deleted successfully"),
        "holidayDetails":
            MessageLookupByLibrary.simpleMessage("Holiday Details"),
        "holidayInfo":
            MessageLookupByLibrary.simpleMessage("Holiday Information"),
        "holidayName": MessageLookupByLibrary.simpleMessage("Holiday Name"),
        "holidayNameRequired":
            MessageLookupByLibrary.simpleMessage("Holiday name is required"),
        "holidayType": MessageLookupByLibrary.simpleMessage("Holiday Type"),
        "holidays": MessageLookupByLibrary.simpleMessage("Holidays"),
        "holidaysList": MessageLookupByLibrary.simpleMessage("Holidays List"),
        "home": MessageLookupByLibrary.simpleMessage("Home"),
        "inactive": MessageLookupByLibrary.simpleMessage("Inactive"),
        "insufficientBalance": m3,
        "itemsPerPage": MessageLookupByLibrary.simpleMessage("Items per page"),
        "joiningDate": MessageLookupByLibrary.simpleMessage("Joining Date"),
        "juniorFullStackDeveloper":
            MessageLookupByLibrary.simpleMessage("Junior Full Stack Developer"),
        "justNow": MessageLookupByLibrary.simpleMessage("Just now"),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "lastName": MessageLookupByLibrary.simpleMessage("Last Name"),
        "late": MessageLookupByLibrary.simpleMessage("Late"),
        "light": MessageLookupByLibrary.simpleMessage("Light"),
        "maritalStatus": MessageLookupByLibrary.simpleMessage("Marital Status"),
        "maternityLeave":
            MessageLookupByLibrary.simpleMessage("Maternity Leave"),
        "members": MessageLookupByLibrary.simpleMessage("Members"),
        "menu": MessageLookupByLibrary.simpleMessage("Menu"),
        "messages": MessageLookupByLibrary.simpleMessage("Messages"),
        "minAgo": MessageLookupByLibrary.simpleMessage("min ago"),
        "mobileNumber": MessageLookupByLibrary.simpleMessage("Mobile Number"),
        "mobilePushNotifications":
            MessageLookupByLibrary.simpleMessage("Mobile Push Notifications"),
        "month": MessageLookupByLibrary.simpleMessage("Month"),
        "morning": MessageLookupByLibrary.simpleMessage("Morning"),
        "nationality": MessageLookupByLibrary.simpleMessage("Nationality"),
        "next": MessageLookupByLibrary.simpleMessage("Next"),
        "nextPage": MessageLookupByLibrary.simpleMessage("Next"),
        "noAttendanceRecords":
            MessageLookupByLibrary.simpleMessage("No attendance records found"),
        "noDepartmentsFound":
            MessageLookupByLibrary.simpleMessage("No departments found"),
        "noEmployeesFound":
            MessageLookupByLibrary.simpleMessage("No employees found"),
        "noHolidays": MessageLookupByLibrary.simpleMessage(
            "No holidays found for this period"),
        "noPendingRequests":
            MessageLookupByLibrary.simpleMessage("No pending requests"),
        "noRequestsToDisplay":
            MessageLookupByLibrary.simpleMessage("No requests to display"),
        "noVacationHistory":
            MessageLookupByLibrary.simpleMessage("No vacation history"),
        "officeLocation":
            MessageLookupByLibrary.simpleMessage("Office Location"),
        "onTime": MessageLookupByLibrary.simpleMessage("On Time"),
        "or": MessageLookupByLibrary.simpleMessage("or"),
        "outOf": MessageLookupByLibrary.simpleMessage("out of"),
        "pageOf": m4,
        "pagination": MessageLookupByLibrary.simpleMessage("Pagination"),
        "partTime": MessageLookupByLibrary.simpleMessage("Part-time"),
        "pastHolidays": MessageLookupByLibrary.simpleMessage("Past Holidays"),
        "paternityLeave":
            MessageLookupByLibrary.simpleMessage("Paternity Leave"),
        "pending": MessageLookupByLibrary.simpleMessage("Pending"),
        "pendingDays": MessageLookupByLibrary.simpleMessage("Pending Days"),
        "pendingTimeOff":
            MessageLookupByLibrary.simpleMessage("Pending Time Off"),
        "personalInformation":
            MessageLookupByLibrary.simpleMessage("Personal Information"),
        "personalLeave": MessageLookupByLibrary.simpleMessage("Personal Leave"),
        "pleaseFillRequiredFields": MessageLookupByLibrary.simpleMessage(
            "Please fill in all required fields"),
        "previousPage": MessageLookupByLibrary.simpleMessage("Previous"),
        "primaryColor": MessageLookupByLibrary.simpleMessage("Primary Color"),
        "primaryColorSample":
            MessageLookupByLibrary.simpleMessage("Primary Color"),
        "professionalInformation":
            MessageLookupByLibrary.simpleMessage("Professional Information"),
        "profile": MessageLookupByLibrary.simpleMessage("Profile"),
        "publicHolidayInfo": MessageLookupByLibrary.simpleMessage(
            "This is a public holiday. All employees are entitled to a day off with regular pay. If you need to work on this day, please contact HR for overtime approval."),
        "reason": MessageLookupByLibrary.simpleMessage("Reason"),
        "receiveEmailNotification":
            MessageLookupByLibrary.simpleMessage("Receive email notification"),
        "receivePushNotification":
            MessageLookupByLibrary.simpleMessage("Receive push notification"),
        "recentActivities":
            MessageLookupByLibrary.simpleMessage("Recent Activities"),
        "recentEvents": MessageLookupByLibrary.simpleMessage("Recent Events"),
        "records": MessageLookupByLibrary.simpleMessage("records"),
        "recurring": MessageLookupByLibrary.simpleMessage("Recurring"),
        "recurringYearly":
            MessageLookupByLibrary.simpleMessage("Recurring yearly"),
        "refreshData": MessageLookupByLibrary.simpleMessage("Refresh Data"),
        "rejectRequest": MessageLookupByLibrary.simpleMessage("Reject Request"),
        "rejected": MessageLookupByLibrary.simpleMessage("Rejected"),
        "remote": MessageLookupByLibrary.simpleMessage("Remote"),
        "requestApproved": MessageLookupByLibrary.simpleMessage(
            "Request approved successfully"),
        "requestCancelled": MessageLookupByLibrary.simpleMessage(
            "Vacation request cancelled successfully"),
        "requestLeave": MessageLookupByLibrary.simpleMessage("Request Leave"),
        "requestRejected": MessageLookupByLibrary.simpleMessage(
            "Request rejected successfully"),
        "requestSubmitted": MessageLookupByLibrary.simpleMessage(
            "Vacation request submitted successfully"),
        "requestVacation":
            MessageLookupByLibrary.simpleMessage("Request Vacation"),
        "requestedOn": m5,
        "robertAllen": MessageLookupByLibrary.simpleMessage("Robert Allen"),
        "search": MessageLookupByLibrary.simpleMessage("Search"),
        "secondaryColor":
            MessageLookupByLibrary.simpleMessage("Secondary Color"),
        "secondaryColorSample":
            MessageLookupByLibrary.simpleMessage("Accent Color"),
        "selectDate": MessageLookupByLibrary.simpleMessage("Select Date"),
        "selectDepartment":
            MessageLookupByLibrary.simpleMessage("Select Department"),
        "selectDesignation":
            MessageLookupByLibrary.simpleMessage("Select Designation"),
        "selectFilter": MessageLookupByLibrary.simpleMessage("Select Filter"),
        "selectLanguage":
            MessageLookupByLibrary.simpleMessage("Select your language"),
        "selectPrimaryColor":
            MessageLookupByLibrary.simpleMessage("Select Primary Color"),
        "selectSecondaryColor":
            MessageLookupByLibrary.simpleMessage("Select Secondary Color"),
        "selectType": MessageLookupByLibrary.simpleMessage("Select Type"),
        "sendMailToHrAndAdmin":
            MessageLookupByLibrary.simpleMessage("Send Mail to HR and Admin"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "showing": MessageLookupByLibrary.simpleMessage("Showing"),
        "sickLeave": MessageLookupByLibrary.simpleMessage("Sick Leave"),
        "startDate": MessageLookupByLibrary.simpleMessage("Start Date"),
        "startTime": MessageLookupByLibrary.simpleMessage("Start Time"),
        "state": MessageLookupByLibrary.simpleMessage("State"),
        "status": MessageLookupByLibrary.simpleMessage("Status"),
        "submitRequest": MessageLookupByLibrary.simpleMessage("Submit Request"),
        "supportedFormats": MessageLookupByLibrary.simpleMessage(
            "Supported formats: .jpeg, .png, .pdf"),
        "system": MessageLookupByLibrary.simpleMessage("System"),
        "to": MessageLookupByLibrary.simpleMessage("to"),
        "toUpload": MessageLookupByLibrary.simpleMessage("to upload"),
        "today": MessageLookupByLibrary.simpleMessage("Today"),
        "todayAttendance":
            MessageLookupByLibrary.simpleMessage("Today Attendance"),
        "totalDays": MessageLookupByLibrary.simpleMessage("Total Days"),
        "totalDepartments":
            MessageLookupByLibrary.simpleMessage("Total Departments"),
        "totalEmployee": MessageLookupByLibrary.simpleMessage("Total Employee"),
        "totalEmployees":
            MessageLookupByLibrary.simpleMessage("Total Employees"),
        "twoFactorAuth":
            MessageLookupByLibrary.simpleMessage("Two-factor Authentication"),
        "twoFactorDescription": MessageLookupByLibrary.simpleMessage(
            "Keep your account secure by enabling 2FA via mail"),
        "type": MessageLookupByLibrary.simpleMessage("Type"),
        "upcoming": MessageLookupByLibrary.simpleMessage("Upcoming"),
        "updateRequest": MessageLookupByLibrary.simpleMessage("Update Request"),
        "updatedServerLogs":
            MessageLookupByLibrary.simpleMessage("Updated Server Logs"),
        "usedDays": MessageLookupByLibrary.simpleMessage("Used Days"),
        "userName": MessageLookupByLibrary.simpleMessage("User Name"),
        "vacation": MessageLookupByLibrary.simpleMessage("Vacation"),
        "vacationBalance":
            MessageLookupByLibrary.simpleMessage("Vacation Balance"),
        "vacationManagement":
            MessageLookupByLibrary.simpleMessage("Vacation Management"),
        "vacationRequests":
            MessageLookupByLibrary.simpleMessage("Vacation Requests"),
        "vacationType": MessageLookupByLibrary.simpleMessage("Vacation Type"),
        "view": MessageLookupByLibrary.simpleMessage("View"),
        "viewAll": MessageLookupByLibrary.simpleMessage("View All"),
        "viewBalance": MessageLookupByLibrary.simpleMessage("View Balance"),
        "workingDays": MessageLookupByLibrary.simpleMessage("Working Days"),
        "year": MessageLookupByLibrary.simpleMessage("Year"),
        "yearlyRecurring":
            MessageLookupByLibrary.simpleMessage("Yearly Recurring Holiday"),
        "zipCode": MessageLookupByLibrary.simpleMessage("ZIP Code")
      };
}
