# Changelog

## [1.1.2] - 2026-08-28

GitHub 公開に向けた整備。コードの変更はない。

### Removed
- `escrow_ignore` を削除（escrow 販売を行わないため）。

### Added
- `LICENSE`（ソース公開・再配布禁止の独自ライセンス）。

## [1.1.1] - 2026-08-09

### Fixed
- **ESX で銀行口座を取得できない場合にサーバー側で落ちる可能性があったのを修正。**
  `xPlayer.getAccount('bank')` は該当口座が無いと nil を返すため、
  そのまま `.money` を読んでいた。存在を確かめてから読むようにした。
- ESX の引き落としに理由を渡すようにした（省略時 ESX は "Unknown" と記録するため、
  サーバーの入出金ログから出所を追えなくなっていた）。

### 検証
- **ESX Legacy 1.13.5 + ox_inventory で起動確認**（`Framework: ESX | ox_inventory: true`）。
  使用している ESX の口（`GetExtendedPlayers` / `GetPlayerFromId` / `getAccount` /
  `removeAccountMoney` / `xPlayer.job`）がこの版に存在することをソースで照合済み。
- ※ **ESX の `removeAccountMoney` は残高不足を検査しない**（内部の underflow 判定は
  金額が負のときしか働かない）。このスクリプトの事前残高確認が唯一の防波堤なので外さないこと。

## [1.1.0] - 2026-07-14
### Added
- 多言語対応: 表示テキストを `locales/`（ja / en）へ分離。`Config.Locale` で言語を選択（既定: ja、未定義キーは en にフォールバック）。

### Changed
- サーバーコンソールのログを英語に統一（購入者向け）。

## [1.0.1] - 2026-07-14
### Fixed
- ox_inventory 環境で銀行引き落としが正しく行われない不具合を修正。`exports.ox_inventory:RemoveItem(..., 'bank')` は現金アイテムを対象とし第5引数の用法も誤っていたため、銀行残高は常にフレームワーク API（qbx_core / qb-core / es_extended）で引き落とすよう変更。

### Added
- 治療費引き落としの監査ログ（サーバーコンソール）。
- `escrow_ignore`（config.lua / README.md）を追加し、購入者が設定を編集可能に。

## [1.0.0]
### Added
- 初回リリース（NPC ドクターによる蘇生・回復、EMS 出勤数チェック、クールダウン、QBX/QBCore/ESX/Standalone 対応）。
