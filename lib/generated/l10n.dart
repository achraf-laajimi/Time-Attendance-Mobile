// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class AppLocalizations {
  AppLocalizations();

  static AppLocalizations? _current;

  static AppLocalizations get current {
    assert(_current != null,
        'No instance of AppLocalizations was loaded. Try to initialize the AppLocalizations delegate before accessing AppLocalizations.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<AppLocalizations> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = AppLocalizations();
      AppLocalizations._current = instance;

      return instance;
    });
  }

  static AppLocalizations of(BuildContext context) {
    final instance = AppLocalizations.maybeOf(context);
    assert(instance != null,
        'No instance of AppLocalizations present in the widget tree. Did you add AppLocalizations.delegate in localizationsDelegates?');
    return instance!;
  }

  static AppLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `All System Settings`
  String get allSystemSettings {
    return Intl.message(
      'All System Settings',
      name: 'allSystemSettings',
      desc: '',
      args: [],
    );
  }

  /// `Appearance`
  String get appearance {
    return Intl.message(
      'Appearance',
      name: 'appearance',
      desc: '',
      args: [],
    );
  }

  /// `Customize how your theme looks on your device`
  String get customizeTheme {
    return Intl.message(
      'Customize how your theme looks on your device',
      name: 'customizeTheme',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Select your language`
  String get selectLanguage {
    return Intl.message(
      'Select your language',
      name: 'selectLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Two-factor Authentication`
  String get twoFactorAuth {
    return Intl.message(
      'Two-factor Authentication',
      name: 'twoFactorAuth',
      desc: '',
      args: [],
    );
  }

  /// `Keep your account secure by enabling 2FA via mail`
  String get twoFactorDescription {
    return Intl.message(
      'Keep your account secure by enabling 2FA via mail',
      name: 'twoFactorDescription',
      desc: '',
      args: [],
    );
  }

  /// `Mobile Push Notifications`
  String get mobilePushNotifications {
    return Intl.message(
      'Mobile Push Notifications',
      name: 'mobilePushNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Receive push notification`
  String get receivePushNotification {
    return Intl.message(
      'Receive push notification',
      name: 'receivePushNotification',
      desc: '',
      args: [],
    );
  }

  /// `Desktop Notification`
  String get desktopNotification {
    return Intl.message(
      'Desktop Notification',
      name: 'desktopNotification',
      desc: '',
      args: [],
    );
  }

  /// `Receive push notification in desktop`
  String get desktopPushDescription {
    return Intl.message(
      'Receive push notification in desktop',
      name: 'desktopPushDescription',
      desc: '',
      args: [],
    );
  }

  /// `Email Notifications`
  String get emailNotifications {
    return Intl.message(
      'Email Notifications',
      name: 'emailNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Receive email notification`
  String get receiveEmailNotification {
    return Intl.message(
      'Receive email notification',
      name: 'receiveEmailNotification',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get light {
    return Intl.message(
      'Light',
      name: 'light',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get dark {
    return Intl.message(
      'Dark',
      name: 'dark',
      desc: '',
      args: [],
    );
  }

  /// `System`
  String get system {
    return Intl.message(
      'System',
      name: 'system',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message(
      'English',
      name: 'english',
      desc: '',
      args: [],
    );
  }

  /// `French`
  String get french {
    return Intl.message(
      'French',
      name: 'french',
      desc: '',
      args: [],
    );
  }

  /// `Robert Allen`
  String get robertAllen {
    return Intl.message(
      'Robert Allen',
      name: 'robertAllen',
      desc: '',
      args: [],
    );
  }

  /// `Junior Full Stack Developer`
  String get juniorFullStackDeveloper {
    return Intl.message(
      'Junior Full Stack Developer',
      name: 'juniorFullStackDeveloper',
      desc: '',
      args: [],
    );
  }

  /// `Total Employee`
  String get totalEmployee {
    return Intl.message(
      'Total Employee',
      name: 'totalEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Today Attendance`
  String get todayAttendance {
    return Intl.message(
      'Today Attendance',
      name: 'todayAttendance',
      desc: '',
      args: [],
    );
  }

  /// `Pending Time Off`
  String get pendingTimeOff {
    return Intl.message(
      'Pending Time Off',
      name: 'pendingTimeOff',
      desc: '',
      args: [],
    );
  }

  /// `Total Departments`
  String get totalDepartments {
    return Intl.message(
      'Total Departments',
      name: 'totalDepartments',
      desc: '',
      args: [],
    );
  }

  /// `Attendance Overview`
  String get attendanceOverview {
    return Intl.message(
      'Attendance Overview',
      name: 'attendanceOverview',
      desc: '',
      args: [],
    );
  }

  /// `Day`
  String get day {
    return Intl.message(
      'Day',
      name: 'day',
      desc: '',
      args: [],
    );
  }

  /// `Month`
  String get month {
    return Intl.message(
      'Month',
      name: 'month',
      desc: '',
      args: [],
    );
  }

  /// `Year`
  String get year {
    return Intl.message(
      'Year',
      name: 'year',
      desc: '',
      args: [],
    );
  }

  /// `Recent Events`
  String get recentEvents {
    return Intl.message(
      'Recent Events',
      name: 'recentEvents',
      desc: '',
      args: [],
    );
  }

  /// `View All`
  String get viewAll {
    return Intl.message(
      'View All',
      name: 'viewAll',
      desc: '',
      args: [],
    );
  }

  /// `Updated Server Logs`
  String get updatedServerLogs {
    return Intl.message(
      'Updated Server Logs',
      name: 'updatedServerLogs',
      desc: '',
      args: [],
    );
  }

  /// `Just now`
  String get justNow {
    return Intl.message(
      'Just now',
      name: 'justNow',
      desc: '',
      args: [],
    );
  }

  /// `Send Mail to HR and Admin`
  String get sendMailToHrAndAdmin {
    return Intl.message(
      'Send Mail to HR and Admin',
      name: 'sendMailToHrAndAdmin',
      desc: '',
      args: [],
    );
  }

  /// `min ago`
  String get minAgo {
    return Intl.message(
      'min ago',
      name: 'minAgo',
      desc: '',
      args: [],
    );
  }

  /// `Backup Files EOD`
  String get backupFilesEOD {
    return Intl.message(
      'Backup Files EOD',
      name: 'backupFilesEOD',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Calendar`
  String get calendar {
    return Intl.message(
      'Calendar',
      name: 'calendar',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `Messages`
  String get messages {
    return Intl.message(
      'Messages',
      name: 'messages',
      desc: '',
      args: [],
    );
  }

  /// `Menu`
  String get menu {
    return Intl.message(
      'Menu',
      name: 'menu',
      desc: '',
      args: [],
    );
  }

  /// `Employees`
  String get employees {
    return Intl.message(
      'Employees',
      name: 'employees',
      desc: '',
      args: [],
    );
  }

  /// `Employee Name`
  String get employeeName {
    return Intl.message(
      'Employee Name',
      name: 'employeeName',
      desc: '',
      args: [],
    );
  }

  /// `Employee ID`
  String get employeeId {
    return Intl.message(
      'Employee ID',
      name: 'employeeId',
      desc: '',
      args: [],
    );
  }

  /// `Department`
  String get department {
    return Intl.message(
      'Department',
      name: 'department',
      desc: '',
      args: [],
    );
  }

  /// `Designation`
  String get designation {
    return Intl.message(
      'Designation',
      name: 'designation',
      desc: '',
      args: [],
    );
  }

  /// `Type`
  String get type {
    return Intl.message(
      'Type',
      name: 'type',
      desc: '',
      args: [],
    );
  }

  /// `Action`
  String get action {
    return Intl.message(
      'Action',
      name: 'action',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Add New Employee`
  String get addNewEmployee {
    return Intl.message(
      'Add New Employee',
      name: 'addNewEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Filter`
  String get filter {
    return Intl.message(
      'Filter',
      name: 'filter',
      desc: '',
      args: [],
    );
  }

  /// `View`
  String get view {
    return Intl.message(
      'View',
      name: 'view',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Total Employees`
  String get totalEmployees {
    return Intl.message(
      'Total Employees',
      name: 'totalEmployees',
      desc: '',
      args: [],
    );
  }

  /// `Active Employees`
  String get activeEmployees {
    return Intl.message(
      'Active Employees',
      name: 'activeEmployees',
      desc: '',
      args: [],
    );
  }

  /// `Recent Activities`
  String get recentActivities {
    return Intl.message(
      'Recent Activities',
      name: 'recentActivities',
      desc: '',
      args: [],
    );
  }

  /// `Pagination`
  String get pagination {
    return Intl.message(
      'Pagination',
      name: 'pagination',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get nextPage {
    return Intl.message(
      'Next',
      name: 'nextPage',
      desc: '',
      args: [],
    );
  }

  /// `Previous`
  String get previousPage {
    return Intl.message(
      'Previous',
      name: 'previousPage',
      desc: '',
      args: [],
    );
  }

  /// `Page {current} of {total}`
  String pageOf(Object current, Object total) {
    return Intl.message(
      'Page $current of $total',
      name: 'pageOf',
      desc: '',
      args: [current, total],
    );
  }

  /// `Items per page`
  String get itemsPerPage {
    return Intl.message(
      'Items per page',
      name: 'itemsPerPage',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get active {
    return Intl.message(
      'Active',
      name: 'active',
      desc: '',
      args: [],
    );
  }

  /// `Inactive`
  String get inactive {
    return Intl.message(
      'Inactive',
      name: 'inactive',
      desc: '',
      args: [],
    );
  }

  /// `Contract`
  String get contract {
    return Intl.message(
      'Contract',
      name: 'contract',
      desc: '',
      args: [],
    );
  }

  /// `Full-time`
  String get fullTime {
    return Intl.message(
      'Full-time',
      name: 'fullTime',
      desc: '',
      args: [],
    );
  }

  /// `Part-time`
  String get partTime {
    return Intl.message(
      'Part-time',
      name: 'partTime',
      desc: '',
      args: [],
    );
  }

  /// `Remote`
  String get remote {
    return Intl.message(
      'Remote',
      name: 'remote',
      desc: '',
      args: [],
    );
  }

  /// `No employees found`
  String get noEmployeesFound {
    return Intl.message(
      'No employees found',
      name: 'noEmployeesFound',
      desc: '',
      args: [],
    );
  }

  /// `Select Department`
  String get selectDepartment {
    return Intl.message(
      'Select Department',
      name: 'selectDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Select Designation`
  String get selectDesignation {
    return Intl.message(
      'Select Designation',
      name: 'selectDesignation',
      desc: '',
      args: [],
    );
  }

  /// `Select Type`
  String get selectType {
    return Intl.message(
      'Select Type',
      name: 'selectType',
      desc: '',
      args: [],
    );
  }

  /// `Clear Filters`
  String get clearFilters {
    return Intl.message(
      'Clear Filters',
      name: 'clearFilters',
      desc: '',
      args: [],
    );
  }

  /// `Showing`
  String get showing {
    return Intl.message(
      'Showing',
      name: 'showing',
      desc: '',
      args: [],
    );
  }

  /// `to`
  String get to {
    return Intl.message(
      'to',
      name: 'to',
      desc: '',
      args: [],
    );
  }

  /// `out of`
  String get outOf {
    return Intl.message(
      'out of',
      name: 'outOf',
      desc: '',
      args: [],
    );
  }

  /// `records`
  String get records {
    return Intl.message(
      'records',
      name: 'records',
      desc: '',
      args: [],
    );
  }

  /// `...`
  String get ellipsis {
    return Intl.message(
      '...',
      name: 'ellipsis',
      desc: '',
      args: [],
    );
  }

  /// `Check-In Time`
  String get checkInTime {
    return Intl.message(
      'Check-In Time',
      name: 'checkInTime',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get status {
    return Intl.message(
      'Status',
      name: 'status',
      desc: '',
      args: [],
    );
  }

  /// `Actions`
  String get actions {
    return Intl.message(
      'Actions',
      name: 'actions',
      desc: '',
      args: [],
    );
  }

  /// `On Time`
  String get onTime {
    return Intl.message(
      'On Time',
      name: 'onTime',
      desc: '',
      args: [],
    );
  }

  /// `Late`
  String get late {
    return Intl.message(
      'Late',
      name: 'late',
      desc: '',
      args: [],
    );
  }

  /// `No attendance records found`
  String get noAttendanceRecords {
    return Intl.message(
      'No attendance records found',
      name: 'noAttendanceRecords',
      desc: '',
      args: [],
    );
  }

  /// `Add Employee`
  String get addEmployee {
    return Intl.message(
      'Add Employee',
      name: 'addEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Personal Information`
  String get personalInformation {
    return Intl.message(
      'Personal Information',
      name: 'personalInformation',
      desc: '',
      args: [],
    );
  }

  /// `Professional Information`
  String get professionalInformation {
    return Intl.message(
      'Professional Information',
      name: 'professionalInformation',
      desc: '',
      args: [],
    );
  }

  /// `First Name`
  String get firstName {
    return Intl.message(
      'First Name',
      name: 'firstName',
      desc: '',
      args: [],
    );
  }

  /// `Last Name`
  String get lastName {
    return Intl.message(
      'Last Name',
      name: 'lastName',
      desc: '',
      args: [],
    );
  }

  /// `Mobile Number`
  String get mobileNumber {
    return Intl.message(
      'Mobile Number',
      name: 'mobileNumber',
      desc: '',
      args: [],
    );
  }

  /// `Email Address`
  String get emailAddress {
    return Intl.message(
      'Email Address',
      name: 'emailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Date of Birth`
  String get dateOfBirth {
    return Intl.message(
      'Date of Birth',
      name: 'dateOfBirth',
      desc: '',
      args: [],
    );
  }

  /// `Marital Status`
  String get maritalStatus {
    return Intl.message(
      'Marital Status',
      name: 'maritalStatus',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get gender {
    return Intl.message(
      'Gender',
      name: 'gender',
      desc: '',
      args: [],
    );
  }

  /// `Nationality`
  String get nationality {
    return Intl.message(
      'Nationality',
      name: 'nationality',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message(
      'Address',
      name: 'address',
      desc: '',
      args: [],
    );
  }

  /// `City`
  String get city {
    return Intl.message(
      'City',
      name: 'city',
      desc: '',
      args: [],
    );
  }

  /// `State`
  String get state {
    return Intl.message(
      'State',
      name: 'state',
      desc: '',
      args: [],
    );
  }

  /// `ZIP Code`
  String get zipCode {
    return Intl.message(
      'ZIP Code',
      name: 'zipCode',
      desc: '',
      args: [],
    );
  }

  /// `Drag & Drop`
  String get dragAndDrop {
    return Intl.message(
      'Drag & Drop',
      name: 'dragAndDrop',
      desc: '',
      args: [],
    );
  }

  /// `or`
  String get or {
    return Intl.message(
      'or',
      name: 'or',
      desc: '',
      args: [],
    );
  }

  /// `choose file`
  String get chooseFile {
    return Intl.message(
      'choose file',
      name: 'chooseFile',
      desc: '',
      args: [],
    );
  }

  /// `Supported formats: .jpeg, .png, .pdf`
  String get supportedFormats {
    return Intl.message(
      'Supported formats: .jpeg, .png, .pdf',
      name: 'supportedFormats',
      desc: '',
      args: [],
    );
  }

  /// `Employee Type`
  String get employeeType {
    return Intl.message(
      'Employee Type',
      name: 'employeeType',
      desc: '',
      args: [],
    );
  }

  /// `Working Days`
  String get workingDays {
    return Intl.message(
      'Working Days',
      name: 'workingDays',
      desc: '',
      args: [],
    );
  }

  /// `Joining Date`
  String get joiningDate {
    return Intl.message(
      'Joining Date',
      name: 'joiningDate',
      desc: '',
      args: [],
    );
  }

  /// `Office Location`
  String get officeLocation {
    return Intl.message(
      'Office Location',
      name: 'officeLocation',
      desc: '',
      args: [],
    );
  }

  /// `User Name`
  String get userName {
    return Intl.message(
      'User Name',
      name: 'userName',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message(
      'Back',
      name: 'back',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get apply {
    return Intl.message(
      'Apply',
      name: 'apply',
      desc: '',
      args: [],
    );
  }

  /// `to upload`
  String get toUpload {
    return Intl.message(
      'to upload',
      name: 'toUpload',
      desc: '',
      args: [],
    );
  }

  /// `Employee Profile`
  String get employeeProfile {
    return Intl.message(
      'Employee Profile',
      name: 'employeeProfile',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `Request Leave`
  String get requestLeave {
    return Intl.message(
      'Request Leave',
      name: 'requestLeave',
      desc: '',
      args: [],
    );
  }

  /// `Duration`
  String get duration {
    return Intl.message(
      'Duration',
      name: 'duration',
      desc: '',
      args: [],
    );
  }

  /// `Holidays`
  String get holidays {
    return Intl.message(
      'Holidays',
      name: 'holidays',
      desc: '',
      args: [],
    );
  }

  /// `Holidays List`
  String get holidaysList {
    return Intl.message(
      'Holidays List',
      name: 'holidaysList',
      desc: '',
      args: [],
    );
  }

  /// `No holidays found for this period`
  String get noHolidays {
    return Intl.message(
      'No holidays found for this period',
      name: 'noHolidays',
      desc: '',
      args: [],
    );
  }

  /// `Add Holiday`
  String get addHoliday {
    return Intl.message(
      'Add Holiday',
      name: 'addHoliday',
      desc: '',
      args: [],
    );
  }

  /// `Holiday Name`
  String get holidayName {
    return Intl.message(
      'Holiday Name',
      name: 'holidayName',
      desc: '',
      args: [],
    );
  }

  /// `Holiday Date`
  String get holidayDate {
    return Intl.message(
      'Holiday Date',
      name: 'holidayDate',
      desc: '',
      args: [],
    );
  }

  /// `Enter holiday name`
  String get enterHolidayName {
    return Intl.message(
      'Enter holiday name',
      name: 'enterHolidayName',
      desc: '',
      args: [],
    );
  }

  /// `Enter description (optional)`
  String get enterDescription {
    return Intl.message(
      'Enter description (optional)',
      name: 'enterDescription',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message(
      'Description',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `Holiday Type`
  String get holidayType {
    return Intl.message(
      'Holiday Type',
      name: 'holidayType',
      desc: '',
      args: [],
    );
  }

  /// `Recurring yearly`
  String get recurringYearly {
    return Intl.message(
      'Recurring yearly',
      name: 'recurringYearly',
      desc: '',
      args: [],
    );
  }

  /// `Holiday name is required`
  String get holidayNameRequired {
    return Intl.message(
      'Holiday name is required',
      name: 'holidayNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Holiday added successfully`
  String get holidayAddedSuccessfully {
    return Intl.message(
      'Holiday added successfully',
      name: 'holidayAddedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Holiday deleted successfully`
  String get holidayDeletedSuccessfully {
    return Intl.message(
      'Holiday deleted successfully',
      name: 'holidayDeletedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Delete`
  String get confirmDelete {
    return Intl.message(
      'Confirm Delete',
      name: 'confirmDelete',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this holiday?`
  String get deleteHolidayConfirmation {
    return Intl.message(
      'Are you sure you want to delete this holiday?',
      name: 'deleteHolidayConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Recurring`
  String get recurring {
    return Intl.message(
      'Recurring',
      name: 'recurring',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get today {
    return Intl.message(
      'Today',
      name: 'today',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get date {
    return Intl.message(
      'Date',
      name: 'date',
      desc: '',
      args: [],
    );
  }

  /// `Yearly Recurring Holiday`
  String get yearlyRecurring {
    return Intl.message(
      'Yearly Recurring Holiday',
      name: 'yearlyRecurring',
      desc: '',
      args: [],
    );
  }

  /// `First Occurrence`
  String get firstOccurrence {
    return Intl.message(
      'First Occurrence',
      name: 'firstOccurrence',
      desc: '',
      args: [],
    );
  }

  /// `Holiday Information`
  String get holidayInfo {
    return Intl.message(
      'Holiday Information',
      name: 'holidayInfo',
      desc: '',
      args: [],
    );
  }

  /// `Holiday Details`
  String get holidayDetails {
    return Intl.message(
      'Holiday Details',
      name: 'holidayDetails',
      desc: '',
      args: [],
    );
  }

  /// `This is a public holiday. All employees are entitled to a day off with regular pay. If you need to work on this day, please contact HR for overtime approval.`
  String get publicHolidayInfo {
    return Intl.message(
      'This is a public holiday. All employees are entitled to a day off with regular pay. If you need to work on this day, please contact HR for overtime approval.',
      name: 'publicHolidayInfo',
      desc: '',
      args: [],
    );
  }

  /// `This is a company holiday. Regular employees are entitled to a day off. Specific departments may have different arrangements. Please check with your manager.`
  String get companyHolidayInfo {
    return Intl.message(
      'This is a company holiday. Regular employees are entitled to a day off. Specific departments may have different arrangements. Please check with your manager.',
      name: 'companyHolidayInfo',
      desc: '',
      args: [],
    );
  }

  /// `Please fill in all required fields`
  String get pleaseFillRequiredFields {
    return Intl.message(
      'Please fill in all required fields',
      name: 'pleaseFillRequiredFields',
      desc: '',
      args: [],
    );
  }

  /// `Upcoming`
  String get upcoming {
    return Intl.message(
      'Upcoming',
      name: 'upcoming',
      desc: '',
      args: [],
    );
  }

  /// `Past Holidays`
  String get pastHolidays {
    return Intl.message(
      'Past Holidays',
      name: 'pastHolidays',
      desc: '',
      args: [],
    );
  }

  /// `Members`
  String get members {
    return Intl.message(
      'Members',
      name: 'members',
      desc: '',
      args: [],
    );
  }

  /// `No departments found`
  String get noDepartmentsFound {
    return Intl.message(
      'No departments found',
      name: 'noDepartmentsFound',
      desc: '',
      args: [],
    );
  }

  /// `Add Department`
  String get addDepartment {
    return Intl.message(
      'Add Department',
      name: 'addDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Department Name`
  String get departmentName {
    return Intl.message(
      'Department Name',
      name: 'departmentName',
      desc: '',
      args: [],
    );
  }

  /// `Enter department name`
  String get enterDepartmentName {
    return Intl.message(
      'Enter department name',
      name: 'enterDepartmentName',
      desc: '',
      args: [],
    );
  }

  /// `Department name is required`
  String get departmentNameRequired {
    return Intl.message(
      'Department name is required',
      name: 'departmentNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Department added successfully`
  String get departmentAddedSuccessfully {
    return Intl.message(
      'Department added successfully',
      name: 'departmentAddedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Primary Color`
  String get primaryColor {
    return Intl.message(
      'Primary Color',
      name: 'primaryColor',
      desc: '',
      args: [],
    );
  }

  /// `Choose your primary app color`
  String get choosePrimaryColor {
    return Intl.message(
      'Choose your primary app color',
      name: 'choosePrimaryColor',
      desc: '',
      args: [],
    );
  }

  /// `Secondary Color`
  String get secondaryColor {
    return Intl.message(
      'Secondary Color',
      name: 'secondaryColor',
      desc: '',
      args: [],
    );
  }

  /// `Choose your secondary app color`
  String get chooseSecondaryColor {
    return Intl.message(
      'Choose your secondary app color',
      name: 'chooseSecondaryColor',
      desc: '',
      args: [],
    );
  }

  /// `Select Primary Color`
  String get selectPrimaryColor {
    return Intl.message(
      'Select Primary Color',
      name: 'selectPrimaryColor',
      desc: '',
      args: [],
    );
  }

  /// `Select Secondary Color`
  String get selectSecondaryColor {
    return Intl.message(
      'Select Secondary Color',
      name: 'selectSecondaryColor',
      desc: '',
      args: [],
    );
  }

  /// `Color Preview`
  String get colorPreview {
    return Intl.message(
      'Color Preview',
      name: 'colorPreview',
      desc: '',
      args: [],
    );
  }

  /// `Primary Color`
  String get primaryColorSample {
    return Intl.message(
      'Primary Color',
      name: 'primaryColorSample',
      desc: '',
      args: [],
    );
  }

  /// `Accent Color`
  String get secondaryColorSample {
    return Intl.message(
      'Accent Color',
      name: 'secondaryColorSample',
      desc: '',
      args: [],
    );
  }

  /// `Check-In 1`
  String get checkInTime1 {
    return Intl.message(
      'Check-In 1',
      name: 'checkInTime1',
      desc: '',
      args: [],
    );
  }

  /// `Check-In 2`
  String get checkInTime2 {
    return Intl.message(
      'Check-In 2',
      name: 'checkInTime2',
      desc: '',
      args: [],
    );
  }

  /// `Check-In 3`
  String get checkInTime3 {
    return Intl.message(
      'Check-In 3',
      name: 'checkInTime3',
      desc: '',
      args: [],
    );
  }

  /// `Check-In 4`
  String get checkInTime4 {
    return Intl.message(
      'Check-In 4',
      name: 'checkInTime4',
      desc: '',
      args: [],
    );
  }

  /// `Check-Out 1`
  String get checkOutTime1 {
    return Intl.message(
      'Check-Out 1',
      name: 'checkOutTime1',
      desc: '',
      args: [],
    );
  }

  /// `Check-Out 2`
  String get checkOutTime2 {
    return Intl.message(
      'Check-Out 2',
      name: 'checkOutTime2',
      desc: '',
      args: [],
    );
  }

  /// `Select Date`
  String get selectDate {
    return Intl.message(
      'Select Date',
      name: 'selectDate',
      desc: '',
      args: [],
    );
  }

  /// `Filter by Date`
  String get filterByDate {
    return Intl.message(
      'Filter by Date',
      name: 'filterByDate',
      desc: '',
      args: [],
    );
  }

  /// `Refresh Data`
  String get refreshData {
    return Intl.message(
      'Refresh Data',
      name: 'refreshData',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Select Filter`
  String get selectFilter {
    return Intl.message(
      'Select Filter',
      name: 'selectFilter',
      desc: '',
      args: [],
    );
  }

  /// `Filter by Month`
  String get filterByMonth {
    return Intl.message(
      'Filter by Month',
      name: 'filterByMonth',
      desc: '',
      args: [],
    );
  }

  /// `Filter by Year`
  String get filterByYear {
    return Intl.message(
      'Filter by Year',
      name: 'filterByYear',
      desc: '',
      args: [],
    );
  }

  /// `Date:`
  String get dateColon {
    return Intl.message(
      'Date:',
      name: 'dateColon',
      desc: '',
      args: [],
    );
  }

  /// `Vacation`
  String get vacation {
    return Intl.message(
      'Vacation',
      name: 'vacation',
      desc: '',
      args: [],
    );
  }

  /// `Vacation Balance`
  String get vacationBalance {
    return Intl.message(
      'Vacation Balance',
      name: 'vacationBalance',
      desc: '',
      args: [],
    );
  }

  /// `Request Vacation`
  String get requestVacation {
    return Intl.message(
      'Request Vacation',
      name: 'requestVacation',
      desc: '',
      args: [],
    );
  }

  /// `Vacation Requests`
  String get vacationRequests {
    return Intl.message(
      'Vacation Requests',
      name: 'vacationRequests',
      desc: '',
      args: [],
    );
  }

  /// `Vacation Management`
  String get vacationManagement {
    return Intl.message(
      'Vacation Management',
      name: 'vacationManagement',
      desc: '',
      args: [],
    );
  }

  /// `Vacation Type`
  String get vacationType {
    return Intl.message(
      'Vacation Type',
      name: 'vacationType',
      desc: '',
      args: [],
    );
  }

  /// `Annual Leave`
  String get annualLeave {
    return Intl.message(
      'Annual Leave',
      name: 'annualLeave',
      desc: '',
      args: [],
    );
  }

  /// `Sick Leave`
  String get sickLeave {
    return Intl.message(
      'Sick Leave',
      name: 'sickLeave',
      desc: '',
      args: [],
    );
  }

  /// `Personal Leave`
  String get personalLeave {
    return Intl.message(
      'Personal Leave',
      name: 'personalLeave',
      desc: '',
      args: [],
    );
  }

  /// `Maternity Leave`
  String get maternityLeave {
    return Intl.message(
      'Maternity Leave',
      name: 'maternityLeave',
      desc: '',
      args: [],
    );
  }

  /// `Paternity Leave`
  String get paternityLeave {
    return Intl.message(
      'Paternity Leave',
      name: 'paternityLeave',
      desc: '',
      args: [],
    );
  }

  /// `Start Date`
  String get startDate {
    return Intl.message(
      'Start Date',
      name: 'startDate',
      desc: '',
      args: [],
    );
  }

  /// `End Date`
  String get endDate {
    return Intl.message(
      'End Date',
      name: 'endDate',
      desc: '',
      args: [],
    );
  }

  /// `Start Time`
  String get startTime {
    return Intl.message(
      'Start Time',
      name: 'startTime',
      desc: '',
      args: [],
    );
  }

  /// `End Time`
  String get endTime {
    return Intl.message(
      'End Time',
      name: 'endTime',
      desc: '',
      args: [],
    );
  }

  /// `Morning`
  String get morning {
    return Intl.message(
      'Morning',
      name: 'morning',
      desc: '',
      args: [],
    );
  }

  /// `Afternoon`
  String get afternoon {
    return Intl.message(
      'Afternoon',
      name: 'afternoon',
      desc: '',
      args: [],
    );
  }

  /// `Reason`
  String get reason {
    return Intl.message(
      'Reason',
      name: 'reason',
      desc: '',
      args: [],
    );
  }

  /// `Total Days`
  String get totalDays {
    return Intl.message(
      'Total Days',
      name: 'totalDays',
      desc: '',
      args: [],
    );
  }

  /// `Used Days`
  String get usedDays {
    return Intl.message(
      'Used Days',
      name: 'usedDays',
      desc: '',
      args: [],
    );
  }

  /// `Available Days`
  String get availableDays {
    return Intl.message(
      'Available Days',
      name: 'availableDays',
      desc: '',
      args: [],
    );
  }

  /// `Pending Days`
  String get pendingDays {
    return Intl.message(
      'Pending Days',
      name: 'pendingDays',
      desc: '',
      args: [],
    );
  }

  /// `Insufficient balance. Available: {days} days`
  String insufficientBalance(Object days) {
    return Intl.message(
      'Insufficient balance. Available: $days days',
      name: 'insufficientBalance',
      desc: '',
      args: [days],
    );
  }

  /// `Vacation request submitted successfully`
  String get requestSubmitted {
    return Intl.message(
      'Vacation request submitted successfully',
      name: 'requestSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `Vacation request cancelled successfully`
  String get requestCancelled {
    return Intl.message(
      'Vacation request cancelled successfully',
      name: 'requestCancelled',
      desc: '',
      args: [],
    );
  }

  /// `Request approved successfully`
  String get requestApproved {
    return Intl.message(
      'Request approved successfully',
      name: 'requestApproved',
      desc: '',
      args: [],
    );
  }

  /// `Request rejected successfully`
  String get requestRejected {
    return Intl.message(
      'Request rejected successfully',
      name: 'requestRejected',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get pending {
    return Intl.message(
      'Pending',
      name: 'pending',
      desc: '',
      args: [],
    );
  }

  /// `Approved`
  String get approved {
    return Intl.message(
      'Approved',
      name: 'approved',
      desc: '',
      args: [],
    );
  }

  /// `Rejected`
  String get rejected {
    return Intl.message(
      'Rejected',
      name: 'rejected',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled`
  String get cancelled {
    return Intl.message(
      'Cancelled',
      name: 'cancelled',
      desc: '',
      args: [],
    );
  }

  /// `No pending requests`
  String get noPendingRequests {
    return Intl.message(
      'No pending requests',
      name: 'noPendingRequests',
      desc: '',
      args: [],
    );
  }

  /// `No vacation history`
  String get noVacationHistory {
    return Intl.message(
      'No vacation history',
      name: 'noVacationHistory',
      desc: '',
      args: [],
    );
  }

  /// `Approve Request`
  String get approveRequest {
    return Intl.message(
      'Approve Request',
      name: 'approveRequest',
      desc: '',
      args: [],
    );
  }

  /// `Reject Request`
  String get rejectRequest {
    return Intl.message(
      'Reject Request',
      name: 'rejectRequest',
      desc: '',
      args: [],
    );
  }

  /// `View Balance`
  String get viewBalance {
    return Intl.message(
      'View Balance',
      name: 'viewBalance',
      desc: '',
      args: [],
    );
  }

  /// `{name}'s Balance`
  String employeeBalance(Object name) {
    return Intl.message(
      '$name\'s Balance',
      name: 'employeeBalance',
      desc: '',
      args: [name],
    );
  }

  /// `No requests to display`
  String get noRequestsToDisplay {
    return Intl.message(
      'No requests to display',
      name: 'noRequestsToDisplay',
      desc: '',
      args: [],
    );
  }

  /// `All Types`
  String get allTypes {
    return Intl.message(
      'All Types',
      name: 'allTypes',
      desc: '',
      args: [],
    );
  }

  /// `Requested on {date}`
  String requestedOn(Object date) {
    return Intl.message(
      'Requested on $date',
      name: 'requestedOn',
      desc: '',
      args: [date],
    );
  }

  /// `Edit Vacation Request`
  String get editVacationRequest {
    return Intl.message(
      'Edit Vacation Request',
      name: 'editVacationRequest',
      desc: '',
      args: [],
    );
  }

  /// `Update Request`
  String get updateRequest {
    return Intl.message(
      'Update Request',
      name: 'updateRequest',
      desc: '',
      args: [],
    );
  }

  /// `Submit Request`
  String get submitRequest {
    return Intl.message(
      'Submit Request',
      name: 'submitRequest',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Cancel`
  String get confirmCancel {
    return Intl.message(
      'Confirm Cancel',
      name: 'confirmCancel',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to cancel this vacation request?`
  String get confirmCancelMessage {
    return Intl.message(
      'Are you sure you want to cancel this vacation request?',
      name: 'confirmCancelMessage',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Approve`
  String get confirmApprove {
    return Intl.message(
      'Confirm Approve',
      name: 'confirmApprove',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to approve {name}'s vacation request for {days} days?`
  String confirmApproveMessage(Object name, Object days) {
    return Intl.message(
      'Are you sure you want to approve $name\'s vacation request for $days days?',
      name: 'confirmApproveMessage',
      desc: '',
      args: [name, days],
    );
  }

  /// `Confirm Reject`
  String get confirmReject {
    return Intl.message(
      'Confirm Reject',
      name: 'confirmReject',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to reject {name}'s vacation request for {days} days?`
  String confirmRejectMessage(Object name, Object days) {
    return Intl.message(
      'Are you sure you want to reject $name\'s vacation request for $days days?',
      name: 'confirmRejectMessage',
      desc: '',
      args: [name, days],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'fr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
