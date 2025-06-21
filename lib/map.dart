// 版本号与版本名映射
const Map<String, String> versionMap = {
  //"33": "Sparkle Shower",
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
  "11": "IIDX RED",
  "10": "10th",
  "9": "9th",
  "8": "8th",
  "7": "7th",
  "6": "6th",
  "5": "5th",
};

String getVersionName(String version) {
  return versionMap[version] ?? version;
}

// 状态缩写映射
const Map<String, String> statusAbbr = {
  'FULLCOMBO CLEAR': 'FC',
  'EX HARD CLEAR': 'EXHC',
  'HARD CLEAR': 'HC',
  'CLEAR': 'NC',
  'EASY CLEAR': 'EC',
  'ASSIST CLEAR': 'AC',
  'FAILED': 'F',
  'NO PLAY': 'N',
};