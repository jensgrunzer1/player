import 'package:app/models/models.dart';
import 'package:app/providers/providers.dart';
import 'package:app/router.dart';
import 'package:app/ui/widgets/artist_thumbnail.dart';
import 'package:app/ui/widgets/bottom_space.dart';
import 'package:app/ui/widgets/spinner.dart';
import 'package:app/ui/widgets/typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArtistsScreen extends StatefulWidget {
  static const routeName = '/artists';
  final AppRouter router;

  const ArtistsScreen({
    Key? key,
    this.router = const AppRouter(),
  }) : super(key: key);

  @override
  _ArtistsScreenState createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen> {
  late ArtistProvider _artistProvider;
  late AppStateProvider _appStateProvider;
  late ScrollController _scrollController;
  late double _currentScrollOffset;
  bool _loading = false;

  void _scrollListener() {
    _currentScrollOffset = _scrollController.offset;

    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      fetchData();
    }
  }

  Future<void> fetchData() async {
    if (_loading) return;

    setState(() => _loading = true);
    await _artistProvider.paginate();
    setState(() => _loading = false);
  }

  @override
  void initState() {
    super.initState();

    _artistProvider = context.read<ArtistProvider>();
    _appStateProvider = context.read<AppStateProvider>();
    _currentScrollOffset = _appStateProvider.get('artists.scrollOffSet') ?? 0.0;

    _scrollController = ScrollController(
      initialScrollOffset: _currentScrollOffset,
    );

    _scrollController.addListener(_scrollListener);

    fetchData();
  }

  @override
  void dispose() {
    _loading = false;
    _appStateProvider.set('artists.scrollOffSet', _currentScrollOffset);
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ArtistProvider>(
        builder: (_, provider, __) {
          return CupertinoTheme(
            data: CupertinoThemeData(
              primaryColor: Colors.white,
            ),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                CupertinoSliverNavigationBar(
                  backgroundColor: Colors.black,
                  largeTitle: const LargeTitle(text: 'Artists'),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((
                    BuildContext context,
                    int index,
                  ) {
                    Artist artist = provider.artists[index];
                    return InkWell(
                      onTap: () => widget.router.gotoArtistDetailsScreen(
                        context,
                        artist: artist,
                      ),
                      child: ListTile(
                        shape: Border(
                          bottom: Divider.createBorderSide(context),
                        ),
                        leading: ArtistThumbnail(artist: artist, asHero: true),
                        title: Text(
                          artist.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }, childCount: provider.artists.length),
                ),
                _loading
                    ? SliverToBoxAdapter(
                        child: Container(
                          height: 72,
                          child: Center(child: Spinner(size: 16)),
                        ),
                      )
                    : SliverToBoxAdapter(),
                const BottomSpace(),
              ],
            ),
          );
        },
      ),
    );
  }
}
