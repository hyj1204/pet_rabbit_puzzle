import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_puzzle/l10n/l10n.dart';
import 'package:flutter_puzzle/layout/layout.dart';
import 'package:flutter_puzzle/models/models.dart';
import 'package:flutter_puzzle/puzzle/puzzle.dart';
import 'package:flutter_puzzle/theme/theme.dart';

/// {@template puzzle_page}
/// The root page of the puzzle UI.
///
/// Builds the puzzle based on the current [PuzzleTheme]
/// from [ThemeBloc].
/// {@endtemplate}
class PuzzlePage extends StatelessWidget {
  /// {@macro puzzle_page}
  const PuzzlePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeBloc(
        themes: const [
          SimpleTheme(),
        ],
      ),
      child: const PuzzleView(),
    );
  }
}

/// {@template puzzle_view}
/// Displays the content for the [PuzzlePage].
/// {@endtemplate}
class PuzzleView extends StatelessWidget {
  /// {@macro puzzle_view}
  const PuzzleView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

    final shufflePuzzle = theme is SimpleTheme;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: BlocProvider(
        create: (context) => PuzzleBloc(4)
          ..add(
            PuzzleInitialized(
              shufflePuzzle: shufflePuzzle,
            ),
          ),
        child: const _Puzzle(
          key: Key('puzzle_view_puzzle'),
        ),
      ),
    );
  }
}

class _Puzzle extends StatefulWidget {
  const _Puzzle({Key? key}) : super(key: key);

  @override
  State<_Puzzle> createState() => _PuzzleState();
}

class _PuzzleState extends State<_Puzzle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation _hintButtonAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500));
    _hintButtonAnimation = Tween(begin: 0.0, end: 40.0).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.50, curve: Curves.easeIn)));
    _controller.forward();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final state = context.select((PuzzleBloc bloc) => bloc.state);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            theme.layoutDelegate.backgroundBuilder(state),
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: AnimatedOpacity(
                  opacity: state.showPromptImage ? 0 : 1,
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.ease,
                  child: const _PuzzleSections(
                    key: Key('puzzle_sections'),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 25,
              right: 20,
              child: GestureDetector(
                  onTapDown: (details) =>
                      context.read<PuzzleBloc>().add(const PuzzlePromptImage()),
                  onTapCancel: () =>
                      context.read<PuzzleBloc>().add(const PuzzlePromptImage()),
                  child: Tooltip(
                    message: state.showPromptImage
                        ? context.l10n.puzzleHintBack
                        : context.l10n.puzzleHint,
                    child: Icon(
                      state.showPromptImage ? Icons.close_sharp : Icons.help,
                      size: _hintButtonAnimation.value,
                      color: Colors.black26,
                    ),
                  )),
            ),
          ],
        );
      },
    );
  }
}

class _PuzzleSections extends StatelessWidget {
  const _PuzzleSections({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final state = context.select((PuzzleBloc bloc) => bloc.state);

    return ResponsiveLayoutBuilder(
      small: (context, child) => Column(
        children: [
          theme.layoutDelegate.startSectionBuilder(state),
          theme.layoutDelegate.puzzleSectionBuilder(state),
          theme.layoutDelegate.endSectionBuilder(state),
        ],
      ),
      medium: (context, child) => Column(
        children: [
          theme.layoutDelegate.startSectionBuilder(state),
          theme.layoutDelegate.puzzleSectionBuilder(state),
          theme.layoutDelegate.endSectionBuilder(state),
        ],
      ),
      large: (context, child) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: theme.layoutDelegate.startSectionBuilder(state),
          ),
          theme.layoutDelegate.puzzleSectionBuilder(state),
          Expanded(
            child: theme.layoutDelegate.endSectionBuilder(state),
          ),
        ],
      ),
    );
  }
}

/// {@template puzzle_board}
/// Displays the board of the puzzle.
/// {@endtemplate}
class PuzzleBoard extends StatelessWidget {
  /// {@macro puzzle_board}
  const PuzzleBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final puzzle = context.select((PuzzleBloc bloc) => bloc.state.puzzle);

    final size = puzzle.getDimension();
    if (size == 0) return const CircularProgressIndicator();

    return BlocBuilder<PuzzleBloc, PuzzleState>(
      builder: (context, state) {
        return theme.layoutDelegate.boardBuilder(
          size,
          puzzle.tiles
              .map(
                (tile) => _PuzzleTile(
                  key: Key('puzzle_tile_${tile.value.toString()}'),
                  tile: tile,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _PuzzleTile extends StatelessWidget {
  const _PuzzleTile({
    Key? key,
    required this.tile,
  }) : super(key: key);

  /// The tile to be displayed.
  final Tile tile;

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final state = context.select((PuzzleBloc bloc) => bloc.state);

    return tile.isWhitespace
        ? theme.layoutDelegate.whitespaceTileBuilder()
        : theme.layoutDelegate.tileBuilder(tile, state);
  }
}
