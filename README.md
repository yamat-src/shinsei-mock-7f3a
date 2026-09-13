# 申込Webモック環境（面接用）

IT人材面接の実技課題で使う、架空の申込Webサイトです。
登場する会社・システム・案件・人物・住所・番号はすべて架空であり、実在の事業者とは関係ありません。

## フォルダ構成

```
template/index.html   マスター（これを編集すると以降の発行分に反映される）
docs/                 ← GitHub Pages の公開ルート
  index.html            ルートに来た人向けのダミー404ページ
  robots.txt            検索エンジン除け
  files/                添付ファイル（全候補者で共有）
  <候補者ID>/index.html  候補者ごとの課題ページ
new-candidate.ps1     候補者URLを発行
remove-candidate.ps1  候補者URLを削除
list-candidates.ps1   発行済みURLの一覧
candidates.tsv        発行台帳（.gitignore 済み。手元だけで管理）
```

`template/` と各 `*.ps1` は `docs/` の外にあるため、GitHub Pages では公開されません。

## 初回セットアップ（1回だけ）

GitHub → Settings → Pages → **Source: Deploy from a branch**、**Branch: `main` / `/docs`** にして Save。
（以前の `/(root)` から `/docs` への変更が必要です）

## 候補者ごとのURL発行

```powershell
.\new-candidate.ps1 -Label "9/20 午前 A氏"
# → https://yamat-src.github.io/shinsei-mock-7f3a/a7f3k2x9/

git add docs
git commit -m "add candidate"
git push
```

数分後に公開されます。候補者にはこのURLだけを伝えてください。

## 面接終了後

```powershell
.\remove-candidate.ps1 -Id a7f3k2x9    # 個別に削除
.\remove-candidate.ps1 -All            # 全部まとめて削除

git add -A docs
git commit -m "remove candidate"
git push
```

## サイト全体を一時的に非公開にする

Settings → Pages → **Unpublish site**。再開は Source を `main` / `/docs` に再設定するだけです。
CDNキャッシュのため、反映まで数分〜十数分かかることがあります。

## 注意

- **面接官コンソール（正解マスタ入り）はこのフォルダに含めないでください。** 面接官のPCでローカルに開いて使います。
- このビルドには正解データ・採点ロジック・管理画面は一切含まれていません（ソースを見ても正解は分かりません）。
- **GitHub Pages に認証機能はありません。** URLを分けても「知っている人だけが開ける秘匿URL」にすぎず、候補者がURLを第三者に共有すれば防げません。
- **リポジトリを Public のままにすると、発行済みの候補者IDが一覧で見えます**（＝候補者Aが候補者BのURLを知れる）。これを避けるには、リポジトリを Private にしたうえで Pages を使ってください（GitHub Pro / Team 以上のプランが必要です）。
- 本格的にアクセス制御したい場合は、Cloudflare Pages + Cloudflare Access（メールのワンタイムPIN認証が無料枠で使える）への移行を検討してください。

## 課題内容を差し替えるとき

`template/index.html` を編集します。既に発行済みの `docs/<候補者ID>/index.html` は
発行時点のコピーなので自動では変わりません。作り直す場合は一度削除してから再発行してください。
