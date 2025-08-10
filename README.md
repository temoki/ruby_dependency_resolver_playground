# ruby_dependency_resolver_playground

Molinilloライブラリを使った依存関係解決のサンプルプロジェクトです。

## 概要

このプロジェクトでは、Ruby用の依存関係解決ライブラリ「Molinillo」の使い方を学ぶためのサンプルコードを提供しています。

## ファイル構成

- `lib/main.rb`: Molinilloを使った依存関係解決のサンプル実装
- `ARCHITECTURE_ja.md`: Molinilloアーキテクチャの日本語版ドキュメント
- `Gemfile`: 必要なgemの定義

## 実行方法

```bash
# 依存関係をインストール
bundle install

# サンプルコードを実行
ruby lib/main.rb
```

## サンプルの内容

サンプルでは以下のケースを実演しています：

1. **正常な依存関係解決**: 競合のない依存関係の解決
2. **バージョン競合のケース**: 互換性のない依存関係による競合（予定）
3. **複数パッケージの同時解決**: 複数のパッケージの依存関係を同時に解決

## 実装の詳細

### 主要クラス

- `Package`: パッケージを表現するクラス（名前、バージョン、依存関係）
- `Requirement`: 依存関係の要件を表現するクラス（名前、バージョン制約）
- `SimpleSpecificationProvider`: Molinillo用のSpecificationProviderの実装
- `SimpleUI`: Molinillo用のUIの実装

### 特徴

- シンプルなバージョン制約サポート（`>=`, `~>`, `=`）
- 分かりやすいコンソール出力
- 段階的な解決プロセスの表示

## Molinilloについて

Molinilloは、CocoaPodsプロジェクトで開発された依存関係解決エンジンです。バックトラッキングアルゴリズムと前進チェックを使用して、複雑な依存関係を効率的に解決します。

詳細なアーキテクチャについては、`ARCHITECTURE_ja.md`をご参照ください。