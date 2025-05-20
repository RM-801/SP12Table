import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import '../widget/menu.dart';

// 版本号与版本名映射
const Map<String, String> versionMap = {
  "32": "Pinky Crush",
  "31": "EPOLIS",
  "30": "RESIDENT",
  "29": "CastHour",
  "28": "BISTROVER",
  "27": "HEROIC VERSE",
  "26": "Rootage",
  "25": "CANNON BALLERS",
  "24": "SINOBUZ",
  "23": "copula",
  "22": "PENDUAL",
  "21": "SPADA",
  "20": "tricoro",
  "19": "Lincle",
  "18": "Resort Anthem",
  "17": "SIRIUS",
  "16": "EMPRESS",
  "15": "DJ TROOPERS",
  "14": "GOLD",
  "13": "DistorteD",
  "12": "HAPPY SKY",
  "11": "RED",
  "10": "10th",
  "9": "9th",
  "8": "8th",
  "7": "7th",
  "6": "6th",
  "5": "5th",
};

// 状态缩写映射
const Map<String, String> statusAbbr = {
  'FULLCOMBO': 'FC',
  'EX HARD CLEAR': 'EXHC',
  'HARD CLEAR': 'HC',
  'CLEAR': 'NC',
  'EASY CLEAR': 'EC',
  'ASSIST CLEAR': 'AC',
  'FAILED': 'F',
  'NO PLAY': 'N',
};

String getVersionName(String version) {
  return versionMap[version] ?? version;
}

Future<List<EarthPowerSong>> loadEarthPowerSongs() async {
  final jsonString = await rootBundle.loadString(
    'assets/earth_power_filled.json',
  );
  final List<dynamic> jsonList = json.decode(jsonString);
  final prefs = await SharedPreferences.getInstance();

  return jsonList.map((e) {
    final song = EarthPowerSong.fromJson(e);
    final key = '${song.title}_${song.difficulty}';
    song.status = prefs.getString(key) ?? 'NO PLAY';
    return song;
  }).toList();
}

class EarthPowerSong {
  final String title;
  final String difficulty;
  final String level;
  final String version;
  final String normal;
  final String hard;
  final String exhard;
  String status;

  EarthPowerSong({
    required this.title,
    required this.difficulty,
    required this.level,
    required this.version,
    required this.normal,
    required this.hard,
    required this.exhard,
    this.status = 'NO PLAY',
  });

  factory EarthPowerSong.fromJson(Map<String, dynamic> json) {
    return EarthPowerSong(
      title: json['title'],
      difficulty: json['difficulty'],
      level: json['level'],
      version: json['version'],
      normal: json['normal'],
      hard: json['hard'],
      exhard: json['exhard'], // 这里要用 exhard 字段
    );
  }
}

class EarthPowerPage extends StatefulWidget {
  const EarthPowerPage({super.key});

  @override
  State<EarthPowerPage> createState() => _EarthPowerPageState();
}

class _EarthPowerPageState extends State<EarthPowerPage> {
  late Future<List<EarthPowerSong>> _songsFuture;

  @override
  void initState() {
    super.initState();
    _songsFuture = loadEarthPowerSongs();
  }

  // 导入CSV后调用
  Future<void> refreshSongs() async {
    setState(() {
      _songsFuture = loadEarthPowerSongs();
    });
  }

  Set<String> selectedVersions = {};
  Set<String> selectedStatus = {};
  final ValueNotifier<int> statusBarNotifier = ValueNotifier(0);
  bool showNormal = false;
  bool showExhard = false;

  static const List<String> groupOrder = [
    '地力S+',
    '個人差S+',
    '地力S',
    '個人差S',
    '地力A+',
    '個人差A+',
    '地力A',
    '個人差A',
    '地力B+',
    '個人差B+',
    '地力B',
    '個人差B',
    '地力C',
    '個人差C',
    '地力D',
    '個人差D',
    '地力E',
    '個人差E',
    '地力F',
    '難易度未定',
  ];

  static const List<String> exhGroupOrder = [
    'CPI > 2450',
    'CPI 2400 - 2450',
    'CPI 2350 - 2400',
    'CPI 2300 - 2350',
    'CPI 2250 - 2300',
    'CPI 2200 - 2250',
    'CPI 2150 - 2200',
    'CPI 2100 - 2150',
    'CPI 2050 - 2100',
    'CPI 2000 - 2050',
    'CPI 1950 - 2000',
    'CPI 1900 - 1950',
    'CPI 1850 - 1900',
    'CPI 1800 - 1850',
    'CPI 1750 - 1800',
    'CPI 1700 - 1750',
    'CPI < 1700',
    'CPI 未定',
  ];

  @override
  void dispose() {
    statusBarNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<List<EarthPowerSong>>(
          future: _songsFuture,
          builder: (context, snapshot) {
            int belowNormalCount = 0;
            int belowHardCount = 0;
            int belowEXHardCount = 0;
            if (snapshot.hasData) {
              final songs = snapshot.data!;
              belowEXHardCount =
                  songs
                      .where(
                        (song) =>
                            song.status != 'FULLCOMBO' &&
                            song.status != 'EX HARD CLEAR',
                      )
                      .length;
              belowHardCount =
                  songs
                      .where(
                        (song) =>
                            song.status != 'FULLCOMBO' &&
                            song.status != 'EX HARD CLEAR' &&
                            song.status != 'HARD CLEAR',
                      )
                      .length;
              belowNormalCount =
                  songs
                      .where(
                        (song) =>
                            song.status != 'FULLCOMBO' &&
                            song.status != 'EX HARD CLEAR' &&
                            song.status != 'HARD CLEAR' &&
                            song.status != 'CLEAR',
                      )
                      .length;
            }
            return Text(
              showNormal
                  ? 'SP☆12ノマゲ表(未クリア：$belowNormalCount)'
                  : showExhard
                  ? 'SP☆12エクハ表(未エクハ：$belowEXHardCount)'
                  : 'SP☆12ハード表(未難：$belowHardCount)',
            );
          },
        ),
      ),
      drawer: AppMenuDrawer(
        parentContext: context,
        onImportFinished: refreshSongs, // 新增
      ),
      body: FutureBuilder<List<EarthPowerSong>>(
        future: _songsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('加载失败: ${snapshot.error}'));
          }
          final songs = snapshot.data ?? [];
          if (songs.isEmpty) {
            return const Center(child: Text('暂无数据'));
          }

          var filteredSongs =
              songs.where((song) {
                final versionOk =
                    selectedVersions.isEmpty ||
                    selectedVersions.contains(song.version);
                final statusOk =
                    selectedStatus.isEmpty ||
                    selectedStatus.contains(song.status);
                return versionOk && statusOk;
              }).toList();

          // 分组逻辑
          final Map<String, List<EarthPowerSong>> grouped = {};
          if (showExhard) {
            // 按exhard分组
            for (var song in filteredSongs) {
              String groupKey = 'CPI 未定';
              double? ex;
              try {
                ex = double.tryParse(song.exhard);
              } catch (_) {
                ex = null;
              }
              if (ex != null) {
                if (ex > 2450) {
                  groupKey = 'CPI > 2450';
                } else if (ex >= 2400) {
                  groupKey = 'CPI 2400 - 2450';
                } else if (ex >= 2350) {
                  groupKey = 'CPI 2350 - 2400';
                } else if (ex >= 2300) {
                  groupKey = 'CPI 2300 - 2350';
                } else if (ex >= 2250) {
                  groupKey = 'CPI 2250 - 2300';
                } else if (ex >= 2200) {
                  groupKey = 'CPI 2200 - 2250';
                } else if (ex >= 2150) {
                  groupKey = 'CPI 2150 - 2200';
                } else if (ex >= 2100) {
                  groupKey = 'CPI 2100 - 2150';
                } else if (ex >= 2050) {
                  groupKey = 'CPI 2050 - 2100';
                } else if (ex >= 2000) {
                  groupKey = 'CPI 2000 - 2050';
                } else if (ex >= 1950) {
                  groupKey = 'CPI 1950 - 2000';
                } else if (ex >= 1900) {
                  groupKey = 'CPI 1900 - 1950';
                } else if (ex >= 1850) {
                  groupKey = 'CPI 1850 - 1900';
                } else if (ex >= 1800) {
                  groupKey = 'CPI 1800 - 1850';
                } else if (ex >= 1750) {
                  groupKey = 'CPI 1750 - 1800';
                } else if (ex >= 1700) {
                  groupKey = 'CPI 1700 - 1750';
                } else {
                  groupKey = 'CPI < 1700';
                }
              }
              grouped.putIfAbsent(groupKey, () => []).add(song);
            }
          } else {
            // 原有分组
            for (var song in filteredSongs) {
              final key = showNormal ? song.normal : song.hard;
              final groupKey = groupOrder.contains(key) ? key : '難易度未定';
              grouped.putIfAbsent(groupKey, () => []).add(song);
            }
          }

          // 展示时用不同顺序
          final List<String> order = showExhard ? exhGroupOrder : groupOrder;

          return ListView(
            children: [
              // 统计栏（只刷新自己）
              ValueListenableBuilder(
                valueListenable: statusBarNotifier,
                builder: (context, _, __) {
                  // 统计各状态数量
                  Map<String, int> statusCount = {
                    for (var abbr in statusAbbr.values) abbr: 0,
                  };
                  for (var song in filteredSongs) {
                    final abbr = statusAbbr[song.status] ?? 'N';
                    statusCount[abbr] = (statusCount[abbr] ?? 0) + 1;
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    child: Card(
                      color: Colors.grey[100],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children:
                              statusAbbr.values.map((abbr) {
                                return Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        abbr,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text('${statusCount[abbr]}'),
                                    ],
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // 筛选器
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    // 左侧筛选按钮
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        // 版本筛选
                        FilterChip(
                          label: const Text('版本筛选'),
                          selected: selectedVersions.isNotEmpty,
                          onSelected: (_) async {
                            final result = await showDialog<Set<String>>(
                              context: context,
                              builder: (context) {
                                final temp = Set<String>.from(
                                  selectedVersions,
                                );
                                return StatefulBuilder(
                                  builder: (context, setStateDialog) {
                                    return AlertDialog(
                                      title: const Text('选择版本'),
                                      content: SizedBox(
                                        width: 300,
                                        height: 400,
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    temp.addAll(
                                                      versionMap.keys,
                                                    );
                                                    setStateDialog(() {});
                                                  },
                                                  child: const Text('全选'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    final all =
                                                        Set<String>.from(
                                                          versionMap.keys,
                                                        );
                                                    final newSet = all
                                                        .difference(temp)
                                                        .union(
                                                          temp.difference(
                                                            all,
                                                          ),
                                                        );
                                                    temp
                                                      ..clear()
                                                      ..addAll(newSet);
                                                    setStateDialog(() {});
                                                  },
                                                  child: const Text('反选'),
                                                ),
                                              ],
                                            ),
                                            Expanded(
                                              child: ListView(
                                                children:
                                                    versionMap.entries.map((
                                                      e,
                                                    ) {
                                                      return CheckboxListTile(
                                                        value: temp.contains(
                                                          e.key,
                                                        ),
                                                        title: Text(e.value),
                                                        onChanged: (v) {
                                                          if (v == true) {
                                                            temp.add(e.key);
                                                          } else {
                                                            temp.remove(
                                                              e.key,
                                                            );
                                                          }
                                                          setStateDialog(
                                                            () {},
                                                          );
                                                        },
                                                      );
                                                    }).toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(
                                                context,
                                                temp,
                                              ),
                                          child: const Text('确定'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                            if (result != null) {
                              setState(() {
                                selectedVersions = result;
                              });
                            }
                          },
                        ),
                        // 状态筛选
                        FilterChip(
                          label: const Text('状态筛选'),
                          selected: selectedStatus.isNotEmpty,
                          onSelected: (_) async {
                            final result = await showDialog<Set<String>>(
                              context: context,
                              builder: (context) {
                                final temp = Set<String>.from(selectedStatus);
                                return StatefulBuilder(
                                  builder: (context, setStateDialog) {
                                    return AlertDialog(
                                      title: const Text('选择状态'),
                                      content: SizedBox(
                                        width: 300,
                                        height: 400,
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    temp.addAll(
                                                      _SongCardState
                                                          .statusOptions,
                                                    );
                                                    setStateDialog(() {});
                                                  },
                                                  child: const Text('全选'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    final all =
                                                        Set<String>.from(
                                                          _SongCardState
                                                              .statusOptions,
                                                        );
                                                    final newSet = all
                                                        .difference(temp)
                                                        .union(
                                                          temp.difference(
                                                            all,
                                                          ),
                                                        );
                                                    temp
                                                      ..clear()
                                                      ..addAll(newSet);
                                                    setStateDialog(() {});
                                                  },
                                                  child: const Text('反选'),
                                                ),
                                              ],
                                            ),
                                            Expanded(
                                              child: ListView(
                                                children: [
                                                  ..._SongCardState
                                                      .statusOptions
                                                      .map(
                                                        (
                                                          s,
                                                        ) => CheckboxListTile(
                                                          value: temp
                                                              .contains(s),
                                                          title: Text(s),
                                                          onChanged: (v) {
                                                            if (v == true) {
                                                              temp.add(s);
                                                            } else {
                                                              temp.remove(s);
                                                            }
                                                            setStateDialog(
                                                              () {},
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(
                                                context,
                                                temp,
                                              ),
                                          child: const Text('确定'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                            if (result != null) {
                              setState(() {
                                selectedStatus = result;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const Spacer(), // 中间弹性占位
                    // 右侧normal/hard/exh按钮
                    GroupSwitchBar(
                      showNormal: showNormal,
                      showExhard: showExhard,
                      onSwitch: (mode) {
                        setState(() {
                          if (mode == 'hard') {
                            showNormal = false;
                            showExhard = false;
                          } else if (mode == 'normal') {
                            showNormal = true;
                            showExhard = false;
                          } else if (mode == 'exhard') {
                            showNormal = false;
                            showExhard = true;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              // 分组展示
              ...order.where((group) => grouped.containsKey(group)).map((
                group,
              ) {
                final entry = MapEntry(group, grouped[group]!);
                return ExpansionTile(
                  title: Row(
                    children: [
                      const Opacity(
                        opacity: 0,
                        child: SizedBox(width: 48), // 占位用，和箭头宽度一致
                      ),
                      Expanded(
                        child: Text(
                          entry.key,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 保留默认箭头
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            const minCardWidth = 260.0;
                            int columns = (constraints.maxWidth / minCardWidth)
                                .floor()
                                .clamp(2, 5);
                            double cardWidth =
                                (constraints.maxWidth - (columns - 1) * 8) /
                                columns;

                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  entry.value.map((song) {
                                    return SizedBox(
                                      width: cardWidth,
                                      child: SongCard(
                                        song: song,
                                        onStatusChanged: () {
                                          statusBarNotifier.value++;
                                          setState(() {}); // 新增：刷新统计栏和AppBar
                                        },
                                      ),
                                    );
                                  }).toList(),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class SongCard extends StatefulWidget {
  final EarthPowerSong song;
  final VoidCallback? onStatusChanged;

  const SongCard({required this.song, this.onStatusChanged, super.key});

  @override
  State<SongCard> createState() => _SongCardState();
}

class _SongCardState extends State<SongCard> {
  String status = 'NO PLAY';

  static const List<String> statusOptions = [
    'FULLCOMBO',
    'EX HARD CLEAR',
    'HARD CLEAR',
    'CLEAR',
    'EASY CLEAR',
    'ASSIST CLEAR',
    'FAILED',
    'NO PLAY',
  ];

  @override
  void initState() {
    super.initState();
    _loadLampStatus();
  }

  Future<void> _loadLampStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${widget.song.title}_${widget.song.difficulty}';
    setState(() {
      status = prefs.getString(key) ?? 'NO PLAY';
      widget.song.status = status;
    });
  }

  Future<void> _saveLampStatus(String value) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${widget.song.title}_${widget.song.difficulty}';
    await prefs.setString(key, value);
    widget.song.status = value;
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'FULLCOMBO':
        return Colors.amber;
      case 'EX HARD CLEAR':
        return Colors.yellow;
      case 'HARD CLEAR':
        return Colors.red;
      case 'CLEAR':
        return Colors.blue;
      case 'EASY CLEAR':
        return Colors.lightGreen;
      case 'ASSIST CLEAR':
        return const Color(0xFF8C86FC);
      case 'FAILED':
        return Colors.grey;
      case 'NO PLAY':
        return Colors.transparent;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: getStatusColor(status),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.song.title,
              style: const TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            Text(
              '${widget.song.difficulty}  ${getVersionName(widget.song.version)}',
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
            PopupMenuButton<String>(
              child: Text(
                status,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onSelected: (value) {
                if (!mounted) return;
                setState(() {
                  status = value;
                  widget.song.status = value;
                });
                _saveLampStatus(value); // 保存到本地
                widget.onStatusChanged?.call(); // 通知统计栏刷新
              },
              itemBuilder:
                  (context) =>
                      statusOptions
                          .map((s) => PopupMenuItem(value: s, child: Text(s)))
                          .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class GroupSwitchBar extends StatelessWidget {
  final bool showNormal;
  final bool showExhard;
  final ValueChanged<String> onSwitch;

  const GroupSwitchBar({
    required this.showNormal,
    required this.showExhard,
    required this.onSwitch,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [];
    if (!showNormal && !showExhard) {
      // HARD页面，只显示切换到NORMAL和EXHARD
      buttons.addAll([
        SizedBox(
          child: ElevatedButton(
            onPressed: () => onSwitch('normal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('CLEAR'),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          child: ElevatedButton(
            onPressed: () => onSwitch('exhard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellowAccent,
              foregroundColor: Colors.black,
            ),
            child: const Text('EXH'),
          ),
        ),
      ]);
    } else if (showNormal && !showExhard) {
      // NORMAL页面，只显示切换到HARD和EXHARD
      buttons.addAll([
        SizedBox(
          child: ElevatedButton(
            onPressed: () => onSwitch('hard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('HARD'),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          child: ElevatedButton(
            onPressed: () => onSwitch('exhard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellowAccent,
              foregroundColor: Colors.black,
            ),
            child: const Text('EXH'),
          ),
        ),
      ]);
    } else if (!showNormal && showExhard) {
      // EXHARD页面，只显示切换到HARD和NORMAL
      buttons.addAll([
        SizedBox(
          child: ElevatedButton(
            onPressed: () => onSwitch('normal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('CLEAR'),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          child: ElevatedButton(
            onPressed: () => onSwitch('hard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('HARD'),
          ),
        ),
      ]);
    }
    return Row(children: buttons);
  }
}
