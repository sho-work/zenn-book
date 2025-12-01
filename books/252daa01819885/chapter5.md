---
title: "Railsで動かすRSpec [Requests spec編]"
---

# 実際にControllerのRequests specを書いてみよう
本章では、Ruby on RailsのControllerに対してRequests specを書いていきます。
前章のModel編に続いて、より実践的なテストケースを作成していきましょう。

## 前提の説明

### 今回使用するController
以下は今回テストを書くBlogsControllerのindexアクションです。

```ruby
class Api::V1::BlogsController < ApplicationController
  # GET /api/v1/blogs
  def index
    # TODO: paginationを実装する
    # TODO: class methodを利用してフィルタリングする
    blogs = Blog.all
    if params[:title].present?
      sanitized_title = sanitize_sql_for_conditions(["title LIKE ?", "%#{params[:title]}%"])
      blogs = blogs.where(sanitized_title)
    end

    if params[:status].present?
      case params[:status]
      when 'published'
        blogs = blogs.published
      when 'unpublished'
        blogs = blogs.unpublished
      end
    end

    render json: blogs
  end
end
````

このコントローラーは以下の機能を持っています：

* ブログ一覧を取得してJSON形式で返す
* タイトルでの部分一致検索（パラメータ: `title`）
* ステータスでのフィルタリング（パラメータ: `status`）

  * "published": 公開済みのブログのみ
  * "unpublished": 未公開のブログのみ

## Requests specについて

Requests specは、HTTPリクエストからレスポンスまでの一連の流れをテストします。Model specがモデルの単体テストだったのに対し、Requests specはより統合的なテストとなります。

### Requests specで検証すること

Requests specでは主に以下を検証します：

* **HTTPステータスコード**: 正しいステータスコードが返されるか
* **レスポンスボディ**: 期待されるデータが返されるか
* **パラメータ処理**: リクエストパラメータが正しく処理されるか

## 実際にBlogsControllerのRequests specを書いてみよう！

### 1. テスト対象を決める

BlogsControllerのindexアクションでは、以下のテスト対象があります：

* **基本的な動作**

  * ブログ一覧が取得できること
* **フィルタリング機能**

  * タイトルでの検索
  * ステータスでのフィルタリング
* **エッジケース**

  * ブログが存在しない場合
  * 無効なパラメータが送信された場合

### 2. 何を検証するべきかを考える

Requests specでも、chapter2で説明した2つの観点から検証を行います：

* **アウトプットのテスト**: HTTPレスポンス（ステータスコード、レスポンスボディ）の検証
* **副作用の検証**: この場合は特にありません（GETリクエストは副作用を起こさない）

### 3. describeとcontextの具体例

```ruby
RSpec.describe 'Api::V1::Blogs', type: :request do
  describe 'GET /api/v1/blogs' do
    context 'when blogs exist' do
      # ブログが存在する場合のテスト
    end

    context 'when no blogs exist' do
      # ブログが存在しない場合のテスト
    end

    context 'when filtering by title' do
      context 'when title parameter is provided' do
        # タイトルパラメータが提供された場合のテスト
      end

      context 'when title parameter is empty' do
        # タイトルパラメータが空の場合のテスト
      end
    end

    context 'when filtering by status' do
      context 'when status is "published"' do
        # ステータスがpublishedの場合のテスト
      end

      context 'when status is "unpublished"' do
        # ステータスがunpublishedの場合のテスト
      end

      context 'when status is invalid' do
        # ステータスが無効な値の場合のテスト
      end
    end

    context 'when filtering by both title and status' do
      # タイトルとステータスの両方でフィルタリングする場合のテスト
    end
  end
end
```

### 4. 各テストケースのitブロックとAAAパターンの説明

#### 基本的な動作のテスト

```ruby
RSpec.describe 'Api::V1::Blogs', type: :request do
  describe 'GET /api/v1/blogs' do
    context 'when blogs exist' do
      # Arrange（準備）
      let!(:blog1) { create(:blog, title: 'First Blog', published: true) }
      let!(:blog2) { create(:blog, title: 'Second Blog', published: false) }
      let!(:blog3) { create(:blog, title: 'Third Blog', published: true) }

      it 'returns all blogs with status 200' do
        # Act（実行）
        get '/api/v1/blogs'

        # Assert（検証）
        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        expect(json.length).to eq(3)

        blog_ids = json.map { |blog| blog['id'] }
        expect(blog_ids).to contain_exactly(blog1.id, blog2.id, blog3.id)
      end
    end
  end
end
```

**AAAパターンの説明**

* **Arrange（準備）**: `let!`を使用して3つのブログをデータベースに作成
* **Act（実行）**: `get '/api/v1/blogs'`でGETリクエストを送信
* **Assert（検証）**:

  * HTTPステータスが200であることを確認
  * レスポンスに3つのブログが含まれることを確認
  * 作成したブログのIDがレスポンスに含まれることを確認

#### タイトルフィルタリングのテスト

```ruby
context 'when filtering by title' do
  # Arrange（準備）
  let!(:rails_blog) { create(:blog, title: 'Ruby on Rails Tutorial') }
  let!(:js_blog) { create(:blog, title: 'JavaScript Guide') }
  let!(:rails_advanced) { create(:blog, title: 'Advanced Rails Patterns') }

  context 'when title parameter is provided' do
    it 'returns only blogs matching the title' do
      # Act（実行）
      get '/api/v1/blogs', params: { title: 'Rails' }

      # Assert（検証）
      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json.length).to eq(2)

      blog_ids = json.map { |blog| blog['id'] }
      expect(blog_ids).to contain_exactly(rails_blog.id, rails_advanced.id)
    end
  end
end
```

**AAAパターンの説明**

* **Arrange（準備）**: 異なるタイトルを持つブログを作成
* **Act（実行）**: タイトルパラメータ付きでGETリクエストを送信
* **Assert（検証）**:

  * タイトルに"Rails"を含むブログのみが返されることを確認
  * JavaScriptのブログが含まれないことを確認

#### ステータスフィルタリングのテスト

```ruby
context 'when filtering by status' do
  # Arrange（準備）
  let!(:published_blog1) { create(:blog, :published) }
  let!(:published_blog2) { create(:blog, :published) }
  let!(:unpublished_blog) { create(:blog, :unpublished) }

  context 'when status is "published"' do
    it 'returns only published blogs' do
      # Act（実行）
      get '/api/v1/blogs', params: { status: 'published' }

      # Assert（検証）
      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json.length).to eq(2)

      blog_ids = json.map { |blog| blog['id'] }
      expect(blog_ids).to contain_exactly(published_blog1.id, published_blog2.id)
    end
  end
end
```

### 5. 完全なテストコード

以下はBlogsControllerのindexアクションに対する完全なRequests specです：

```ruby
require 'rails_helper'

RSpec.describe 'Api::V1::Blogs', type: :request do
  describe 'GET /api/v1/blogs' do
    context 'when blogs exist' do
      let!(:blog1) { create(:blog, title: 'First Blog', published: true) }
      let!(:blog2) { create(:blog, title: 'Second Blog', published: false) }
      let!(:blog3) { create(:blog, title: 'Third Blog', published: true) }

      it 'returns all blogs with status 200' do
        get '/api/v1/blogs'

        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        expect(json.length).to eq(3)

        blog_ids = json.map { |blog| blog['id'] }
        expect(blog_ids).to contain_exactly(blog1.id, blog2.id, blog3.id)
      end
    end

    context 'when no blogs exist' do
      it 'returns empty array with status 200' do
        get '/api/v1/blogs'

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq([])
      end
    end

    context 'when filtering by title' do
      let!(:rails_blog) { create(:blog, title: 'Ruby on Rails Tutorial') }
      let!(:js_blog) { create(:blog, title: 'JavaScript Guide') }
      let!(:rails_advanced) { create(:blog, title: 'Advanced Rails Patterns') }

      context 'when title parameter is provided' do
        it 'returns only blogs matching the title' do
          get '/api/v1/blogs', params: { title: 'Rails' }

          expect(response).to have_http_status(:ok)

          json = response.parsed_body
          expect(json.length).to eq(2)

          blog_ids = json.map { |blog| blog['id'] }
          expect(blog_ids).to contain_exactly(rails_blog.id, rails_advanced.id)
        end

        it 'is case insensitive' do
          get '/api/v1/blogs', params: { title: 'rails' }

          expect(response).to have_http_status(:ok)

          json = response.parsed_body
          expect(json.length).to eq(2)

          blog_ids = json.map { |blog| blog['id'] }
          expect(blog_ids).to contain_exactly(rails_blog.id, rails_advanced.id)
        end
      end

      context 'when title parameter is empty' do
        it 'returns all blogs' do
          get '/api/v1/blogs', params: { title: '' }

          expect(response).to have_http_status(:ok)

          json = response.parsed_body
          expect(json.length).to eq(3)
        end
      end
    end

    context 'when filtering by status' do
      let!(:published_blog1) { create(:blog, :published) }
      let!(:published_blog2) { create(:blog, :published) }
      let!(:unpublished_blog) { create(:blog, :unpublished) }

      context 'when status is "published"' do
        it 'returns only published blogs' do
          get '/api/v1/blogs', params: { status: 'published' }

          expect(response).to have_http_status(:ok)

          json = response.parsed_body
          expect(json.length).to eq(2)

          blog_ids = json.map { |blog| blog['id'] }
          expect(blog_ids).to contain_exactly(published_blog1.id, published_blog2.id)
        end
      end

      context 'when status is "unpublished"' do
        it 'returns only unpublished blogs' do
          get '/api/v1/blogs', params: { status: 'unpublished' }

          expect(response).to have_http_status(:ok)

          json = response.parsed_body
          expect(json.length).to eq(1)

          expect(json.first['id']).to eq(unpublished_blog.id)
        end
      end

      context 'when status is invalid' do
        it 'returns all blogs' do
          get '/api/v1/blogs', params: { status: 'invalid_status' }

          expect(response).to have_http_status(:ok)

          json = response.parsed_body
          expect(json.length).to eq(3)
        end
      end
    end

    context 'when filtering by both title and status' do
      let!(:published_rails) { create(:blog, title: 'Rails Guide', published: true) }
      let!(:unpublished_rails) { create(:blog, title: 'Rails Tips', published: false) }
      let!(:published_js) { create(:blog, title: 'JavaScript', published: true) }

      it 'applies both filters correctly' do
        get '/api/v1/blogs', params: { title: 'Rails', status: 'published' }

        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        expect(json.length).to eq(1)

        expect(json.first['id']).to eq(published_rails.id)
      end
    end
  end
end
```

## まとめ

本章では、BlogsControllerのindexアクションに対するRequests specを書きました。

Requests specでは：

* HTTPリクエストからレスポンスまでの一連の流れをテスト
* ステータスコードやレスポンスボディを検証
* パラメータによるフィルタリング機能を網羅的にテスト

Model specが個別のメソッドの動作を検証するのに対し、Requests specはより実際の使用に近い形でテストを行います。両方のテストを適切に書くことで、アプリケーションの品質を保証できます。

