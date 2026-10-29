// // ignore_for_file: must_be_immutable

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:salah_online_platform/widgets/app_status_dialog.dart';
//
// import 'package:salah_online_platform/bloc/platform_cubit.dart';
// import 'package:salah_online_platform/bloc/platformStates.dart';
// import 'package:salah_online_platform/constants/components.dart';
// import 'package:salah_online_platform/constants/styles.dart';
// import 'package:salah_online_platform/constants/widgets.dart';
// import 'package:salah_online_platform/models/boarding_model.dart';
// import 'package:salah_online_platform/network/local/shared_pref_helper.dart';
// import 'package:salah_online_platform/screens/auth/login/login_page.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// import '../../constants/constants.dart';

// class OnBoardingScreen extends StatefulWidget {
//   const OnBoardingScreen({super.key});

//   @override
//   State<OnBoardingScreen> createState() => _OnBoardingScreenState();
// }

// class _OnBoardingScreenState extends State<OnBoardingScreen>
//     with SingleTickerProviderStateMixin {
//   var pageController = PageController();
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   bool isLast = false;
//   int curIdx = 0;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
//     );
//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return BlocBuilder<PlatformCubit, PlatformStates>(
//       builder: (context, state) {
//         var cubit = PlatformCubit.get(context);
//         final primaryColor = Components.setBgColor(cubit.isDarkMode);

//         return Scaffold(
//           body: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   primaryColor.withValues(alpha: 0.1),
//                   Colors.white,
//                 ],
//               ),
//             ),
//             child: SafeArea(
//               child: Column(
//                 children: [
//                   // Skip Button
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20.0,
//                       vertical: 12.0,
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         TextButton(
//                           onPressed: submit,
//                           style: TextButton.styleFrom(
//                             foregroundColor: primaryColor,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 8,
//                             ),
//                           ),
//                           child: Text(
//                             'تخطي',
//                             style: TextStyle(
//                               fontFamily: 'Cairo',
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: primaryColor,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Hero Image Section
//                   FadeTransition(
//                     opacity: _fadeAnimation,
//                     child: Container(
//                       height: size.height * 0.35,
//                       margin: const EdgeInsets.symmetric(horizontal: 24),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(24),
//                         boxShadow: [
//                           BoxShadow(
//                             color: primaryColor.withValues(alpha: 0.3),
//                             blurRadius: 30,
//                             offset: const Offset(0, 15),
//                             spreadRadius: 0,
//                           ),
//                         ],
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(24),
//                         child: CachedNetworkImage(
//                           imageUrl: Constants.koraiemPhoto,
//                           fit: BoxFit.cover,
//                           width: double.infinity,
//                           placeholder: (context, url) => Container(
//                             color: primaryColor.withValues(alpha: 0.1),
//                             child: Center(
//                               child: CircularProgressIndicator(
//                                 color: primaryColor,
//                                 strokeWidth: 2,
//                               ),
//                             ),
//                           ),
//                           errorWidget: (context, url, error) => Container(
//                             color: primaryColor.withValues(alpha: 0.1),
//                             child: Icon(
//                               Icons.person,
//                               size: 80,
//                               color: primaryColor.withValues(alpha: 0.5),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   // Content Card
//                   Expanded(
//                     child: SlideTransition(
//                       position: _slideAnimation,
//                       child: FadeTransition(
//                         opacity: _fadeAnimation,
//                         child: Container(
//                           margin: const EdgeInsets.symmetric(horizontal: 20),
//                           decoration: BoxDecoration(
//                             color: primaryColor,
//                             borderRadius: const BorderRadius.only(
//                               topLeft: Radius.circular(32),
//                               topRight: Radius.circular(32),
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: primaryColor.withValues(alpha: 0.4),
//                                 blurRadius: 20,
//                                 offset: const Offset(0, -5),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             children: [
//                               // Drag Indicator
//                               Container(
//                                 margin: const EdgeInsets.only(top: 12),
//                                 width: 40,
//                                 height: 4,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withValues(alpha: 0.3),
//                                   borderRadius: BorderRadius.circular(2),
//                                 ),
//                               ),

//                               // PageView Content
//                               Expanded(
//                                 child: PageView.builder(
//                                   onPageChanged: (value) {
//                                     setState(() {
//                                       curIdx = value;
//                                       isLast = value ==
//                                           Components.boardings.length - 1;
//                                     });
//                                   },
//                                   controller: pageController,
//                                   itemBuilder: (context, index) =>
//                                       BuildBoardingItem(
//                                     boardingModel: Components.boardings[index],
//                                     isDarkMode: cubit.isDarkMode,
//                                     isActive: curIdx == index,
//                                   ),
//                                   itemCount: Components.boardings.length,
//                                 ),
//                               ),

//                               // Bottom Navigation
//                               Padding(
//                                 padding:
//                                     const EdgeInsets.fromLTRB(24, 0, 24, 24),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     // Page Indicator
//                                     SmoothPageIndicator(
//                                       controller: pageController,
//                                       count: Components.boardings.length,
//                                       effect: WormEffect(
//                                         activeDotColor: Colors.white,
//                                         dotColor:
//                                             Colors.white.withValues(alpha: 0.3),
//                                         dotHeight: 10,
//                                         dotWidth: 10,
//                                         spacing: 8,
//                                       ),
//                                     ),

//                                     // Action Button
//                                     AnimatedSwitcher(
//                                       duration:
//                                           const Duration(milliseconds: 300),
//                                       transitionBuilder: (child, animation) {
//                                         return ScaleTransition(
//                                           scale: animation,
//                                           child: child,
//                                         );
//                                       },
//                                       child: isLast
//                                           ? _buildGetStartedButton()
//                                           : _buildNextButton(),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildNextButton() {
//     return Container(
//       key: const ValueKey('next'),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(30),
//           onTap: () {
//             pageController.nextPage(
//               duration: const Duration(milliseconds: 400),
//               curve: Curves.easeInOut,
//             );
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Icon(
//               Icons.arrow_forward_rounded,
//               color: Components.setBgColor(
//                 PlatformCubit.get(context).isDarkMode,
//               ),
//               size: 28,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGetStartedButton() {
//     return Container(
//       key: const ValueKey('start'),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(30),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(30),
//           onTap: submit,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'ابدأ الآن',
//                   style: TextStyle(
//                     fontFamily: 'Cairo',
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Components.setBgColor(
//                       PlatformCubit.get(context).isDarkMode,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Icon(
//                   Icons.arrow_forward_rounded,
//                   color: Components.setBgColor(
//                     PlatformCubit.get(context).isDarkMode,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void submit() {
//     SharedPrefHelper.saveData(
//       key: 'isOnBoardingDone',
//       value: true,
//     ).then((value) {
//       if (value) {
//         Components.pushReplacement(
//           context: context,
//           widget: LoginPage(),
//         );
//       }
//     }).catchError((onError) {
//       AppStatusDialog.show(
//         context: context,
//         status: AppDialogStatus.error,
//         title: 'خطأ',
//         message: onError.toString(),
//       );
//     });
//   }
// }

// class BuildBoardingItem extends StatelessWidget {
//   const BuildBoardingItem({
//     super.key,
//     required this.boardingModel,
//     required this.isDarkMode,
//     this.isActive = false,
//   });

//   final BoardingModel boardingModel;
//   final bool isDarkMode;
//   final bool isActive;

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedOpacity(
//       duration: const Duration(milliseconds: 300),
//       opacity: isActive ? 1.0 : 0.5,
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Title
//             AnimatedDefaultTextStyle(
//               duration: const Duration(milliseconds: 300),
//               style: AppTextStyles.headStyle.copyWith(
//                 height: 1.2,
//                 fontSize: isActive ? 32 : 28,
//                 fontFamily: 'Cairo',
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//               child: Text(
//                 boardingModel.title,
//                 textAlign: TextAlign.center,
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Image (if exists)
//             if (boardingModel.image != null && boardingModel.image!.isNotEmpty)
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(16),
//                     child: DefaultImage(
//                       imgUrl: boardingModel.image!,
//                     ),
//                   ),
//                 ),
//               ),

//             if (boardingModel.image == null || boardingModel.image!.isEmpty)
//               const SizedBox(height: 24),

//             // Body Text
//             Text(
//               boardingModel.body,
//               textAlign: TextAlign.center,
//               style: AppTextStyles.body1Style.copyWith(
//                 fontFamily: 'Cairo',
//                 color: Colors.white.withValues(alpha: 0.9),
//                 height: 1.6,
//                 fontSize: 16,
//               ),
//             ),

//             if (boardingModel.image == null || boardingModel.image!.isEmpty)
//               const Spacer(),
//           ],
//         ),
//       ),
//     );
//   }
// }
