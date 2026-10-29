// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc/platformCubit.dart';
import '../../bloc/platformStates.dart';
import '../../constants/constants.dart';
import '../../generated/l10n.dart';
import '../../models/user_model.dart';

class PdfScreen extends StatefulWidget {
  PdfScreen({
    super.key,
    required this.pdfUrl,
    required this.chapId,
    required this.lecId,
    required this.pdfId,
  });
  String pdfUrl;
  String chapId;
  String lecId;
  String pdfId;
  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  late PdfViewerController _pdfViewerController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Constants.noScreenshot.screenshotOff();
    });
    _pdfViewerController = PdfViewerController();
  }

  @override
  void dispose() async {
    super.dispose();
    await Constants.noScreenshot.screenshotOn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<PlatformCubit, PlatformStates>(
            builder: (context, state) {
          var cubit = PlatformCubit.get(context);
          return Stack(
            alignment: AlignmentDirectional.topStart,
            children: [
              Platform.isWindows
                  ? SfPdfViewer.network(
                      widget.pdfUrl,
                      controller: _pdfViewerController,
                      enableTextSelection: true,
                      enableHyperlinkNavigation: true,
                      onDocumentLoaded: (details) {
                        UserModel um = Constants.userBox.get('user');

                        int pdfIndex = um.purchasedPdfs?[widget.chapId]
                                    ?[widget.lecId]
                                ?.indexWhere(
                              (element) => element == widget.pdfId,
                            ) ??
                            -1;

                        if (pdfIndex == -1) {
                          debugPrint('Ahmedddd');

                          // add to database and firebase
                          cubit.addPdf(
                            chapId: widget.chapId,
                            lecId: widget.lecId,
                            pdfId: widget.pdfId,
                          );
                        }
                      },
                      onHyperlinkClicked: (details) async {
                        if (await canLaunchUrl(Uri.parse(details.uri))) {
                          await launchUrl(Uri.parse(details.uri));
                        }
                      },
                      onDocumentLoadFailed: (details) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Error loading PDF: ${details.error}')),
                        );
                      },
                    )
                  : PDF(
                      swipeHorizontal: true,
                      onViewCreated: (controller) {
                        UserModel um = Constants.userBox.get('user');

                        int pdfIndex = um.purchasedPdfs?[widget.chapId]
                                    ?[widget.lecId]
                                ?.indexWhere(
                              (element) => element == widget.pdfId,
                            ) ??
                            -1;

                        if (pdfIndex == -1) {
                          debugPrint('Ahmedddd');

                          // add to data base and firebase.

                          cubit.addPdf(
                            chapId: widget.chapId,
                            lecId: widget.lecId,
                            pdfId: widget.pdfId,
                          );
                        }
                      },
                      onLinkHandler: (uri) {
                        launchUrl(Uri.parse(uri!));
                      },
                    ).cachedFromUrl(
                      widget.pdfUrl,
                      placeholder: (progress) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('$progress %'),
                            const CircularProgressIndicator(),
                          ],
                        ),
                      ),
                      errorWidget: (error) => Center(
                        child: Text(error.toString()),
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                        Text(
                          S.of(context).back,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
