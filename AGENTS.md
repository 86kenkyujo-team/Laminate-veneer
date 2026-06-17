# ラミネートベニアLP 作業ルール

## 基本方針

- 静的HTML/CSSを基本とし、スマホ幅390px前後で表示崩れがないことを優先する。
- 画像・CTA・Googleマップなど、LP上で見える要素は本番URLで表示確認する。
- 変更後は `git status` で差分を確認し、不要な素材や作業ファイルを混ぜない。

## 画像運用

- LP表示用の画像は、原則として幅1200〜1400px程度まで縮小し、1ファイル3MB以下を目安にする。
- 元画像・未圧縮PNG・編集前素材は `assets/images/raw/` または `assets/images/originals/` に置く場合もGit管理しない。
- commit前に `sh scripts/check-new-image-sizes.sh` を実行し、staging済み画像のサイズを確認する。
- ローカルでは `git config core.hooksPath .githooks` を設定し、pre-commitで画像サイズチェックを自動実行する。
- 医療写真は見た目の清潔感と判別性を残しつつ、スマホLPに必要以上の解像度を持ち込まない。

## デプロイ

- 次回以降、通常の公開作業は `sh scripts/ship-now.sh "変更内容"` を使う。正しいGit/Vercel対象確認、画像サイズチェック、commit、push、Vercel本番deploy、公開URL確認までまとめて実行する。
- GitHubへpushしたあと、Vercel本番に反映されているかURLで確認する。
- 本番反映が遅い場合は、GitHub連携の自動デプロイ状況と手動 `vercel --prod --yes` の結果を分けて確認する。
