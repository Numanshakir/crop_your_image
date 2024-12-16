import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kotc/base/colors.dart';
import 'package:kotc/generated/assets.dart';
import 'package:kotc/pages/ask_ai_tutor/ask_ai_chat/presentation/providers/ask_ai_provider.dart';
import 'package:kotc/pages/ask_ai_tutor/ask_ai_chat/presentation/providers/ask_ai_state.dart';
import 'package:kotc/pages/ask_ai_tutor/ocr_photo_croper/presentation/pages/ai_take_photo.dart';
import 'package:kotc/widgets/app_button_widget.dart';
import 'package:kotc/widgets/montserrat.dart';

class AiCropPhoto extends ConsumerStatefulWidget {
  final AiTutorPhotoType photoType;

  AiCropPhoto({super.key, required this.imagePath, required this.photoType});

  final Uint8List imagePath;

  @override
  ConsumerState createState() => _AiCropPhotoState();
}

class _AiCropPhotoState extends ConsumerState<AiCropPhoto>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final CropController _cropController = CropController();

  bool isCropping = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Uint8List? croppedData;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    double height = size.height - kBottomNavigationBarHeight;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: MontserratText(
          "Crop Photo",
          size: 24,
          weight: 700,
          color: AppColors.whiteF2,
        ),
        leading: IconButton(
          icon: SvgPicture.asset(
            Assets.backArrowSvgUrl,
            height: 19,
            width: 9,
          ),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Crop(
            image: widget.imagePath,
            controller: _cropController,
            onCropped: (CropResult value) {
              print("value ${value}");
              // if (value.runtimeType == CropSuccess) {
              //   onCropped((value as CropSuccess).croppedImage);
              // }
            },
            cropAreaLoadingIndicator: Center(
              child: CupertinoActivityIndicator(
                radius: 15.0,
                color: AppColors.pinkButton,
              ),
            ),
            progressIndicator: Center(
              child: CupertinoActivityIndicator(
                radius: 15.0,
                color: AppColors.pinkButton,
              ),
            ),
            radius: 4,
            initialRectBuilder: InitialRectBuilder.withArea(Rect.fromCenter(
                center: Offset(size.width / 2, height / 2),
                width: 243,
                height: 190)),
            cornerDotBuilder: (size, edgeAlignment) {
              if (edgeAlignment == EdgeAlignment.topLeft) {
                return _buildCorner(
                    borderRadius:
                        BorderRadius.only(topLeft: Radius.circular(5)),
                    border: Border(
                      top: BorderSide(
                        color: AppColors.pinkButton,
                        width: 4,
                      ),
                      left: BorderSide(
                        color: AppColors.pinkButton,
                        width: 4,
                      ),
                    ),
                    margin: EdgeInsets.only(top: 14, left: 14));
              } else if (edgeAlignment == EdgeAlignment.topRight) {
                return _buildCorner(
                    borderRadius:
                        BorderRadius.only(topRight: Radius.circular(5)),
                    border: Border(
                      top: BorderSide(
                        color: AppColors.pinkButton,
                        width: 4,
                      ),
                      right: BorderSide(
                        color: AppColors.pinkButton,
                        width: 4,
                      ),
                    ),
                    margin: EdgeInsets.only(top: 14, left: 3));
              } else if (edgeAlignment == EdgeAlignment.bottomLeft) {
                return _buildCorner(
                  borderRadius:
                      BorderRadius.only(bottomLeft: Radius.circular(5)),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.pinkButton,
                      width: 4,
                    ),
                    left: BorderSide(
                      color: AppColors.pinkButton,
                      width: 4,
                    ),
                  ),
                  margin: EdgeInsets.only(top: 3, left: 14),
                );
              } else if (edgeAlignment == EdgeAlignment.bottomRight) {
                return _buildCorner(
                    borderRadius:
                        BorderRadius.only(bottomRight: Radius.circular(5)),
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.pinkButton,
                        width: 4,
                      ),
                      right: BorderSide(
                        color: AppColors.pinkButton,
                        width: 4,
                      ),
                    ),
                    margin: EdgeInsets.only(
                      left: 3,
                      top: 3,
                    ));
              } else {
                return DotControl();
              }
            },
            maskColor: Color(0xff000000).withOpacity(0.77),
            // interactiveAreaColor: Colors.red,
            interactiveAreaColor: Color(0xffB9B9B9).withOpacity(0.5),
          ),
          Positioned(
            bottom: isCropping ? 37 : 57,
            left: 0,
            right: 0,
            child: isCropping
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RotationTransition(
                        turns: _animationController,
                        child: Image.asset(
                          Assets.aiCropLogo,
                          height: 66,
                          width: 66,
                        ),
                      ),
                      MontserratText(
                        AiTutorPhotoType.flashcards.name ==
                                GoRouter.of(context)
                                    .state
                                    ?.uri
                                    .queryParameters["chat-type"]
                            ? "Generating Flashcards"
                            : "Recognizing",
                        color: Colors.white,
                      )
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppButtonWidget.elevated(
                            buttonSize: 50,
                            titleSize: 17,
                            title: 'Cancel',
                            borderRadius: 10,
                            backgroundColor: Color(0xff979696),
                            onPressed: () {
                              context.pop();
                            },
                          ),
                        ),
                        SizedBox(width: 11),
                        Expanded(
                          child: AppButtonWidget.elevated(
                            buttonSize: 50,
                            titleSize: 17,
                            title: 'Continue',
                            borderRadius: 10,
                            onPressed: () async {
                              isCropping = true;
                              setState(() {});
                              _cropController.crop();
                              //
                              // isCropping = false;
                              // setState(() {});
                              //
                              // if (!mounted) return;
                            },
                          ),
                        )
                      ],
                    ),
                  ),
          ),
          // isCropping
          //     ? Center(
          //   child: CupertinoActivityIndicator(
          //     radius: 15.0,
          //     color: AppColors.pinkButton,
          //   ),
          // )
          //     : SizedBox.shrink()
        ],
      ),
    );
  }

  onCropped(Uint8List? value) async {
    if (value != null) {
      croppedData = value;
      AiChatTpe chatType = widget.photoType == AiTutorPhotoType.general
          ? AiChatTpe.generalOCR
          : widget.photoType == AiTutorPhotoType.math
              ? AiChatTpe.mathOCR
              : AiChatTpe.flashcardOCR;

      String text = await ref
          .read(askAiProviderProvider.notifier)
          .onGenerateImageOCR(
              image: value, aiChatType: chatType, context: context);

      isCropping = false;
      setState(() {});

      if (!mounted) return;
      if (text.isNotEmpty) {
        context.pop(OCRQuery(text: text, chatType: chatType));
        context.pop(OCRQuery(text: text, chatType: chatType));
      }
    }
  }

  Widget _buildCorner(
      {required Border border,
      EdgeInsets? margin,
      BorderRadius? borderRadius}) {
    return Container(
      width: 16,
      height: 16,
      margin: margin,
      decoration: BoxDecoration(
        border: border,
        borderRadius: borderRadius,
      ),
    );
  }
}

class OCRQuery {
  String text;
  AiChatTpe chatType;

  OCRQuery({
    required this.text,
    required this.chatType,
  });
}
