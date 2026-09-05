import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MindoraApp());

class MindoraApp extends StatelessWidget {
  const MindoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mindora',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050817),
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9B4DFF), brightness: Brightness.dark),
      ),
      home: const HomePage(),
    );
  }
}

class GameInfo {
  final String title, subtitle, icon;
  final List<Color> colors;
  const GameInfo(this.title, this.subtitle, this.icon, this.colors);
}

const games = [
  GameInfo('Color Flow', 'Connect the dots', '💧', [Color(0xFF00C6FF), Color(0xFF0072FF)]),
  GameInfo('Number Merge', 'Merge same numbers', '🔢', [Color(0xFFFF4ECD), Color(0xFF7B2CFF)]),
  GameInfo('Block Drop', 'Fill lines, clear board', '🧱', [Color(0xFF00D7A7), Color(0xFF007F70)]),
  GameInfo('Sort Puzzle', 'Sort by the same color', '🧪', [Color(0xFFFFA000), Color(0xFFFF4D4D)]),
  GameInfo('Mini Sudoku', 'Classic number puzzle', '🧠', [Color(0xFF4DFF75), Color(0xFF008C55)]),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int coins = 1250;
  final progress = [12, 15, 18, 10, 8];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() => coins = p.getInt('coins') ?? 1250);
  }

  Future<void> _saveCoins(int value) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('coins', value);
  }

  void openGame(int i) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => GamePage(index: i, onCoin: (n) {
      setState(() => coins += n);
      _saveCoins(coins);
    })));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _header()),
            SliverToBoxAdapter(child: _daily()),
            const SliverToBoxAdapter(child: Padding(
              padding: EdgeInsets.fromLTRB(24, 26, 24, 14),
              child: Text('Choose Your Game', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
            )),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, i) => GameCard(
                  info: games[i], level: progress[i], onTap: () => openGame(i),
                ), childCount: games.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: .78,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 105)),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomBar(),
    );
  }

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
    child: Row(children: [
      const Text('🧩', style: TextStyle(fontSize: 42)),
      const SizedBox(width: 10),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Mindora', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
        Text('Play • Relax • Sharpen', style: TextStyle(color: Colors.white60)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(color: Colors.white.withOpacity(.07), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white12)),
        child: Text('🪙 $coins', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    ]),
  );

  Widget _daily() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 18),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF17152F), Color(0xFF35143D)]),
      borderRadius: BorderRadius.circular(26),
      border: Border.all(color: const Color(0xFF8B5CFF).withOpacity(.35)),
    ),
    child: Row(children: [
      const Text('🏆', style: TextStyle(fontSize: 58)),
      const SizedBox(width: 15),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Daily Challenge', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        SizedBox(height: 5),
        Text('Complete today’s challenge and win coins!', style: TextStyle(color: Colors.white70)),
        SizedBox(height: 12),
        LinearProgressIndicator(value: .4, minHeight: 7, borderRadius: BorderRadius.all(Radius.circular(10))),
      ])),
      const SizedBox(width: 12),
      FilledButton(onPressed: null, child: Text('Play')),
    ]),
  );
}

class GameCard extends StatelessWidget {
  final GameInfo info; final int level; final VoidCallback onTap;
  const GameCard({super.key, required this.info, required this.level, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(24),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: info.colors),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: info.colors.first.withOpacity(.18), blurRadius: 14)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Container(
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.black.withOpacity(.25), borderRadius: BorderRadius.circular(18)),
          child: Center(child: Text(info.icon, style: const TextStyle(fontSize: 58))),
        )),
        const SizedBox(height: 10),
        Text(info.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        Text(info.subtitle, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        const SizedBox(height: 10),
        Text('Level $level', style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        LinearProgressIndicator(value: (level % 10) / 10, minHeight: 5, borderRadius: BorderRadius.circular(10)),
      ]),
    ),
  );
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();
  @override
  Widget build(BuildContext context) => NavigationBar(
    backgroundColor: const Color(0xFF0B0D20),
    indicatorColor: const Color(0xFF7B2CFF).withOpacity(.25),
    destinations: const [
      NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Games'),
      NavigationDestination(icon: Icon(Icons.star_rounded), label: 'Daily'),
      NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: 'Progress'),
      NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
    ],
  );
}

class GamePage extends StatefulWidget {
  final int index; final void Function(int) onCoin;
  const GamePage({super.key, required this.index, required this.onCoin});
  @override State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late int score;
  final rng = Random();

  @override
  void initState() { super.initState(); score = 0; }

  void reward() { setState(() => score += 10); if (score % 50 == 0) widget.onCoin(25); }

  @override
  Widget build(BuildContext context) {
    final g = games[widget.index];
    return Scaffold(
      appBar: AppBar(title: Text(g.title), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Score $score', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            FilledButton.tonal(onPressed: () => setState(() => score = 0), child: const Text('Restart')),
          ]),
          const SizedBox(height: 18),
          Expanded(child: _gameBody()),
        ]),
      ),
    );
  }

  Widget _gameBody() {
    switch (widget.index) {
      case 0: return const FlowGame();
      case 1: return MergeGame(onMove: (v) => reward());
      case 2: return BlockGame(onMove: (v) => reward());
      case 3: return SortGame(onMove: (v) => reward());
      default: return SudokuGame(onSolved: reward);
    }
  }
}

class FlowGame extends StatefulWidget {
  const FlowGame({super.key});
  @override State<FlowGame> createState() => _FlowGameState();
}
class _FlowGameState extends State<FlowGame> {
  final cells = List.filled(25, 0);
  int selected = -1;
  @override
  void initState() {
    super.initState();
    cells[0]=1; cells[4]=1; cells[20]=2; cells[24]=2;
  }
  @override
  Widget build(BuildContext context) => Column(children: [
    const Text('Connect matching dots without crossing lines.', style: TextStyle(color: Colors.white70)),
    const SizedBox(height: 20),
    AspectRatio(aspectRatio: 1, child: GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 25, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => setState(() => selected = i),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: cells[i]==1 ? Colors.orange : cells[i]==2 ? Colors.cyan : (selected==i ? Colors.white12 : const Color(0xFF10152A)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: cells[i] != 0 ? const Icon(Icons.circle, color: Colors.white, size: 18) : null,
        ),
      ),
    )),
    const SizedBox(height: 15),
    const Text('Tap cells to draw your own path.', style: TextStyle(color: Colors.white54)),
  ]);
}

class MergeGame extends StatefulWidget {
  final void Function(int) onMove;
  const MergeGame({super.key, required this.onMove});
  @override State<MergeGame> createState() => _MergeGameState();
}
class _MergeGameState extends State<MergeGame> {
  final nums = [2,2,4,8,4,8,16,2,4,2,8,16,4,2,32,4];
  void tap(int i) {
    final j = i + 1;
    if (j < nums.length && nums[j] == nums[i]) {
      setState(() { nums[i] *= 2; nums[j] = 0; });
      widget.onMove(10);
    }
  }
  @override
  Widget build(BuildContext context) => Column(children: [
    const Text('Tap two matching neighbors to merge them.'),
    const SizedBox(height: 20),
    Expanded(child: GridView.builder(
      itemCount: 16, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8),
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => tap(i),
        child: Container(
          decoration: BoxDecoration(color: nums[i]==0 ? Colors.white10 : Colors.deepPurpleAccent.withOpacity(.55), borderRadius: BorderRadius.circular(14)),
          child: Center(child: Text(nums[i]==0 ? '' : '${nums[i]}', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900))),
        ),
      ),
    )),
  ]);
}

class BlockGame extends StatefulWidget {
  final void Function(int) onMove;
  const BlockGame({super.key, required this.onMove});
  @override State<BlockGame> createState() => _BlockGameState();
}
class _BlockGameState extends State<BlockGame> {
  final filled = <int>{0,1,2,5,6,7,12,13,18,19,20,24};
  @override
  Widget build(BuildContext context) => Column(children: [
    const Text('Tap empty cells to place blocks. Complete rows for points.'),
    const SizedBox(height: 20),
    Expanded(child: GridView.builder(
      itemCount: 25, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 6, crossAxisSpacing: 6),
      itemBuilder: (_, i) => GestureDetector(
        onTap: () { if (!filled.contains(i)) { setState(() => filled.add(i)); widget.onMove(1); } },
        child: Container(
          decoration: BoxDecoration(
            color: filled.contains(i) ? Colors.tealAccent.withOpacity(.75) : Colors.white10,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    )),
  ]);
}

class SortGame extends StatefulWidget {
  final void Function(int) onMove;
  const SortGame({super.key, required this.onMove});
  @override State<SortGame> createState() => _SortGameState();
}
class _SortGameState extends State<SortGame> {
  final tubes = [
    [0,1,0], [1,2,1], [2,0,2], [0,2,1], []
  ];
  int? from;
  @override
  Widget build(BuildContext context) => Column(children: [
    const Text('Select a tube, then select another tube to move the top ball.'),
    const SizedBox(height: 28),
    Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(tubes.length, (i) => GestureDetector(
      onTap: () {
        if (from == null) { if (tubes[i].isNotEmpty) setState(() => from=i); }
        else {
          if (from != i && tubes[from!].isNotEmpty && tubes[i].length < 4) {
            setState(() { tubes[i].add(tubes[from!].removeLast()); from=null; });
            widget.onMove(2);
          } else setState(() => from=null);
        }
      },
      child: Container(
        width: 55, height: 230,
        decoration: BoxDecoration(border: Border.all(color: from==i ? Colors.amber : Colors.white24, width: 3), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28))),
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: tubes[i].map((c) => Container(
          margin: const EdgeInsets.all(4), width: 36, height: 36,
          decoration: BoxDecoration(shape: BoxShape.circle, color: [Colors.blue, Colors.red, Colors.green][c]),
        )).toList(),
        ),
      ),
    )))),
  ]);
}

class SudokuGame extends StatefulWidget {
  final VoidCallback onSolved;
  const SudokuGame({super.key, required this.onSolved});
  @override State<SudokuGame> createState() => _SudokuGameState();
}
class _SudokuGameState extends State<SudokuGame> {
  final cells = List<int?>.filled(81, null);
  final fixed = {0:5, 1:3, 4:7, 9:6, 12:9, 13:5, 14:3, 20:8, 27:8, 31:6, 35:3, 36:4, 39:8, 41:3, 44:1, 45:7, 49:2, 53:6, 55:6, 57:2, 60:2, 61:8, 66:6, 67:1, 70:4, 71:9, 76:8, 79:7};
  @override
  void initState() { super.initState(); fixed.forEach((k,v) => cells[k]=v); }
  void add(int i) {
    if (fixed.containsKey(i)) return;
    setState(() { cells[i] = ((cells[i] ?? 0) % 9) + 1; });
    if (cells.every((v) => v != null)) widget.onSolved();
  }
  @override
  Widget build(BuildContext context) => Column(children: [
    const Text('Tap an empty square to cycle 1–9.'),
    const SizedBox(height: 15),
    AspectRatio(aspectRatio: 1, child: GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 81, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 9),
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => add(i),
        child: Container(
          margin: const EdgeInsets.all(.5),
          decoration: BoxDecoration(color: fixed.containsKey(i) ? Colors.white12 : Colors.white.withOpacity(.04), border: Border.all(color: Colors.white10)),
          child: Center(child: Text(cells[i]?.toString() ?? '', style: TextStyle(fontSize: 16, fontWeight: fixed.containsKey(i) ? FontWeight.w900 : FontWeight.w500))),
        ),
      ),
    )),
  ]);
}