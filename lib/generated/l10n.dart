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

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Flutter App`
  String get app_title {
    return Intl.message('Flutter App', name: 'app_title', desc: '', args: []);
  }

  /// `Lectures`
  String get lectures {
    return Intl.message('Lectures', name: 'lectures', desc: '', args: []);
  }

  /// `Lectures`
  String get lecturess {
    return Intl.message('Lectures', name: 'lecturess', desc: '', args: []);
  }

  /// `Wallet`
  String get wallet {
    return Intl.message('Wallet', name: 'wallet', desc: '', args: []);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Settings`
  String get profile {
    return Intl.message('Settings', name: 'profile', desc: '', args: []);
  }

  /// `Quizes`
  String get quizs {
    return Intl.message('Quizes', name: 'quizs', desc: '', args: []);
  }

  /// `Edit Profile`
  String get edit_profile {
    return Intl.message(
      'Edit Profile',
      name: 'edit_profile',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Dark Mode`
  String get dark_mode {
    return Intl.message('Dark Mode', name: 'dark_mode', desc: '', args: []);
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Follow Us on`
  String get follow_us_on {
    return Intl.message(
      'Follow Us on',
      name: 'follow_us_on',
      desc: '',
      args: [],
    );
  }

  /// `EGP`
  String get egp {
    return Intl.message('EGP', name: 'egp', desc: '', args: []);
  }

  /// `Min Degree`
  String get min_degree {
    return Intl.message('Min Degree', name: 'min_degree', desc: '', args: []);
  }

  /// `Contact support if you think there is an error.`
  String get contact_support {
    return Intl.message(
      'Contact support if you think there is an error.',
      name: 'contact_support',
      desc: '',
      args: [],
    );
  }

  /// `Account Blocked!`
  String get account_blocked {
    return Intl.message(
      'Account Blocked!',
      name: 'account_blocked',
      desc: '',
      args: [],
    );
  }

  /// `You must pass the exam to open rest of content; if you fail, you'll need to retake the quiz.`
  String get min_degree_warning {
    return Intl.message(
      'You must pass the exam to open rest of content; if you fail, you\'ll need to retake the quiz.',
      name: 'min_degree_warning',
      desc: '',
      args: [],
    );
  }

  /// `My Lectures`
  String get my_lec {
    return Intl.message('My Lectures', name: 'my_lec', desc: '', args: []);
  }

  /// `Attendance`
  String get attendance {
    return Intl.message('Attendance', name: 'attendance', desc: '', args: []);
  }

  /// `More Questions`
  String get more_questions {
    return Intl.message(
      'More Questions',
      name: 'more_questions',
      desc: '',
      args: [],
    );
  }

  /// `Chapters`
  String get chapters {
    return Intl.message('Chapters', name: 'chapters', desc: '', args: []);
  }

  /// `Are Available Now in your Wallet.`
  String get are_available_now {
    return Intl.message(
      'Are Available Now in your Wallet.',
      name: 'are_available_now',
      desc: '',
      args: [],
    );
  }

  /// `Enter Code`
  String get enter_code {
    return Intl.message('Enter Code', name: 'enter_code', desc: '', args: []);
  }

  /// `Recharge`
  String get recharge {
    return Intl.message('Recharge', name: 'recharge', desc: '', args: []);
  }

  /// `Lecture`
  String get lecture {
    return Intl.message('Lecture', name: 'lecture', desc: '', args: []);
  }

  /// `Hey,`
  String get hey {
    return Intl.message('Hey,', name: 'hey', desc: '', args: []);
  }

  /// `New Quiz`
  String get new_quiz {
    return Intl.message('New Quiz', name: 'new_quiz', desc: '', args: []);
  }

  /// `Ahmed Kabary`
  String get name_double {
    return Intl.message(
      'Ahmed Kabary',
      name: 'name_double',
      desc: '',
      args: [],
    );
  }

  /// `Ahmed Kabary Mostafa`
  String get name_triple {
    return Intl.message(
      'Ahmed Kabary Mostafa',
      name: 'name_triple',
      desc: '',
      args: [],
    );
  }

  /// `Grade`
  String get grade {
    return Intl.message('Grade', name: 'grade', desc: '', args: []);
  }

  /// `Scan Qr Code`
  String get scan_qr {
    return Intl.message('Scan Qr Code', name: 'scan_qr', desc: '', args: []);
  }

  /// `Edit Password`
  String get edit_pass {
    return Intl.message('Edit Password', name: 'edit_pass', desc: '', args: []);
  }

  /// `To Get your Payment`
  String get to_get_payment {
    return Intl.message(
      'To Get your Payment',
      name: 'to_get_payment',
      desc: '',
      args: [],
    );
  }

  /// `3-digits`
  String get three_digits {
    return Intl.message('3-digits', name: 'three_digits', desc: '', args: []);
  }

  /// `Title`
  String get title {
    return Intl.message('Title', name: 'title', desc: '', args: []);
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Password Cahnged Successfuly`
  String get pass_changes_success {
    return Intl.message(
      'Password Cahnged Successfuly',
      name: 'pass_changes_success',
      desc: '',
      args: [],
    );
  }

  /// `Code`
  String get code {
    return Intl.message('Code', name: 'code', desc: '', args: []);
  }

  /// `Do you want to Delete Account?`
  String get want_del_acc {
    return Intl.message(
      'Do you want to Delete Account?',
      name: 'want_del_acc',
      desc: '',
      args: [],
    );
  }

  /// `Delete Account`
  String get del_acc {
    return Intl.message('Delete Account', name: 'del_acc', desc: '', args: []);
  }

  /// `Don't Have an Account?`
  String get donot_have_acc {
    return Intl.message(
      'Don`t Have an Account?',
      name: 'donot_have_acc',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get register {
    return Intl.message('Register', name: 'register', desc: '', args: []);
  }

  /// `My Views`
  String get my_views {
    return Intl.message('My Views', name: 'my_views', desc: '', args: []);
  }

  /// `Views Available`
  String get views_avl {
    return Intl.message(
      'Views Available',
      name: 'views_avl',
      desc: '',
      args: [],
    );
  }

  /// `Show Answer`
  String get show_result {
    return Intl.message('Show Answer', name: 'show_result', desc: '', args: []);
  }

  /// `Enter Your Code`
  String get enter_your_code {
    return Intl.message(
      'Enter Your Code',
      name: 'enter_your_code',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Phone Number`
  String get enter_your_phone_num {
    return Intl.message(
      'Enter Your Phone Number',
      name: 'enter_your_phone_num',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Enter Your Password`
  String get enter_your_password {
    return Intl.message(
      'Enter Your Password',
      name: 'enter_your_password',
      desc: '',
      args: [],
    );
  }

  /// `Old Password`
  String get old_password {
    return Intl.message(
      'Old Password',
      name: 'old_password',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Old Password`
  String get enter_your_old_password {
    return Intl.message(
      'Enter Your Old Password',
      name: 'enter_your_old_password',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get new_password {
    return Intl.message(
      'New Password',
      name: 'new_password',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your New Password`
  String get enter_your_new_password {
    return Intl.message(
      'Enter Your New Password',
      name: 'enter_your_new_password',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message('Back', name: 'back', desc: '', args: []);
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `in Arabic`
  String get in_arabic {
    return Intl.message('in Arabic', name: 'in_arabic', desc: '', args: []);
  }

  /// `in English`
  String get in_english {
    return Intl.message('in English', name: 'in_english', desc: '', args: []);
  }

  /// `Phone Number`
  String get phone_num {
    return Intl.message('Phone Number', name: 'phone_num', desc: '', args: []);
  }

  /// `Already Have an Account?`
  String get already_have_acc {
    return Intl.message(
      'Already Have an Account?',
      name: 'already_have_acc',
      desc: '',
      args: [],
    );
  }

  /// `First Grade Secondary`
  String get first_grade_sec {
    return Intl.message(
      'First Grade Secondary',
      name: 'first_grade_sec',
      desc: '',
      args: [],
    );
  }

  /// `Second Grade Secondary`
  String get second_grade_sec {
    return Intl.message(
      'Second Grade Secondary',
      name: 'second_grade_sec',
      desc: '',
      args: [],
    );
  }

  /// `Third Grade Secondary`
  String get third_grade_sec {
    return Intl.message(
      'Third Grade Secondary',
      name: 'third_grade_sec',
      desc: '',
      args: [],
    );
  }

  /// `is Required`
  String get is_req {
    return Intl.message('is Required', name: 'is_req', desc: '', args: []);
  }

  /// `Enter Valid Code`
  String get enter_valid_code {
    return Intl.message(
      'Enter Valid Code',
      name: 'enter_valid_code',
      desc: '',
      args: [],
    );
  }

  /// `Content`
  String get content {
    return Intl.message('Content', name: 'content', desc: '', args: []);
  }

  /// `Duration`
  String get duration {
    return Intl.message('Duration', name: 'duration', desc: '', args: []);
  }

  /// `Get Now`
  String get buy_now {
    return Intl.message('Get Now', name: 'buy_now', desc: '', args: []);
  }

  /// `With`
  String get withh {
    return Intl.message('With', name: 'withh', desc: '', args: []);
  }

  /// `Free`
  String get free {
    return Intl.message('Free', name: 'free', desc: '', args: []);
  }

  /// `Choose Your Path`
  String get path_choosen {
    return Intl.message(
      'Choose Your Path',
      name: 'path_choosen',
      desc: '',
      args: [],
    );
  }

  /// `Select Your Grade`
  String get grade_selection {
    return Intl.message(
      'Select Your Grade',
      name: 'grade_selection',
      desc: '',
      args: [],
    );
  }

  /// `Please Select Your Grade!`
  String get select_grade {
    return Intl.message(
      'Please Select Your Grade!',
      name: 'select_grade',
      desc: '',
      args: [],
    );
  }

  /// `Guest`
  String get login_guest {
    return Intl.message('Guest', name: 'login_guest', desc: '', args: []);
  }

  /// `You are currently using a guest account. Please log in to access this feature.`
  String get must_login_access {
    return Intl.message(
      'You are currently using a guest account. Please log in to access this feature.',
      name: 'must_login_access',
      desc: '',
      args: [],
    );
  }

  /// `Login required`
  String get login_req {
    return Intl.message(
      'Login required',
      name: 'login_req',
      desc: '',
      args: [],
    );
  }

  /// `Loading`
  String get loading {
    return Intl.message('Loading', name: 'loading', desc: '', args: []);
  }

  /// `Your Data Updated Successfully!`
  String get user_data_updated_success {
    return Intl.message(
      'Your Data Updated Successfully!',
      name: 'user_data_updated_success',
      desc: '',
      args: [],
    );
  }

  /// `Should watch at least one time of previous video to open this video.`
  String get watch_vid_vid {
    return Intl.message(
      'Should watch at least one time of previous video to open this video.',
      name: 'watch_vid_vid',
      desc: '',
      args: [],
    );
  }

  /// `Should buy and watch at least one time of previous video to open this video.`
  String get buy_watch_vid_vid {
    return Intl.message(
      'Should buy and watch at least one time of previous video to open this video.',
      name: 'buy_watch_vid_vid',
      desc: '',
      args: [],
    );
  }

  /// `Should watch at least one time of previous video to open this quiz.`
  String get watch_vid_quiz {
    return Intl.message(
      'Should watch at least one time of previous video to open this quiz.',
      name: 'watch_vid_quiz',
      desc: '',
      args: [],
    );
  }

  /// `Should buy and watch at least one time of previous video to open this quiz.`
  String get buy_watch_vid_quiz {
    return Intl.message(
      'Should buy and watch at least one time of previous video to open this quiz.',
      name: 'buy_watch_vid_quiz',
      desc: '',
      args: [],
    );
  }

  /// `Should watch at least one time of previous video to open this PDF.`
  String get watch_vid_pdf {
    return Intl.message(
      'Should watch at least one time of previous video to open this PDF.',
      name: 'watch_vid_pdf',
      desc: '',
      args: [],
    );
  }

  /// `Should buy and watch at least one time of previous video to open this PDF.`
  String get buy_watch_vid_pdf {
    return Intl.message(
      'Should buy and watch at least one time of previous video to open this PDF.',
      name: 'buy_watch_vid_pdf',
      desc: '',
      args: [],
    );
  }

  /// `Should open previous PDF to open this video.`
  String get open_pdf_vid {
    return Intl.message(
      'Should open previous PDF to open this video.',
      name: 'open_pdf_vid',
      desc: '',
      args: [],
    );
  }

  /// `Should open previous PDF to open this quiz.`
  String get open_pdf_quiz {
    return Intl.message(
      'Should open previous PDF to open this quiz.',
      name: 'open_pdf_quiz',
      desc: '',
      args: [],
    );
  }

  /// `Should open previous PDF to open this PDF.`
  String get open_pdf_pdf {
    return Intl.message(
      'Should open previous PDF to open this PDF.',
      name: 'open_pdf_pdf',
      desc: '',
      args: [],
    );
  }

  /// `Should answer and get at least`
  String get ans_get_least {
    return Intl.message(
      'Should answer and get at least',
      name: 'ans_get_least',
      desc: '',
      args: [],
    );
  }

  /// `Should get at least`
  String get get_least {
    return Intl.message(
      'Should get at least',
      name: 'get_least',
      desc: '',
      args: [],
    );
  }

  /// `of previous quiz to open this video.`
  String get quiz_vid {
    return Intl.message(
      'of previous quiz to open this video.',
      name: 'quiz_vid',
      desc: '',
      args: [],
    );
  }

  /// `of previous quiz to open this quiz.`
  String get quiz_quiz {
    return Intl.message(
      'of previous quiz to open this quiz.',
      name: 'quiz_quiz',
      desc: '',
      args: [],
    );
  }

  /// `of previous quiz to open this PDF.`
  String get quiz_pdf {
    return Intl.message(
      'of previous quiz to open this PDF.',
      name: 'quiz_pdf',
      desc: '',
      args: [],
    );
  }

  /// `Recharged Successfully!`
  String get rech_succ {
    return Intl.message(
      'Recharged Successfully!',
      name: 'rech_succ',
      desc: '',
      args: [],
    );
  }

  /// `Buy This Lecture?`
  String get buy_lec {
    return Intl.message(
      'Buy This Lecture?',
      name: 'buy_lec',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Quiz`
  String get quiz {
    return Intl.message('Quiz', name: 'quiz', desc: '', args: []);
  }

  /// `Buy`
  String get buy {
    return Intl.message('Buy', name: 'buy', desc: '', args: []);
  }

  /// `Okay`
  String get okay {
    return Intl.message('Okay', name: 'okay', desc: '', args: []);
  }

  /// `Are You Sure You Want to Pay`
  String get sure_buy {
    return Intl.message(
      'Are You Sure You Want to Pay',
      name: 'sure_buy',
      desc: '',
      args: [],
    );
  }

  /// `?`
  String get question_mark {
    return Intl.message('?', name: 'question_mark', desc: '', args: []);
  }

  /// `Do you want to Logout?`
  String get want_logout {
    return Intl.message(
      'Do you want to Logout?',
      name: 'want_logout',
      desc: '',
      args: [],
    );
  }

  /// ` No Balance Available `
  String get no_balance_avl {
    return Intl.message(
      ' No Balance Available ',
      name: 'no_balance_avl',
      desc: '',
      args: [],
    );
  }

  /// `Purchased Successfully!`
  String get purchased_success {
    return Intl.message(
      'Purchased Successfully!',
      name: 'purchased_success',
      desc: '',
      args: [],
    );
  }

  /// `Mins`
  String get mins {
    return Intl.message('Mins', name: 'mins', desc: '', args: []);
  }

  /// `Purchased`
  String get purchased {
    return Intl.message('Purchased', name: 'purchased', desc: '', args: []);
  }

  /// `Not Purchased`
  String get not_purchased {
    return Intl.message(
      'Not Purchased',
      name: 'not_purchased',
      desc: '',
      args: [],
    );
  }

  /// `Student Code or Grade incorrect`
  String get err_std_code {
    return Intl.message(
      'Student Code or Grade incorrect',
      name: 'err_std_code',
      desc: '',
      args: [],
    );
  }

  /// `Enter Valid Phone Number`
  String get err_std_phone {
    return Intl.message(
      'Enter Valid Phone Number',
      name: 'err_std_phone',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Once You Enter the Video a View Will be Counted`
  String get sure_enter_video {
    return Intl.message(
      'Once You Enter the Video a View Will be Counted',
      name: 'sure_enter_video',
      desc: '',
      args: [],
    );
  }

  /// `You Will Have`
  String get you_will_have {
    return Intl.message(
      'You Will Have',
      name: 'you_will_have',
      desc: '',
      args: [],
    );
  }

  /// `Watches Left`
  String get watches_left {
    return Intl.message(
      'Watches Left',
      name: 'watches_left',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure to Exit?`
  String get sure_exit {
    return Intl.message(
      'Are You Sure to Exit?',
      name: 'sure_exit',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get exit {
    return Intl.message('Exit', name: 'exit', desc: '', args: []);
  }

  /// `No Internet Connection!`
  String get no_internet {
    return Intl.message(
      'No Internet Connection!',
      name: 'no_internet',
      desc: '',
      args: [],
    );
  }

  /// `My Code`
  String get my_code {
    return Intl.message('My Code', name: 'my_code', desc: '', args: []);
  }

  /// `Data Updated Successfully!`
  String get edit_success {
    return Intl.message(
      'Data Updated Successfully!',
      name: 'edit_success',
      desc: '',
      args: [],
    );
  }

  /// `Discard`
  String get discard {
    return Intl.message('Discard', name: 'discard', desc: '', args: []);
  }

  /// `Color`
  String get color {
    return Intl.message('Color', name: 'color', desc: '', args: []);
  }

  /// `Pick Color`
  String get pick_color {
    return Intl.message('Pick Color', name: 'pick_color', desc: '', args: []);
  }

  /// `Questions Number`
  String get questions_num {
    return Intl.message(
      'Questions Number',
      name: 'questions_num',
      desc: '',
      args: [],
    );
  }

  /// `Discard Changes?`
  String get discard_changes {
    return Intl.message(
      'Discard Changes?',
      name: 'discard_changes',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message('Update', name: 'update', desc: '', args: []);
  }

  /// `Questions Bank`
  String get questions_bank {
    return Intl.message(
      'Questions Bank',
      name: 'questions_bank',
      desc: '',
      args: [],
    );
  }

  /// `Choose Image Less than 1.5 MB`
  String get choose_less_img {
    return Intl.message(
      'Choose Image Less than 1.5 MB',
      name: 'choose_less_img',
      desc: '',
      args: [],
    );
  }

  /// `Please Pick an Image`
  String get no_img_selc {
    return Intl.message(
      'Please Pick an Image',
      name: 'no_img_selc',
      desc: '',
      args: [],
    );
  }

  /// `Quiz Code`
  String get quiz_code {
    return Intl.message('Quiz Code', name: 'quiz_code', desc: '', args: []);
  }

  /// `Enter Quiz Code`
  String get enter_quiz_code {
    return Intl.message(
      'Enter Quiz Code',
      name: 'enter_quiz_code',
      desc: '',
      args: [],
    );
  }

  /// `Enter`
  String get enter {
    return Intl.message('Enter', name: 'enter', desc: '', args: []);
  }

  /// `Quizes History`
  String get quizes_history {
    return Intl.message(
      'Quizes History',
      name: 'quizes_history',
      desc: '',
      args: [],
    );
  }

  /// `Date:`
  String get date {
    return Intl.message('Date:', name: 'date', desc: '', args: []);
  }

  /// `Questions:`
  String get questions {
    return Intl.message('Questions:', name: 'questions', desc: '', args: []);
  }

  /// `Your Result:`
  String get your_result {
    return Intl.message(
      'Your Result:',
      name: 'your_result',
      desc: '',
      args: [],
    );
  }

  /// `Finish`
  String get complete {
    return Intl.message('Finish', name: 'complete', desc: '', args: []);
  }

  /// `Next`
  String get next {
    return Intl.message('Next', name: 'next', desc: '', args: []);
  }

  /// `of`
  String get of_ {
    return Intl.message('of', name: 'of_', desc: '', args: []);
  }

  /// `Questions`
  String get questionss {
    return Intl.message('Questions', name: 'questionss', desc: '', args: []);
  }

  /// `Start Now`
  String get start {
    return Intl.message('Start Now', name: 'start', desc: '', args: []);
  }

  /// `Enter Your Message`
  String get enter_msg {
    return Intl.message(
      'Enter Your Message',
      name: 'enter_msg',
      desc: '',
      args: [],
    );
  }

  /// `you Missed some Questions!`
  String get sure_complete {
    return Intl.message(
      'you Missed some Questions!',
      name: 'sure_complete',
      desc: '',
      args: [],
    );
  }

  /// `You Complete all Questions`
  String get you_complete_success {
    return Intl.message(
      'You Complete all Questions',
      name: 'you_complete_success',
      desc: '',
      args: [],
    );
  }

  /// `No Quizes Yet`
  String get no_quizes_yet {
    return Intl.message(
      'No Quizes Yet',
      name: 'no_quizes_yet',
      desc: '',
      args: [],
    );
  }

  /// `Press + Button to add Quiz`
  String get press_to_add_quiz {
    return Intl.message(
      'Press + Button to add Quiz',
      name: 'press_to_add_quiz',
      desc: '',
      args: [],
    );
  }

  /// `Requests`
  String get requests {
    return Intl.message('Requests', name: 'requests', desc: '', args: []);
  }

  /// `Don’t Click Finish before you take your answers`
  String get donot_click_finish {
    return Intl.message(
      'Don’t Click Finish before you take your answers',
      name: 'donot_click_finish',
      desc: '',
      args: [],
    );
  }

  /// `Request`
  String get request {
    return Intl.message('Request', name: 'request', desc: '', args: []);
  }

  /// `New Request`
  String get new_req {
    return Intl.message('New Request', name: 'new_req', desc: '', args: []);
  }

  /// `Enter New Request`
  String get enter_new_req {
    return Intl.message(
      'Enter New Request',
      name: 'enter_new_req',
      desc: '',
      args: [],
    );
  }

  /// `Recent Lectures`
  String get recent_lectures {
    return Intl.message(
      'Recent Lectures',
      name: 'recent_lectures',
      desc: '',
      args: [],
    );
  }

  /// `Wallet Balance`
  String get wallet_balance {
    return Intl.message(
      'Wallet Balance',
      name: 'wallet_balance',
      desc: '',
      args: [],
    );
  }

  /// `Your Group`
  String get your_group {
    return Intl.message('Your Group', name: 'your_group', desc: '', args: []);
  }

  /// `you can't send messages in this chat`
  String get cannot_send_message {
    return Intl.message(
      'you can\'t send messages in this chat',
      name: 'cannot_send_message',
      desc: '',
      args: [],
    );
  }

  /// `Recent Requests`
  String get recent_requests {
    return Intl.message(
      'Recent Requests',
      name: 'recent_requests',
      desc: '',
      args: [],
    );
  }

  /// `No Attendance List Yet`
  String get no_attendance_yet {
    return Intl.message(
      'No Attendance List Yet',
      name: 'no_attendance_yet',
      desc: '',
      args: [],
    );
  }

  /// `No Chapters Yet`
  String get no_chapters_yet {
    return Intl.message(
      'No Chapters Yet',
      name: 'no_chapters_yet',
      desc: '',
      args: [],
    );
  }

  /// `No Lectures Yet`
  String get no_videos_yet {
    return Intl.message(
      'No Lectures Yet',
      name: 'no_videos_yet',
      desc: '',
      args: [],
    );
  }

  /// `No Content Yet`
  String get no_content_yet {
    return Intl.message(
      'No Content Yet',
      name: 'no_content_yet',
      desc: '',
      args: [],
    );
  }

  /// `No Requests Yet`
  String get no_requests_yet {
    return Intl.message(
      'No Requests Yet',
      name: 'no_requests_yet',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get change_pass {
    return Intl.message(
      'Change Password',
      name: 'change_pass',
      desc: '',
      args: [],
    );
  }

  /// `Posts`
  String get posts {
    return Intl.message('Posts', name: 'posts', desc: '', args: []);
  }

  /// `No Posts yet`
  String get no_posts_yet {
    return Intl.message(
      'No Posts yet',
      name: 'no_posts_yet',
      desc: '',
      args: [],
    );
  }

  /// `Comments`
  String get comments {
    return Intl.message('Comments', name: 'comments', desc: '', args: []);
  }

  /// `Like`
  String get like {
    return Intl.message('Like', name: 'like', desc: '', args: []);
  }

  /// `Likes`
  String get likes {
    return Intl.message('Likes', name: 'likes', desc: '', args: []);
  }

  /// `Write a comment`
  String get write_comment {
    return Intl.message(
      'Write a comment',
      name: 'write_comment',
      desc: '',
      args: [],
    );
  }

  /// `Read More`
  String get read_more {
    return Intl.message('Read More', name: 'read_more', desc: '', args: []);
  }

  /// `Read Less`
  String get read_less {
    return Intl.message('Read Less', name: 'read_less', desc: '', args: []);
  }

  /// `No Comments Yet`
  String get no_comments_yet {
    return Intl.message(
      'No Comments Yet',
      name: 'no_comments_yet',
      desc: '',
      args: [],
    );
  }

  /// `No Likes Yet`
  String get no_likes_yet {
    return Intl.message(
      'No Likes Yet',
      name: 'no_likes_yet',
      desc: '',
      args: [],
    );
  }

  /// `Continue Watching`
  String get continue_watching {
    return Intl.message(
      'Continue Watching',
      name: 'continue_watching',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get create_acc {
    return Intl.message(
      'Create Account',
      name: 'create_acc',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continue_watching_btn {
    return Intl.message(
      'Continue',
      name: 'continue_watching_btn',
      desc: '',
      args: [],
    );
  }

  /// `Purchased Videos`
  String get purchased_videos {
    return Intl.message(
      'Purchased Videos',
      name: 'purchased_videos',
      desc: '',
      args: [],
    );
  }

  /// `Online`
  String get online {
    return Intl.message('Online', name: 'online', desc: '', args: []);
  }

  /// `Center`
  String get center {
    return Intl.message('Center', name: 'center', desc: '', args: []);
  }

  /// `Guest`
  String get guest {
    return Intl.message('Guest', name: 'guest', desc: '', args: []);
  }

  /// `Check the code on whatsapp...`
  String get check_code_wts {
    return Intl.message(
      'Check the code on whatsapp...',
      name: 'check_code_wts',
      desc: '',
      args: [],
    );
  }

  /// `Verify the OTP sent to you on WhatsApp to\nconfirm your identity`
  String get verify_otp_wts {
    return Intl.message(
      'Verify the OTP sent to you on WhatsApp to\nconfirm your identity',
      name: 'verify_otp_wts',
      desc: '',
      args: [],
    );
  }

  /// `Didn't receive code?`
  String get didnot_recieve_code {
    return Intl.message(
      'Didn`t receive code?',
      name: 'didnot_recieve_code',
      desc: '',
      args: [],
    );
  }

  /// `Resend`
  String get resend {
    return Intl.message('Resend', name: 'resend', desc: '', args: []);
  }

  /// `Pin is Required`
  String get pin_req {
    return Intl.message('Pin is Required', name: 'pin_req', desc: '', args: []);
  }

  /// `Enter your full name`
  String get enter_your_name {
    return Intl.message(
      'Enter your full name',
      name: 'enter_your_name',
      desc: '',
      args: [],
    );
  }

  /// `Verify`
  String get verify {
    return Intl.message('Verify', name: 'verify', desc: '', args: []);
  }

  /// `Enter Your Parent Phone Number`
  String get enter_your_parent_phone_num {
    return Intl.message(
      'Enter Your Parent Phone Number',
      name: 'enter_your_parent_phone_num',
      desc: '',
      args: [],
    );
  }

  /// `Enter Valid Phone Number`
  String get enter_valid_phoneNum {
    return Intl.message(
      'Enter Valid Phone Number',
      name: 'enter_valid_phoneNum',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number Already Exists`
  String get phone_num_alreday_exist {
    return Intl.message(
      'Phone Number Already Exists',
      name: 'phone_num_alreday_exist',
      desc: '',
      args: [],
    );
  }

  /// `Phone number must start with 01`
  String get phone_num_must_start {
    return Intl.message(
      'Phone number must start with 01',
      name: 'phone_num_must_start',
      desc: '',
      args: [],
    );
  }

  /// `Choose your grade`
  String get choose_your_grade {
    return Intl.message(
      'Choose your grade',
      name: 'choose_your_grade',
      desc: '',
      args: [],
    );
  }

  /// `First secondary grade`
  String get first_grade {
    return Intl.message(
      'First secondary grade',
      name: 'first_grade',
      desc: '',
      args: [],
    );
  }

  /// `Second secondary grade`
  String get second_grade {
    return Intl.message(
      'Second secondary grade',
      name: 'second_grade',
      desc: '',
      args: [],
    );
  }

  /// `Third secondary grade`
  String get third_grade {
    return Intl.message(
      'Third secondary grade',
      name: 'third_grade',
      desc: '',
      args: [],
    );
  }

  /// `Upload your ID Here`
  String get upload_here {
    return Intl.message(
      'Upload your ID Here',
      name: 'upload_here',
      desc: '',
      args: [],
    );
  }

  /// `Front`
  String get front {
    return Intl.message('Front', name: 'front', desc: '', args: []);
  }

  /// `Enter Your ID`
  String get enter_your_id {
    return Intl.message(
      'Enter Your ID',
      name: 'enter_your_id',
      desc: '',
      args: [],
    );
  }

  /// `Choose From Gallery`
  String get choose_from_gallery {
    return Intl.message(
      'Choose From Gallery',
      name: 'choose_from_gallery',
      desc: '',
      args: [],
    );
  }

  /// `Take Photo`
  String get take_photo {
    return Intl.message('Take Photo', name: 'take_photo', desc: '', args: []);
  }

  /// `Back`
  String get backk {
    return Intl.message('Back', name: 'backk', desc: '', args: []);
  }

  /// `Enter your profile image`
  String get enter_your_profile_img {
    return Intl.message(
      'Enter your profile image',
      name: 'enter_your_profile_img',
      desc: '',
      args: [],
    );
  }

  /// `Optional`
  String get optional {
    return Intl.message('Optional', name: 'optional', desc: '', args: []);
  }

  /// `Available Groups`
  String get ava_groups {
    return Intl.message(
      'Available Groups',
      name: 'ava_groups',
      desc: '',
      args: [],
    );
  }

  /// `No Groups Available Yet`
  String get no_groups_yet {
    return Intl.message(
      'No Groups Available Yet',
      name: 'no_groups_yet',
      desc: '',
      args: [],
    );
  }

  /// `No Lectures Yet`
  String get no_lectures_yet {
    return Intl.message(
      'No Lectures Yet',
      name: 'no_lectures_yet',
      desc: '',
      args: [],
    );
  }

  /// `Whatsapp Message will be sent to verify your phone number.`
  String get whats_app_msg_will_send {
    return Intl.message(
      'Whatsapp Message will be sent to verify your phone number.',
      name: 'whats_app_msg_will_send',
      desc: '',
      args: [],
    );
  }

  /// `Account created successfully.\nWait until verifing your account`
  String get account_created {
    return Intl.message(
      'Account created successfully.\nWait until verifing your account',
      name: 'account_created',
      desc: '',
      args: [],
    );
  }

  /// `This code is used before`
  String get code_used {
    return Intl.message(
      'This code is used before',
      name: 'code_used',
      desc: '',
      args: [],
    );
  }

  /// `Go to Lecture`
  String get go_to_lecture {
    return Intl.message(
      'Go to Lecture',
      name: 'go_to_lecture',
      desc: '',
      args: [],
    );
  }

  /// `Use Wallet Value`
  String get use_wallet_value {
    return Intl.message(
      'Use Wallet Value',
      name: 'use_wallet_value',
      desc: '',
      args: [],
    );
  }

  /// `Enter Code`
  String get enter_lecture_code {
    return Intl.message(
      'Enter Code',
      name: 'enter_lecture_code',
      desc: '',
      args: [],
    );
  }

  /// `Payment Options`
  String get lecture_payment_options {
    return Intl.message(
      'Payment Options',
      name: 'lecture_payment_options',
      desc: '',
      args: [],
    );
  }

  /// `Online Payment`
  String get online_payment {
    return Intl.message(
      'Online Payment',
      name: 'online_payment',
      desc: '',
      args: [],
    );
  }

  /// `Pay by card or e-wallet`
  String get pay_online_desc {
    return Intl.message(
      'Pay by card or e-wallet',
      name: 'pay_online_desc',
      desc: '',
      args: [],
    );
  }

  /// `Safe & secure payment`
  String get secure_payment {
    return Intl.message(
      'Safe & secure payment',
      name: 'secure_payment',
      desc: '',
      args: [],
    );
  }

  /// `Proceed to Payment`
  String get proceed_to_payment {
    return Intl.message(
      'Proceed to Payment',
      name: 'proceed_to_payment',
      desc: '',
      args: [],
    );
  }

  /// `Choose Payment Method`
  String get choose_payment_method {
    return Intl.message(
      'Choose Payment Method',
      name: 'choose_payment_method',
      desc: '',
      args: [],
    );
  }

  /// `Could not complete the payment, please try again`
  String get payment_failed {
    return Intl.message(
      'Could not complete the payment, please try again',
      name: 'payment_failed',
      desc: '',
      args: [],
    );
  }

  /// `Your payment is pending, the lecture will be unlocked once it is confirmed`
  String get payment_pending {
    return Intl.message(
      'Your payment is pending, the lecture will be unlocked once it is confirmed',
      name: 'payment_pending',
      desc: '',
      args: [],
    );
  }

  /// `Awaiting Payment`
  String get payment_pending_title {
    return Intl.message(
      'Awaiting Payment',
      name: 'payment_pending_title',
      desc: '',
      args: [],
    );
  }

  /// `There is already an invoice for this lecture "pending" payment.\nComplete payment to open.`
  String get payment_pending_hint {
    return Intl.message(
      'There is already an invoice for this lecture "pending" payment.\nComplete payment to open.',
      name: 'payment_pending_hint',
      desc: '',
      args: [],
    );
  }

  /// `Retry Payment`
  String get complete_payment {
    return Intl.message(
      'Retry Payment',
      name: 'complete_payment',
      desc: '',
      args: [],
    );
  }

  /// `Purchases History`
  String get purchases_history {
    return Intl.message(
      'Purchases History',
      name: 'purchases_history',
      desc: '',
      args: [],
    );
  }

  /// `Your payment is pending, the balance will be added once it is confirmed`
  String get recharge_pending {
    return Intl.message(
      'Your payment is pending, the balance will be added once it is confirmed',
      name: 'recharge_pending',
      desc: '',
      args: [],
    );
  }

  /// `Choose Recharge Method`
  String get choose_recharge_method {
    return Intl.message(
      'Choose Recharge Method',
      name: 'choose_recharge_method',
      desc: '',
      args: [],
    );
  }

  /// `Recharge with Code`
  String get recharge_with_code {
    return Intl.message(
      'Recharge with Code',
      name: 'recharge_with_code',
      desc: '',
      args: [],
    );
  }

  /// `Enter a recharge code to add balance`
  String get recharge_with_code_desc {
    return Intl.message(
      'Enter a recharge code to add balance',
      name: 'recharge_with_code_desc',
      desc: '',
      args: [],
    );
  }

  /// `Online Payment`
  String get recharge_online {
    return Intl.message(
      'Online Payment',
      name: 'recharge_online',
      desc: '',
      args: [],
    );
  }

  /// `Top up with card, wallet or Fawry`
  String get recharge_online_desc {
    return Intl.message(
      'Top up with card, wallet or Fawry',
      name: 'recharge_online_desc',
      desc: '',
      args: [],
    );
  }

  /// `Choose Amount`
  String get choose_amount {
    return Intl.message(
      'Choose Amount',
      name: 'choose_amount',
      desc: '',
      args: [],
    );
  }

  /// `Enter Amount`
  String get enter_amount {
    return Intl.message(
      'Enter Amount',
      name: 'enter_amount',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid amount`
  String get invalid_amount {
    return Intl.message(
      'Enter a valid amount',
      name: 'invalid_amount',
      desc: '',
      args: [],
    );
  }

  /// `Wallet Recharge`
  String get wallet_recharge {
    return Intl.message(
      'Wallet Recharge',
      name: 'wallet_recharge',
      desc: '',
      args: [],
    );
  }

  /// `Recharge Your Wallet`
  String get recharge_wallet_section {
    return Intl.message(
      'Recharge Your Wallet',
      name: 'recharge_wallet_section',
      desc: '',
      args: [],
    );
  }

  /// `Add balance with a code or online payment.`
  String get recharge_wallet_hint {
    return Intl.message(
      'Add balance with a code or online payment.',
      name: 'recharge_wallet_hint',
      desc: '',
      args: [],
    );
  }

  /// `Need Help?`
  String get need_help_section {
    return Intl.message(
      'Need Help?',
      name: 'need_help_section',
      desc: '',
      args: [],
    );
  }

  /// `Contact us if you face problem.`
  String get need_help_hint {
    return Intl.message(
      'Contact us if you face problem.',
      name: 'need_help_hint',
      desc: '',
      args: [],
    );
  }

  /// `or`
  String get or_divider {
    return Intl.message('or', name: 'or_divider', desc: '', args: []);
  }

  /// `Scan a QR code to add balance instantly`
  String get scan_qr_to_recharge {
    return Intl.message(
      'Scan a QR code to add balance instantly',
      name: 'scan_qr_to_recharge',
      desc: '',
      args: [],
    );
  }

  /// `Or enter the code manually`
  String get enter_code_manually {
    return Intl.message(
      'Or enter the code manually',
      name: 'enter_code_manually',
      desc: '',
      args: [],
    );
  }

  /// `No payment methods available right now`
  String get no_payment_methods {
    return Intl.message(
      'No payment methods available right now',
      name: 'no_payment_methods',
      desc: '',
      args: [],
    );
  }

  /// `Pay via Fawry`
  String get fawry_payment {
    return Intl.message(
      'Pay via Fawry',
      name: 'fawry_payment',
      desc: '',
      args: [],
    );
  }

  /// `Payment Code`
  String get fawry_code {
    return Intl.message('Payment Code', name: 'fawry_code', desc: '', args: []);
  }

  /// `Go to any Fawry outlet and pay using the code below before it expires`
  String get fawry_instructions {
    return Intl.message(
      'Go to any Fawry outlet and pay using the code below before it expires',
      name: 'fawry_instructions',
      desc: '',
      args: [],
    );
  }

  /// `Expires at`
  String get expires_at {
    return Intl.message('Expires at', name: 'expires_at', desc: '', args: []);
  }

  /// `Reference Number`
  String get reference_number {
    return Intl.message(
      'Reference Number',
      name: 'reference_number',
      desc: '',
      args: [],
    );
  }

  /// `Code copied`
  String get code_copied {
    return Intl.message('Code copied', name: 'code_copied', desc: '', args: []);
  }

  /// `Copy Code`
  String get copy_code {
    return Intl.message('Copy Code', name: 'copy_code', desc: '', args: []);
  }

  /// `Recharge Wallet`
  String get add_to_wallet {
    return Intl.message(
      'Recharge Wallet',
      name: 'add_to_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Wallet Code`
  String get wallet_code {
    return Intl.message('Wallet Code', name: 'wallet_code', desc: '', args: []);
  }

  /// `Voice Note`
  String get voice_note {
    return Intl.message('Voice Note', name: 'voice_note', desc: '', args: []);
  }

  /// `The code you entered does not belong to this lecture`
  String get code_not_for_lec {
    return Intl.message(
      'The code you entered does not belong to this lecture',
      name: 'code_not_for_lec',
      desc: '',
      args: [],
    );
  }

  /// `The code you entered does not belong to this chapter`
  String get code_not_for_chap {
    return Intl.message(
      'The code you entered does not belong to this chapter',
      name: 'code_not_for_chap',
      desc: '',
      args: [],
    );
  }

  /// `The code you entered does not belong to this quiz`
  String get code_not_for_quiz {
    return Intl.message(
      'The code you entered does not belong to this quiz',
      name: 'code_not_for_quiz',
      desc: '',
      args: [],
    );
  }

  /// `Lecture Charged successfully`
  String get lecture_chargerd_success {
    return Intl.message(
      'Lecture Charged successfully',
      name: 'lecture_chargerd_success',
      desc: '',
      args: [],
    );
  }

  /// `Paid`
  String get paid {
    return Intl.message('Paid', name: 'paid', desc: '', args: []);
  }

  /// `Loan`
  String get loan {
    return Intl.message('Loan', name: 'loan', desc: '', args: []);
  }

  /// `Outstanding amount`
  String get loan_desc {
    return Intl.message(
      'Outstanding amount',
      name: 'loan_desc',
      desc: '',
      args: [],
    );
  }

  /// `Total Paid`
  String get total_paid {
    return Intl.message('Total Paid', name: 'total_paid', desc: '', args: []);
  }

  /// `Ask Us`
  String get ask_us {
    return Intl.message('Ask Us', name: 'ask_us', desc: '', args: []);
  }

  /// `Quiz Degree`
  String get quiz_degree {
    return Intl.message('Quiz Degree', name: 'quiz_degree', desc: '', args: []);
  }

  /// `Homework`
  String get homework {
    return Intl.message('Homework', name: 'homework', desc: '', args: []);
  }

  /// `Arrival Time`
  String get arrival_time {
    return Intl.message(
      'Arrival Time',
      name: 'arrival_time',
      desc: '',
      args: [],
    );
  }

  /// `No Exam`
  String get no_exam {
    return Intl.message('No Exam', name: 'no_exam', desc: '', args: []);
  }

  /// `No Homework`
  String get no_hw {
    return Intl.message('No Homework', name: 'no_hw', desc: '', args: []);
  }

  /// `Lecture Date`
  String get lecture_date {
    return Intl.message(
      'Lecture Date',
      name: 'lecture_date',
      desc: '',
      args: [],
    );
  }

  /// `Lecture not added yet`
  String get lecture_not_exist {
    return Intl.message(
      'Lecture not added yet',
      name: 'lecture_not_exist',
      desc: '',
      args: [],
    );
  }

  /// `You used this code before!`
  String get u_charge_code {
    return Intl.message(
      'You used this code before!',
      name: 'u_charge_code',
      desc: '',
      args: [],
    );
  }

  /// `Lecture Exam`
  String get lecture_exam {
    return Intl.message(
      'Lecture Exam',
      name: 'lecture_exam',
      desc: '',
      args: [],
    );
  }

  /// `Wait to enable answer model`
  String get wait_to_get_degree {
    return Intl.message(
      'Wait to enable answer model',
      name: 'wait_to_get_degree',
      desc: '',
      args: [],
    );
  }

  /// `Select Exam Type`
  String get select_exam_type {
    return Intl.message(
      'Select Exam Type',
      name: 'select_exam_type',
      desc: '',
      args: [],
    );
  }

  /// `All Exams`
  String get all_exams {
    return Intl.message('All Exams', name: 'all_exams', desc: '', args: []);
  }

  /// `Normal Exams`
  String get normal_exams {
    return Intl.message(
      'Normal Exams',
      name: 'normal_exams',
      desc: '',
      args: [],
    );
  }

  /// `Lesson Exams`
  String get lesson_exams {
    return Intl.message(
      'Lesson Exams',
      name: 'lesson_exams',
      desc: '',
      args: [],
    );
  }

  /// `You should get the minimum degree`
  String get should_get_min_degree {
    return Intl.message(
      'You should get the minimum degree',
      name: 'should_get_min_degree',
      desc: '',
      args: [],
    );
  }

  /// `Full Mark:`
  String get fullMark {
    return Intl.message('Full Mark:', name: 'fullMark', desc: '', args: []);
  }

  /// `Full Mark`
  String get fullMarkk {
    return Intl.message('Full Mark', name: 'fullMarkk', desc: '', args: []);
  }

  /// `Questions`
  String get question {
    return Intl.message('Questions', name: 'question', desc: '', args: []);
  }

  /// `Degree`
  String get degree {
    return Intl.message('Degree', name: 'degree', desc: '', args: []);
  }

  /// `Degrees`
  String get degrees {
    return Intl.message('Degrees', name: 'degrees', desc: '', args: []);
  }

  /// `Missed`
  String get missed {
    return Intl.message('Missed', name: 'missed', desc: '', args: []);
  }

  /// `Right`
  String get right {
    return Intl.message('Right', name: 'right', desc: '', args: []);
  }

  /// `Wrong`
  String get wrong {
    return Intl.message('Wrong', name: 'wrong', desc: '', args: []);
  }

  /// `Written`
  String get written {
    return Intl.message('Written', name: 'written', desc: '', args: []);
  }

  /// `Clear filter`
  String get clear_filter {
    return Intl.message(
      'Clear filter',
      name: 'clear_filter',
      desc: '',
      args: [],
    );
  }

  /// `Write your answer here (Optional)`
  String get write_your_answer {
    return Intl.message(
      'Write your answer here (Optional)',
      name: 'write_your_answer',
      desc: '',
      args: [],
    );
  }

  /// `Upload answer image here`
  String get upload_answ_img_here {
    return Intl.message(
      'Upload answer image here',
      name: 'upload_answ_img_here',
      desc: '',
      args: [],
    );
  }

  /// `Delete Image`
  String get delete_img {
    return Intl.message('Delete Image', name: 'delete_img', desc: '', args: []);
  }

  /// `Your Answer:`
  String get your_answer {
    return Intl.message(
      'Your Answer:',
      name: 'your_answer',
      desc: '',
      args: [],
    );
  }

  /// `Choose Image Source`
  String get choose_img_source {
    return Intl.message(
      'Choose Image Source',
      name: 'choose_img_source',
      desc: '',
      args: [],
    );
  }

  /// `Upload image from gallery or take a photo?`
  String get choose_source_msg {
    return Intl.message(
      'Upload image from gallery or take a photo?',
      name: 'choose_source_msg',
      desc: '',
      args: [],
    );
  }

  /// `Failed to open video`
  String get err_open_vid {
    return Intl.message(
      'Failed to open video',
      name: 'err_open_vid',
      desc: '',
      args: [],
    );
  }

  /// `Opening the video on your mobile device`
  String get try_mobile_to_open {
    return Intl.message(
      'Opening the video on your mobile device',
      name: 'try_mobile_to_open',
      desc: '',
      args: [],
    );
  }

  /// `Zoom`
  String get tap_to_zoom {
    return Intl.message('Zoom', name: 'tap_to_zoom', desc: '', args: []);
  }

  /// `Quick Actions`
  String get quick_actions {
    return Intl.message(
      'Quick Actions',
      name: 'quick_actions',
      desc: '',
      args: [],
    );
  }

  /// `Revisions`
  String get revisions {
    return Intl.message('Revisions', name: 'revisions', desc: '', args: []);
  }

  /// `Lectures Exams`
  String get lecture_exams {
    return Intl.message(
      'Lectures Exams',
      name: 'lecture_exams',
      desc: '',
      args: [],
    );
  }

  /// `Available Exams`
  String get available_exams {
    return Intl.message(
      'Available Exams',
      name: 'available_exams',
      desc: '',
      args: [],
    );
  }

  /// `Valid until`
  String get valid_until {
    return Intl.message('Valid until', name: 'valid_until', desc: '', args: []);
  }

  /// `Left:`
  String get time_left {
    return Intl.message('Left:', name: 'time_left', desc: '', args: []);
  }

  /// `Ended`
  String get exam_ended {
    return Intl.message('Ended', name: 'exam_ended', desc: '', args: []);
  }

  /// `Exam Time Ended`
  String get exam_expired {
    return Intl.message(
      'Exam Time Ended',
      name: 'exam_expired',
      desc: '',
      args: [],
    );
  }

  /// `d`
  String get unit_days {
    return Intl.message('d', name: 'unit_days', desc: '', args: []);
  }

  /// `h`
  String get unit_hours {
    return Intl.message('h', name: 'unit_hours', desc: '', args: []);
  }

  /// `m`
  String get unit_minutes {
    return Intl.message('m', name: 'unit_minutes', desc: '', args: []);
  }

  /// `s`
  String get unit_seconds {
    return Intl.message('s', name: 'unit_seconds', desc: '', args: []);
  }

  /// `Answered Exams`
  String get answered_exams {
    return Intl.message(
      'Answered Exams',
      name: 'answered_exams',
      desc: '',
      args: [],
    );
  }

  /// `Contact US`
  String get contact_us_cash {
    return Intl.message(
      'Contact US',
      name: 'contact_us_cash',
      desc: '',
      args: [],
    );
  }

  /// `To purchase a code or recharge your wallet, contact us at`
  String get contact_us_get_cash {
    return Intl.message(
      'To purchase a code or recharge your wallet, contact us at',
      name: 'contact_us_get_cash',
      desc: '',
      args: [],
    );
  }

  /// `Techical Support`
  String get support {
    return Intl.message(
      'Techical Support',
      name: 'support',
      desc: '',
      args: [],
    );
  }

  /// `Quizzes`
  String get shamel_quizs {
    return Intl.message('Quizzes', name: 'shamel_quizs', desc: '', args: []);
  }

  /// `External\nBooks`
  String get external_books {
    return Intl.message(
      'External\nBooks',
      name: 'external_books',
      desc: '',
      args: [],
    );
  }

  /// `Buy with code`
  String get buy_with_code {
    return Intl.message(
      'Buy with code',
      name: 'buy_with_code',
      desc: '',
      args: [],
    );
  }

  /// `Lecture Code`
  String get lecture_code {
    return Intl.message(
      'Lecture Code',
      name: 'lecture_code',
      desc: '',
      args: [],
    );
  }

  /// `My Invoices`
  String get my_invoices {
    return Intl.message('My Invoices', name: 'my_invoices', desc: '', args: []);
  }

  /// `No invoices yet`
  String get no_invoices_yet {
    return Intl.message(
      'No invoices yet',
      name: 'no_invoices_yet',
      desc: '',
      args: [],
    );
  }

  /// `All your purchases will appear here`
  String get invoices_appear_here {
    return Intl.message(
      'All your purchases will appear here',
      name: 'invoices_appear_here',
      desc: '',
      args: [],
    );
  }

  /// `Invoice`
  String get invoice {
    return Intl.message('Invoice', name: 'invoice', desc: '', args: []);
  }

  /// `Amount`
  String get amount {
    return Intl.message('Amount', name: 'amount', desc: '', args: []);
  }

  /// `Payment Method`
  String get payment_method {
    return Intl.message(
      'Payment Method',
      name: 'payment_method',
      desc: '',
      args: [],
    );
  }

  /// `Payment Date`
  String get payment_date {
    return Intl.message(
      'Payment Date',
      name: 'payment_date',
      desc: '',
      args: [],
    );
  }

  /// `Failure Date`
  String get failure_date {
    return Intl.message(
      'Failure Date',
      name: 'failure_date',
      desc: '',
      args: [],
    );
  }

  /// `Failure Reason`
  String get failure_reason {
    return Intl.message(
      'Failure Reason',
      name: 'failure_reason',
      desc: '',
      args: [],
    );
  }

  /// `Copied`
  String get copied {
    return Intl.message('Copied', name: 'copied', desc: '', args: []);
  }

  /// `Paid`
  String get status_paid {
    return Intl.message('Paid', name: 'status_paid', desc: '', args: []);
  }

  /// `Pending`
  String get status_pending {
    return Intl.message('Pending', name: 'status_pending', desc: '', args: []);
  }

  /// `Failed`
  String get status_failed {
    return Intl.message('Failed', name: 'status_failed', desc: '', args: []);
  }

  /// `Unknown`
  String get status_unknown {
    return Intl.message('Unknown', name: 'status_unknown', desc: '', args: []);
  }

  /// `Buy Exam`
  String get buy_exam {
    return Intl.message('Buy Exam', name: 'buy_exam', desc: '', args: []);
  }

  /// `Pending`
  String get pending {
    return Intl.message('Pending', name: 'pending', desc: '', args: []);
  }

  /// `Welcome Back`
  String get welcome_back {
    return Intl.message(
      'Welcome Back',
      name: 'welcome_back',
      desc: '',
      args: [],
    );
  }

  /// `الفئة الأولى`
  String get login_subtitle {
    return Intl.message(
      'الفئة الأولى',
      name: 'login_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `New Month`
  String get new_month {
    return Intl.message('New Month', name: 'new_month', desc: '', args: []);
  }

  /// `Pull to Refresh`
  String get pull_refresh {
    return Intl.message(
      'Pull to Refresh',
      name: 'pull_refresh',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
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
