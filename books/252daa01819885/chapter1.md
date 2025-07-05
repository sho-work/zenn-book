---
title: "なぜテストコードを書く必要があるのか？"
---


# なぜテストコードを書く必要があるのか？

ソフトウェア開発において、品質の高いコードを維持し続けるためには、テストコードの作成が非常に重要です。特にRuby on Railsのようなフレームワークを使っている場合、Rspecを用いたテストが一般的です。ここではRubyとRspecを使った具体的な例を交えながら、なぜテストコードを書くべきなのか、その理由を説明します。

## 1. 不具合・デグレに気付きやすくなる

アプリケーションのコードに改修や機能追加をするとき、既存のコードに予期しない影響を与えてしまうことがあります。これをデグレード（デグレ）と呼びます。

テストコードがあると、このような問題に即座に気づくことができます。例えば以下のRubyコードを考えてみましょう。

```ruby
def sum(a, b)
  a + b
end

# テストコード
RSpec.describe 'sumメソッドのテスト' do
  it '2つの数値の和を返す' do
    expect(sum(2, 3)).to eq(5)
  end
end
```

もし誤って以下のようにロジックを変更した場合、テストコードがFailするため、即座に間違いに気づけます。

```ruby
def sum(a, b)
  (a + b) * 2  # 本来の仕様ではない変更
end
```

## 2. リファクタリングしやすくなる（これが一番大事）

コードをリファクタリングする際に、テストコードが存在すると安心してコードを整理・改善できます。なぜなら、リファクタリング後にテストを実行することで、挙動が変わっていないかどうかを自動で確認できるためです。

また、テストしにくいコードとは、しばしば保守性が低く整理されていないコードである可能性が高いです。つまり、テストが書きやすいコードに改善することで、コードの品質も向上します。

例えば以下のような複雑で分岐がネストしているメソッドがあったとします。

```ruby
def discount(user, product)
  if user.logged_in?
    if user.vip?
      if product.on_sale?
        product.price * 0.8
      else
        product.price * 0.9
      end
    else
      if product.on_sale?
        product.price * 0.9
      else
        product.price
      end
    end
  else
    product.price
  end
end
```

このようなメソッドをリファクタリングするとしても、テストコードがあれば安心して進められます。
また、実際にテストを書いてみて、contextがネストしすぎてしまうため、テストがしにくいことにも気付けます。
これによって、「discountメソッドの設計に問題があるんじゃないか？」と気づけるようになります。
(今回の実装だと、正直パッと見で問題があることに気づけそうですが・・・)

```ruby
RSpec.describe '#discount' do
  let(:product_on_sale) { double(price: 100, on_sale?: true) }
  let(:product_not_on_sale) { double(price: 100, on_sale?: false) }

  context 'ユーザーがログインしている場合' do
    context 'VIPユーザーの場合' do
      context '商品がセール中の場合' do
        it '20%オフになる' do
          user = double(logged_in?: true, vip?: true)
          expect(discount(user, product_on_sale)).to eq(80)
        end
      end

      context '商品がセール中でない場合' do
        it '10%オフになる' do
          user = double(logged_in?: true, vip?: true)
          expect(discount(user, product_not_on_sale)).to eq(90)
        end
      end
    end

    context '一般ユーザーの場合' do
      context '商品がセール中の場合' do
        it '10%オフになる' do
          user = double(logged_in?: true, vip?: false)
          expect(discount(user, product_on_sale)).to eq(90)
        end
      end

      context '商品がセール中でない場合' do
        it '割引なしの価格になる' do
          user = double(logged_in?: true, vip?: false)
          expect(discount(user, product_not_on_sale)).to eq(100)
        end
      end
    end
  end

  context 'ユーザーがログインしていない場合' do
    it '常に割引なしの価格になる' do
      user = double(logged_in?: false)
      expect(discount(user, product_on_sale)).to eq(100)
    end
  end
end
```

このテストがあるおかげで、リファクタリング後も正しい挙動をしているかすぐに検証できます。

## 3. コードの仕様が一目でわかる

テストケースがあると、コードがどのような状況でどのように振る舞うかを簡単に理解できます。つまり、テストコード自体がドキュメントの役割を果たします。

たとえば以下のようなテストコードを見れば、このメソッドがユーザーのステータスによって異なるメッセージを返すことがすぐに分かります。

```ruby
RSpec.describe '#welcome_message' do
  context 'ユーザーが管理者の場合' do
    it '管理者用のメッセージを表示する' do
      user = double(admin?: true)
      expect(welcome_message(user)).to eq('ようこそ、管理者！')
    end
  end

  context 'ユーザーが一般ユーザーの場合' do
    it '一般ユーザー用のメッセージを表示する' do
      user = double(admin?: false)
      expect(welcome_message(user)).to eq('ようこそ、ユーザー！')
    end
  end
end
```

このようにテストコードは、仕様の明確化や挙動の確認にも大きく貢献します。

## まとめ

テストコードを書くことは、ソフトウェア開発の質を高め、メンテナンス性を劇的に向上させます。
不具合やデグレードの早期発見、安心してリファクタリングできる環境作り、コードの仕様を明確に伝える役割といった、多くのメリットがあります。

