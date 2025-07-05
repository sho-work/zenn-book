---
title: "PlainなRubyで動かすRSpec"
---

# この章以降で学ぶこと
この章以降では、前章で学んだ事を念頭に、
実際にテスティングフレームワークを使ってテストコードの書き方を学んでいきます。
（※本記事ではRspecを使用します。）
まずはPlainなRubyで書いたロジックに対してテストコードを書いて、
その次にRuby on Railsで書いたアプリケーションコードのロジックに対してテストを書いていきます。

## 前提条件
- Rubyが使えるようになっていること
- Rspecがインストールされていること

:::details Rspecのインストール
Rubyのインストールは以下のサイト等を参考に行ってください。
https://www.ruby-lang.org/ja/documentation/installation/

### 1. bundlerをインストールする
```bash
$ gem install bundler
```

### 2. 作業用のディレクトリを作成して移動する
以下の例では作業用のディレクトリをplain_ruby_rspecとしています。
```bash
$ mkdir plain_ruby_rspec
$ cd plain_ruby_rspec
```

### 3. bundler を初期化してrspecをインストールする
以下のコマンドを実行してください。Gemfileが生成されます。
```bash
$ bundle init
```
次に、以下のようにGemfileを編集します。
```diff
# frozen_string_literal: true

source "https://rubygems.org"

- # gem "rails"
+ gem "rspec"
```

その後に以下のコマンドを実行します。
```bash
$ bundle install
```

### 4. rspecを初期化する
```bash
$ bundle exec rspec --init
```

参考文献
https://qiita.com/takaesu_ug/items/db44b81bdddf6ed0e9f5
https://techtechmedia.com/ruby-setup-rspec/
:::


## describe/context/itの使い方

- describeにはテストの対象を書きます。
- contextにはテストケースを書きます。
    - contextは基本ネストさせない方がいいです。ネストする場合はその処理・クラスの責務を適切に分けられていないという事なので、分けましょう。
- itブロックにはテストの具体的な期待結果を記述します。

ここまでの内容を使って、以下のUserクラスのテストを書いてみます。
今回はシンプルに考えるために、副作用のないアウトプットのみのロジックにしています。
```ruby
class User
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def greeting(current_time = Time.now)
    case current_time.hour
    when 0..11
      'Good morning!'
    when 12..17
      'Hello!'
    else
      'Good evening!'
    end
  end
end
```

以下のようになると思います。
```ruby
RSpec.describe User do
  describe '#greeting' do
    context '時刻が0:00~11:59の時' do
      it 'Good morning!を返す' do
        user = User.new('Test User')
        morning_time = Time.new(2024, 11, 25, 9, 0, 0) # 9:00 AM
        expect(user.greeting(morning_time)).to eq 'Good morning!'
      end
    end

    context '時刻が12:00~17:59の時' do
      it 'Hello!を返す' do
        user = User.new('Test User')
        afternoon_time = Time.new(2024, 11, 25, 15, 0, 0) # 3:00 PM
        expect(user.greeting(afternoon_time)).to eq 'Hello!'
      end
    end

    context '時刻が18:00~23:59の時' do
      it 'Good evening!を返す' do
        user = User.new('Test User')
        evening_time = Time.new(2024, 11, 25, 20, 0, 0) # 8:00 PM
        expect(user.greeting(evening_time)).to eq 'Good evening!'
      end
    end
  end
end
```

## let/beforeの使い方
letはitブロック内で参照されるものを書きます。`let`は遅延評価され、初めて参照されたときに評価されます。
**let!** は、 `let`と似ていますが、即時評価され、各テストの前に実行されます。

:::message
ポイント💡:  `let`と`let!` は遅延評価か即時評価であるかの違いがあります。`let`はその変数名が呼ばれた時に初めて評価されます。
:::

beforeブロックは即時評価されます。beforeはitブロック内で参照されないものを書くのが良さそうです。
（`let!`の後に評価されるので、`let`や`let!`の下に書くと良いでしょう。）

## AAAを意識したテストコードを書こう！

AAAとは、**Arrange、Act、Assert**のことです。
テストコードの基本ステップはArrange、Act、Assert（準備、実行、検証、以下AAA）の3ステップに分かれます。
AAAを意識することで、何をテストしているのかがわかりやすいテストコードになります。
RSpecのコードであれば、これら3つのステップが以下の場所に分散していることが望ましいです。
- Arrange = let/let!、もしくはbeforeの中（場合によってはitの中でも可）
- Act = itの中
- Assert = itの中

参考:
[【アンチパターン】Arrange、Act、Assert（AAA）を意識できていないRSpecのコード例とその対処法 - Qiita](https://qiita.com/jnchito/items/91779b55cae0f4915da5)
[AAA パターンを用いてテストを構成する](https://github.com/goldbergyoni/nodebestpractices/blob/master/sections/testingandquality/aaa.japanese.md)
（rubyではなく、node.jsのベストプラクティスですが、テスト全般に関して言える事なので、引用しています。）


先ほどのUserクラスに対して、AAAを意識して書いたテストコードを書くと、以下のようになると思います。
（Railsで書いたアプリケーションコードに対するテストコードを書く際にも実践します。）

```ruby
RSpec.describe User do
  describe '#greeting' do
    let(:user) { User.new('Test User') }

    context '時刻が0:00~11:59の時' do
      let(:time) do
        # Arrange
        Time.new(2024, 11, 25, 0, 0, 0) # 0:00
      end

      it 'Good morning!を返す' do
        # Act
        result = user.greeting(time)

        # Assert
        expect(result).to eq 'Good morning!'
      end
    end

    context '時刻が12:00~17:59の時' do
      let(:time) do
        # Arrange
        Time.new(2024, 11, 25, 17, 59, 59) # 17:59
      end

      it 'Hello!を返す' do
        # Act
        result = user.greeting(time)

        # Assert
        expect(result).to eq 'Hello!'
      end
    end

    context '時刻が18:00~23:59の時' do
      let(:time) do
        # Arrange
        Time.new(2024, 11, 25, 18, 0, 0) # 18:00
      end

      it 'Good evening!を返す' do
        # Act
        result = user.greeting(time)

        # Assert
        expect(result).to eq 'Good evening!'
      end
    end
  end
end
```
