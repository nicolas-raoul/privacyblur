import 'dart:math';
import 'dart:ui' as img_tools;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:privacyblur/resources/localization/keys.dart';
import 'package:privacyblur/src/di.dart';
import 'package:privacyblur/src/router.dart';
import 'package:privacyblur/src/screens/image/helpers/image_events.dart';
import 'package:privacyblur/src/screens/image/helpers/image_states.dart';
import 'package:privacyblur/src/screens/image/utils/internal_layout.dart';
import 'package:privacyblur/src/screens/image/widgets/image_viewer.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/filter_result.dart';
import 'package:privacyblur/src/widgets/adaptive_widgets_builder.dart';
import 'package:privacyblur/src/widgets/message_bar.dart';
import 'package:privacyblur/src/widgets/theme/theme_provider.dart';

import 'image_bloc.dart';
import 'widgets/help_widget.dart';
import 'widgets/image_tools.dart';
import 'widgets/screen_rotation.dart';

enum MenuActions { Settings, Camera, Image }

class ImageScreen extends StatelessWidget with AppMessages {
  final DependencyInjection _di;
  final AppRouter _router;
  final String filename;
  late ImageBloc _bloc;
  late InternalLayout internalLayout;
  late Color textColor;
  late double view2PortraitSize;
  late double view2LandScapeSize;
  ScaleUpdateDetails interactiveDetails = ScaleUpdateDetails();

  TransformationController? _transformationController;
  bool imageSet = false;

  ImageScreen(this._di, this._router, this.filename);

  @override
  Widget build(BuildContext context) {
    textColor = AppTheme.fontColor(context);
    internalLayout = InternalLayout(context);

    view2PortraitSize = internalLayout.view2PortraitSize;
    view2LandScapeSize = internalLayout.view2LandScapeSize;

    return MultiRepositoryProvider(
      providers: _di.getRepositoryProviders(),
      child: MultiBlocProvider(
          providers: [_di.getImageBloc()],
          child: BlocConsumer<ImageBloc, ImageStateBase?>(
              listenWhen: (_, curState) => (curState is ImageStateFeedback),
              buildWhen: (_, curState) => !(curState is ImageStateFeedback),
              listener: (_, state) {
                if (state is ImageStateFeedback) {
                  double offsetBottom = internalLayout.offsetBottom;
                  if (state.feedback.contains(FeedbackAction.Navigate)) {
                    offsetBottom = 10;
                    _router.goBack(context);
                  }
                  if (state.feedback.contains(FeedbackAction.ShowMessage)) {
                    showMessage(
                        context: context,
                        message: translate(state.messageData,
                            args: state.positionalArgs),
                        type: state.messageType,
                        offsetBottom: offsetBottom);
                  }
                }
              },
              builder: (BuildContext context, ImageStateBase? state) {
                _bloc = BlocProvider.of<ImageBloc>(context);
                if (state == null && (!imageSet)) {
                  _bloc.add(ImageEventSelected(filename));
                }
                // move to notifier in next version

                return ScaffoldWithAppBar.build(
                  onBackPressed: () => _onBack(context, state),
                  context: context,
                  title: translate(Keys.App_Name),
                  actions: _actionsIcon(context),
                  body: SafeArea(
                    child: _buildHomeBody(context, state),
                    top: internalLayout.landscapeMode,
                    bottom: internalLayout.landscapeMode,
                    left: !internalLayout.landscapeMode,
                    right: !internalLayout.landscapeMode,
                  ),
                );
              })),
    );
  }

  Future<bool> _onBack(BuildContext context, ImageStateBase? state) async {
    bool canClose = true;
    bool confirmNeeded =
        (state != null) && (state is ImageStateScreen) && (!state.isImageSaved);
    if (confirmNeeded) {
      canClose = await AppConfirmationBuilder.build(context,
          message: translate(Keys.Messages_Infos_Exit_Request),
          acceptTitle: translate(Keys.Buttons_Accept),
          rejectTitle: translate(Keys.Buttons_Cancel));
    }
    return Future.value(canClose);
  }

  Widget _buildHomeBody(BuildContext context, ImageStateBase? state) {
    if (state is ImageStateScreen) {
      return LayoutBuilder(builder: (context, constraints) {
        return ScreenRotation(
          baseHeight: constraints.maxHeight,
          baseWidth: constraints.maxWidth,
          view1: (context, w, h, landscape) {
            if (_transformationController == null) {
              _transformationController = TransformationController(
                  _calculateInitialScaleAndOffset(
                      context, state.image.mainImage, w, h));
            }
            return ImageViewer(
                state.image,
                state,
                w,
                h,
                _transformationController!,
                (posX, posY) =>
                    _bloc.add(ImageEventPositionChanged(posX, posY)),
                (posX, posY) => _bloc.add(ImageEventNewFilter(posX, posY)),
                (index) => _bloc.add(ImageEventExistingFilterSelected(index)),
                updateInteractiveDetails
            );
          },
          view2: (context, w, h, landscape) =>
              drawImageToolbar(context, state, w, h, landscape),
          view2Portrait: view2PortraitSize,
          view2Landscape: view2LandScapeSize,
        );
      });
    } else {
      return Center(child: CircularProgressIndicator.adaptive());
    }
  }

  List<Widget> _actionsIcon(BuildContext context) {
    return <Widget>[
        TextButtonBuilder.build(
            color: AppTheme.appBarToolColor(context),
            text: translate(Keys.Buttons_Save),
            onPressed: () => _bloc.add(ImageEventSave2Disk()))
      ];
  }

  Widget drawImageToolbar(BuildContext context, ImageStateScreen state,
      double width, double height, bool isLandscape) {
    var position = state.getSelectedPosition();
    return Container(
      decoration: BoxDecoration(color: AppTheme.barColor(context)),
      //AppTheme.barColor(context)
      child: (position == null)
          ? HelpWidget(height, width)
          : RotatedBox(
              quarterTurns: isLandscape ? 3 : 0,
              child: ImageToolsWidget(
                onEditToolSelected: (EditTool tool) =>
                    _bloc.add(ImageEventEditToolSelected(tool)),
                onRadiusChanged: (double radius) =>
                    _bloc.add(ImageEventShapeSize(radius)),
                onPowerChanged: (double filterPower) =>
                    _bloc.add(ImageEventFilterGranularity(filterPower)),
                onApply: () => _bloc.add(ImageEventApply()),
                onCancel: () => _bloc.add(ImageEventCancel()),
                onPreview: () => _onPreview(context, state.image),
                onBlurSelected: () =>
                    _bloc.add(ImageEventFilterPixelate(false)),
                onPixelateSelected: () =>
                    _bloc.add(ImageEventFilterPixelate(true)),
                onCircleSelected: () => _bloc.add(ImageEventShapeRounded(true)),
                onSquareSelected: () => _bloc.add(ImageEventShapeRounded(false)),
                onFilterDelete: () => _bloc.add(ImageEventExistingFilterDelete(state.selectedFilterPosition)),
                isRounded: position.isRounded,
                isPixelate: position.isPixelate,
                curPower: position.granularityRatio,
                curRadius: position.radiusRatio,
                isLandscape: isLandscape,
                activeTool: state.activeTool,
              )),
    );
  }

  void _onPreview(BuildContext context, ImageFilterResult image) {
    this._router.openImagePreview(context, interactiveDetails, image);
  }

  void updateInteractiveDetails(ScaleUpdateDetails details) {
    interactiveDetails = details;
  }

  Matrix4 _calculateInitialScaleAndOffset(BuildContext context,
      img_tools.Image image, double width, double height) {
    var imgScaleRate = width / image.width;

    ///if you want fit, but not Cover - replace 'max' to 'min'
    imgScaleRate = max(height / image.height, imgScaleRate);
    var matrix = Matrix4.identity()
      ..setEntry(0, 0, imgScaleRate)
      ..setEntry(1, 1, imgScaleRate);
    var newWidth = image.width * imgScaleRate;
    var newHeight = image.height * imgScaleRate;

    /// center image
    matrix
      ..setEntry(0, 3, (width - newWidth) / 2)
      ..setEntry(1, 3, (height - newHeight) / 2);
    return matrix;
  }
}
