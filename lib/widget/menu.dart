import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class AppMenuDrawer extends StatelessWidget {
  final BuildContext parentContext;
  final VoidCallback? onImportFinished; // 新增

  const AppMenuDrawer({
    required this.parentContext,
    this.onImportFinished,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              '菜单',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('导入CSV'),
            onTap: () async {
              Navigator.of(context).pop();
              await Future.delayed(const Duration(milliseconds: 200));
              await importUserCsv(parentContext);
              if (onImportFinished != null) {
                onImportFinished!(); // 导入后刷新主页面
              }
            },
          ),

          ListTile(
            leading: Icon(Icons.info),
            title: Text('关于'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'SP12地力表',
                applicationVersion: '1.1.0',
                children: const [
                  Text('这是一个SP12地力表管理工具。'),
                  SizedBox(height: 8),
                  Text('数据来源：'),
                  Text('1. IIDX SP☆12難易度議論スレ@したらば'),
                  SelectableText('https://x.com/iidx_sp12'),
                  Text('2. CPI'),
                  SelectableText('https://cpi.makecir.com/'),
                  SizedBox(height: 8),
                  Text('感谢以上项目的作者及玩家参与投票提供的数据支持。'),
                  Text('© 2025 SeaRay all rights reserved.'),
                  SizedBox(height: 8),
                  Text('本软件仅供学习交流使用，禁止用于商业用途。'),
                  Text('如有侵权请联系作者删除。'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// 定义状态优先级（数值越小越好）
const lampPriority = {
  'FULLCOMBO CLEAR': 0,
  'EX HARD CLEAR': 1,
  'HARD CLEAR': 2,
  'CLEAR': 3,
  'EASY CLEAR': 4,
  'ASSIST CLEAR': 5,
  'FAILED': 6,
  'NO PLAY': 7,
};

Future<void> importUserCsv(BuildContext context) async {
  // 1. 弹窗让用户选择
  bool? overwrite = await showDialog<bool>(
    context: context,
    builder: (context) {
      bool temp = false;
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('导入设置'),
            content: Row(
              children: [
                Switch(
                  value: temp,
                  onChanged: (v) {
                    setStateDialog(() {
                      temp = v;
                    });
                  },
                ),
                const SizedBox(width: 8),
                const Text('覆盖已有更好成绩'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, temp),
                child: const Text('确定'),
              ),
            ],
          );
        },
      );
    },
  );
  if (overwrite == null) return;

  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );
  if (result == null || result.files.isEmpty) return;

  final file = result.files.first;
  String content;
  if (file.bytes != null) {
    content = String.fromCharCodes(file.bytes!);
  } else if (file.path != null) {
    content = await File(file.path!).readAsString();
  } else {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('文件读取失败')));
    return;
  }

  final rows = const CsvToListConverter(
    eol: '\n',
    shouldParseNumbers: false,
  ).convert(content);

  // 获取表头
  final header = rows.first.cast<String>();
  final titleIndex = header.indexWhere((h) => h.contains('タイトル'));
  final anotherDifficultyIndex = header.indexWhere((h) => h.contains('ANOTHER 難易度'));
  final anotherClearTypeIndex = header.indexWhere((h) => h.contains('ANOTHER クリアタイプ'));
  final hyperDifficultyIndex = header.indexWhere((h) => h.contains('HYPER 難易度'));
  final hyperClearTypeIndex = header.indexWhere((h) => h.contains('HYPER クリアタイプ'));
  final legendariaDifficultyIndex = header.indexWhere((h) => h.contains('LEGGENDARIA 難易度'));
  final legendariaClearTypeIndex = header.indexWhere((h) => h.contains('LEGGENDARIA クリアタイプ'));

  // 验证CSV格式是否正确
  if ([
    titleIndex,
    anotherDifficultyIndex,
    anotherClearTypeIndex,
    hyperDifficultyIndex,
    hyperClearTypeIndex,
    legendariaDifficultyIndex,
    legendariaClearTypeIndex,
  ].contains(-1)) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('CSV格式不正确')));
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  int updateCount = 0;

  for (var i = 1; i < rows.length; i++) {
    final row = rows[i];
    if (row.length <=
        [
          titleIndex,
          anotherDifficultyIndex,
          anotherClearTypeIndex,
          hyperDifficultyIndex,
          hyperClearTypeIndex,
          legendariaDifficultyIndex,
          legendariaClearTypeIndex,
        ].reduce((a, b) => a > b ? a : b)) {
      continue;
    }
    final title = row[titleIndex]?.toString().trim();

    // ANOTHER (SPA)
    final levelA = row[anotherDifficultyIndex]?.toString();
    final clearTypeA = row[anotherClearTypeIndex]?.toString().trim();
    if (levelA == '12' &&
        title != null &&
        clearTypeA != null &&
        clearTypeA.isNotEmpty) {
      final key = '${title}_SPA';
      final old = prefs.getString(key) ?? 'NO PLAY';
      if (lampPriority[clearTypeA] != null && lampPriority[old] != null) {
        if (overwrite || lampPriority[clearTypeA]! < lampPriority[old]!) {
          await prefs.setString(key, clearTypeA);
          updateCount++;
        }
      }
    }

    // HYPER (SPH)
    final levelH = row[hyperDifficultyIndex]?.toString();
    final clearTypeH = row[hyperClearTypeIndex]?.toString().trim();
    if (levelH == '12' &&
        title != null &&
        clearTypeH != null &&
        clearTypeH.isNotEmpty) {
      final key = '${title}_SPH';
      final old = prefs.getString(key) ?? 'NO PLAY';
      if (lampPriority[clearTypeH] != null && lampPriority[old] != null) {
        if (overwrite || lampPriority[clearTypeH]! < lampPriority[old]!) {
          await prefs.setString(key, clearTypeH);
          updateCount++;
        }
      }
    }

    // LEGGENDARIA (SPL)
    final levelL = row[legendariaDifficultyIndex]?.toString();
    final clearTypeL = row[legendariaClearTypeIndex]?.toString().trim();
    if (levelL == '12' &&
        title != null &&
        clearTypeL != null &&
        clearTypeL.isNotEmpty) {
      final key = '${title}_SPL';
      final old = prefs.getString(key) ?? 'NO PLAY';
      if (lampPriority[clearTypeL] != null && lampPriority[old] != null) {
        if (overwrite || lampPriority[clearTypeL]! < lampPriority[old]!) {
          await prefs.setString(key, clearTypeL);
          updateCount++;
        }
      }
    }
  }

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('已导入 $updateCount 条记录')));
}
