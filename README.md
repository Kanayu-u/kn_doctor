# kn_doctor

[![Version](https://img.shields.io/badge/version-1.1.2-blue.svg)](CHANGELOG.md)
[![Framework](https://img.shields.io/badge/framework-QBCore%20%7C%20QBox%20%7C%20ESX%20%7C%20Standalone-green.svg)](#依存)
[![License](https://img.shields.io/badge/license-source--available-lightgrey.svg)](LICENSE)

NPC ドクターによる蘇生・回復スクリプト。救急隊（EMS）が不在のときだけ、マップ上の NPC ドクターから有料で治療を受けられます。

## 特徴

- **フレームワーク自動検出**: qbx_core / qb-core / es_extended / Standalone に対応（設定不要）
- **EMS 出勤数チェック**: 出勤中の救急隊が指定人数以上いる場合は NPC の利用を拒否（EMS の仕事を奪わない設計）
- **状態自動判別**: プレイヤーの死亡/ダウン状態をサーバー側で判定し、蘇生・回復を自動で切り替え
- **サーバー側検証**: 料金・クールダウン・死亡判定はすべてサーバー側で処理（クライアント改ざん対策）
- 治療費引き落としの監査ログをサーバーコンソールに出力

## 依存

- ox_lib（必須）

## インストール

1. `kn_doctor` を resources フォルダに配置
2. `server.cfg` に `ensure kn_doctor` を追加（`ox_lib` より後に起動すること）

## 設定（config.lua）

| キー | 説明 |
|---|---|
| `Config.EMS.JobName` | 救急隊のジョブ名（既定: `ambulance`） |
| `Config.EMS.MaxOnDuty` | この人数以上の EMS が出勤中なら NPC 利用不可。`0` で常時利用可 |
| `Config.Prices.Revive / Heal` | 蘇生 / 回復の料金（銀行から引き落とし） |
| `Config.Cooldown` | 再利用までの待機秒数 |
| `Config.Doctors` | NPC の座標・モデル・ラベル（複数追加可能） |
| `Config.Text` | 表示テキスト（すべて編集可能） |

## 注意事項

- Standalone モード（フレームワーク未検出）では経済システムが無いため治療は無料になります。

## ライセンス

ソース公開型の独自ライセンスです。**自分のサーバーでの使用と改変は自由ですが、再配布・再販・再公開は禁止**しています。詳細は [LICENSE](LICENSE) を参照してください。
