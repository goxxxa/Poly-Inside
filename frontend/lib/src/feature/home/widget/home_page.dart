import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:poly_inside/src/common/utils/capitalizer.dart';
import 'package:poly_inside/src/common/utils/word_formatter.dart';
import 'package:poly_inside/src/common/widgets/sort_button.dart';
import 'package:poly_inside/src/common/widgets/static_stars_rating.dart';
import 'package:poly_inside/src/feature/home/bloc/home_bloc.dart';
import 'package:poly_inside/src/feature/home/widget/search_bar.dart';
import 'package:poly_inside/src/feature/initialization/widget/initialization.dart';
import 'package:poly_inside/src/feature/professor_profile/widget/professor_profile_page.dart';
import 'package:poly_inside/src/feature/authentication/widget/user_scope.dart';
import 'package:poly_inside/src/feature/user_profile/bloc/data_bloc.dart';
import 'package:poly_inside/src/feature/user_profile/widget/user_profile_page.dart';
import 'package:shared/shared.dart';

/// {@template home_page}
/// HomePage widget.
/// {@endtemplate}
class HomePage extends StatefulWidget {
  // ignore: library_private_types_in_public_api
  static _HomePageState? of(BuildContext context) =>
      context.findAncestorStateOfType<_HomePageState>();

  /// {@macro home_page}
  const HomePage({
    super.key, // ignore: unused_element
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController? _scrollController;
  ValueNotifier<bool>? _valueNotifier;
  HomeBloc? _bloc;
  ProfileDataBLoC? _profileDataBLoC;
  TextEditingController? _textEditingController;
  FocusNode? _node;
  String reviewInRussian = 'отзыв';
  int count = 20;
  static const Duration scrollDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    _node = FocusNode();
    _valueNotifier = ValueNotifier(false);
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController?.position.pixels ==
            _scrollController?.position.maxScrollExtent) {
          count += 20;
          _bloc?.add(ListRequested(
              count: count, group: UserScope.userOf(context).group));
        }
        if (_scrollController?.position.pixels !=
            _scrollController?.position.minScrollExtent) {
          _valueNotifier!.value = true;
        } else {
          _valueNotifier!.value = false;
        }
      });
    _textEditingController = TextEditingController()
      ..addListener(() => _bloc?.add(TextFieldChanged(
          name: _textEditingController?.text.toLowerCase() ?? '')));
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _bloc ??= HomeBloc(repository: InitializationScope.repositoryOf(context))
      ..add(
          ListRequested(count: count, group: UserScope.userOf(context).group));
    _profileDataBLoC ??=
        ProfileDataBLoC(repository: InitializationScope.repositoryOf(context))
          ..add(ProfileDataRequested(userId: UserScope.userOf(context).id));
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bloc?.close();
    _node?.dispose();
    _textEditingController?.dispose();
    _scrollController?.dispose();
    _valueNotifier?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ValueListenableBuilder(
        valueListenable: _valueNotifier!,
        builder: (_, value, child) => Visibility(
          visible: _valueNotifier!.value,
          child: FloatingActionButton.extended(
            onPressed: () {
              _scrollController?.animateTo(0,
                  duration: scrollDuration, curve: Curves.easeInOut);
            },
            backgroundColor: Colors.green,
            label: const AnimatedSize(
              duration: Duration(milliseconds: 150),
              child: Center(
                child: Icon(CupertinoIcons.up_arrow),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              Row(
                children: [
                  Builder(builder: (builderContext) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          builderContext,
                          MaterialPageRoute<void>(
                            builder: (builderContext) => ProfilePage(
                              bloc: _profileDataBLoC,
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: UserScope.userOf(context).id,
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 31,
                          child: ClipOval(
                            child: UserScope.userOf(context).avatar.isNotEmpty
                                ? Image.memory(
                                    height: 62,
                                    width: 62,
                                    fit: BoxFit.cover,
                                    Uint8List.fromList(
                                      UserScope.userOf(context).avatar,
                                    ),
                                  )
                                : SvgPicture.asset(
                                    'assets/icons/no_photo.svg',
                                    width: 35,
                                  ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(
                    width: 18,
                  ),
                  ProfessorSearchBar(
                    node: _node,
                    controller: _textEditingController,
                  )
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Мои преподаватели',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  SortButton(
                    type: SortingTypes.professors,
                  )
                ],
              ),
              const SizedBox(
                height: 19,
              ),
              Expanded(
                child: BlocBuilder<HomeBloc, HomePageState>(
                  bloc: _bloc,
                  builder: (context, state) {
                    return state.when(
                      processing: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      idle: () => const SizedBox(),
                      error: (error) => Center(
                        child: Text(error.toString()),
                      ),
                      loaded: (professors) {
                        return ListView.separated(
                          controller: _scrollController,
                          itemCount: professors.length,
                          separatorBuilder: (context, index) => const SizedBox(
                            height: 25,
                          ),
                          itemBuilder: (context, index) {
                            return RepaintBoundary(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (builderContext) =>
                                          _InheritedProfessorScope(
                                        professor: professors[index],
                                        child: ProfessorProfilePage(
                                          repository:
                                              InitializationScope.repositoryOf(
                                                  context),
                                          professor: professors[index],
                                        ),
                                      ),
                                    ),
                                  );
                                  _textEditingController?.clear();
                                  _node?.unfocus();
                                },
                                child: Container(
                                  width: 360,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xFFEEF9EF),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.grey[200],
                                          radius: 27,
                                          backgroundImage: MemoryImage(
                                            Uint8List.fromList(
                                              professors[index].avatar,
                                            ),
                                          ),
                                          child: Uint8List.fromList(
                                            professors[index].avatar,
                                          ).isEmpty
                                              ? SvgPicture.asset(
                                                  'assets/icons/no_photo.svg',
                                                )
                                              : null,
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                professors[index]
                                                    .name
                                                    .capitalize(),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Stack(
                                                children: [
                                                  StaticStarsRating(
                                                    spaceBetween: 8,
                                                    textSize: 16,
                                                    size: 20,
                                                    value: professors[index]
                                                        .rating,
                                                  ),
                                                  // StarsRating(
                                                  //   size: const Size(20, 20),
                                                  //   textSize: 16,
                                                  //   value: professors[index]
                                                  //       .rating,
                                                  //   spaceBetween: 8,
                                                  // ),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(
                                                          height: 3,
                                                        ),
                                                        Text(
                                                          (professors[index]
                                                                      .rating ==
                                                                  0)
                                                              ? 'нет отзывов'
                                                              : '${professors[index].reviewsCount} ${reviewInRussian.formatReview(professors[index].reviewsCount)}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Color.fromARGB(
                                                              255,
                                                              138,
                                                              138,
                                                              138,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// {@template user_profile_page}
/// _InheritedProfessorScope widget.
/// {@endtemplate}
class _InheritedProfessorScope extends InheritedWidget {
  /// {@macro user_profile_page}
  const _InheritedProfessorScope({
    required this.professor,
    required super.child,
    super.key, // ignore: unused_element
  });

  final Professor professor;

  static _InheritedProfessorScope? maybeOf(BuildContext context,
          {bool listen = true}) =>
      listen
          ? context
              .dependOnInheritedWidgetOfExactType<_InheritedProfessorScope>()
          : context.getInheritedWidgetOfExactType<_InheritedProfessorScope>();
  static Professor professorOf(BuildContext context) =>
      maybeOf(context)?.professor ?? _notFoundInheritedWidgetOfExactType();

  static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
        'Out of scope, not found inherited widget '
            'a _InheritedApp of the exact type',
        'out_of_scope',
      );

  @override
  bool updateShouldNotify(_InheritedProfessorScope oldWidget) =>
      !(professor == oldWidget.professor);
}
