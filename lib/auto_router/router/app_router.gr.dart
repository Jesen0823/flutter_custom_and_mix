// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [DetailPage]
class DetailRoute extends PageRouteInfo<DetailRouteArgs> {
  DetailRoute({
    Key? key,
    String? id = "",
    String? title,
    int? count = 0,
    GoodsEntity? goods,
    List<PageRouteInfo>? children,
  }) : super(
         DetailRoute.name,
         args: DetailRouteArgs(
           key: key,
           id: id,
           title: title,
           count: count,
           goods: goods,
         ),
         rawPathParams: {'id': id},
         rawQueryParams: {'title': title, 'count': count},
         initialChildren: children,
       );

  static const String name = 'DetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final queryParams = data.queryParams;
      final args = data.argsAs<DetailRouteArgs>(
        orElse: () => DetailRouteArgs(
          id: pathParams.optString('id', ""),
          title: queryParams.optString('title'),
          count: queryParams.optInt('count', 0),
        ),
      );
      return DetailPage(
        key: args.key,
        id: args.id,
        title: args.title,
        count: args.count,
        goods: args.goods,
      );
    },
  );
}

class DetailRouteArgs {
  const DetailRouteArgs({
    this.key,
    this.id = "",
    this.title,
    this.count = 0,
    this.goods,
  });

  final Key? key;

  final String? id;

  final String? title;

  final int? count;

  final GoodsEntity? goods;

  @override
  String toString() {
    return 'DetailRouteArgs{key: $key, id: $id, title: $title, count: $count, goods: $goods}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DetailRouteArgs) return false;
    return key == other.key &&
        id == other.id &&
        title == other.title &&
        count == other.count &&
        goods == other.goods;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      id.hashCode ^
      title.hashCode ^
      count.hashCode ^
      goods.hashCode;
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [LikeDetailPage]
class LikeDetailRoute extends PageRouteInfo<void> {
  const LikeDetailRoute({List<PageRouteInfo>? children})
    : super(LikeDetailRoute.name, initialChildren: children);

  static const String name = 'LikeDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LikeDetailPage();
    },
  );
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    Key? key,
    dynamic Function(bool)? onResult,
    List<PageRouteInfo>? children,
  }) : super(
         LoginRoute.name,
         args: LoginRouteArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () => const LoginRouteArgs(),
      );
      return LoginPage(key: args.key, onResult: args.onResult);
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key, this.onResult});

  final Key? key;

  final dynamic Function(bool)? onResult;

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key, onResult: $onResult}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LoginRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [TabLikePage]
class TabLikeRoute extends PageRouteInfo<void> {
  const TabLikeRoute({List<PageRouteInfo>? children})
    : super(TabLikeRoute.name, initialChildren: children);

  static const String name = 'TabLikeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TabLikePage();
    },
  );
}

/// generated route for
/// [TabPage]
class TabRoute extends PageRouteInfo<void> {
  const TabRoute({List<PageRouteInfo>? children})
    : super(TabRoute.name, initialChildren: children);

  static const String name = 'TabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TabPage();
    },
  );
}

/// generated route for
/// [TabSavePage]
class TabSaveRoute extends PageRouteInfo<void> {
  const TabSaveRoute({List<PageRouteInfo>? children})
    : super(TabSaveRoute.name, initialChildren: children);

  static const String name = 'TabSaveRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TabSavePage();
    },
  );
}
