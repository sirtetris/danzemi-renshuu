# Git

## 簡単なワークフロー

* gitプロンプト（黒いコマンドプロンプト）をデスクトップから実行する
* `cd danzemi-renshuu` (プロジェクトのフォルダーに入る)
* `git pull` (リポジトリからプロジェクトの最新のバージョンをゲットする)
* ファイルを変更する
* `git add ◯◯` (変更があるファイルを選ぶ。例えば：`git add renshuu.txt hoka.jpg test.lua`)
* `git commit -m "◯◯"` (変更を保存して、その説明を書く。例えば：`git commit -m "test.luaの機能を増やした"`)
* `git push` (リポジトリに送る)

## 解けない問題がある、助けて！

* danzemi-renshuuというフォルダーを消す
* gitプロンプト（黒いコマンドプロンプト）をデスクトップから実行する
* `git clone https://github.com/sirtetris/danzemi-renshuu.git`

# Lua

実行するために： `◯◯.lua`のファイルをドラッグアンドドロップでLuaのアイコンに置く

参考： [お気楽 Lua プログラミング超入門](http://www.geocities.jp/m_hiroi/light/lua01.html)

参考： [Wikipedia](https://ja.wikipedia.org/wiki/Lua)

# LÖVE

実行するために： `main.lua`というファイルと`assets`というフォルダーがあるフォルダーをドラッグアンドドロップでLÖVEのアイコンに置く

参考： [Main Page (日本語)](https://love2d.org/wiki/Main_Page_%28%E6%97%A5%E6%9C%AC%E8%AA%9E%29)

利点：

* ゲーム開発のためのフレームワーク
* 分けやすい（love.audio、love.graphics、等のモジュール）

[LÖVEゲームの成分](https://i.imgur.com/G7wK9Lk.png)：

![](https://i.imgur.com/G7wK9Lk.png)
