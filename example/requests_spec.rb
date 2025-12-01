RSpec.describe MemosController, type: :request do
  describe 'GET /memos' do
    context 'メモが存在する場合' do
      let!(:memos) { create_list(:memo, 3) }

      it '全てのメモが取得でき降順で並び変えられていることを確認する' do
        get '/memos'
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['memos'].length).to eq(3)
        result_memo_ids = response.parsed_body['memos'].map { _1['id'] }
        expected_memo_ids = memos.reverse.map(&:id)
        expect(result_memo_ids).to eq(expected_memo_ids)
      end
    end

    # WIP: 他の検索条件の場合のテストを追加する
    # 検索条件は以下の通り
    # - タイトルが部分一致する場合
    # - タイトルが完全一致する場合
    # - タイトルが空文字の場合
    # - タイトルがnilの場合
  end

  describe 'GET /memos/:id' do
    context 'メモが存在する場合' do
      let!(:memo) { create(:memo) }
      let!(:comments) { create_list(:comment, 3, memo: memo) }

      it '指定したメモ、コメントが取得できることを確認する' do
        get "/memos/#{memo.id}", headers: { Accept: 'application/json' }
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['memo']['id']).to eq(memo.id)
        expect(response.parsed_body['memo']['comments'].length).to eq(3)
        result_comment_ids = response.parsed_body['memo']['comments'].map { _1['id'] }
        expected_comments_ids = comments.reverse.map(&:id)
        expect(result_comment_ids).to eq(expected_comments_ids)
      end
    end

    context '存在しないメモを取得しようとした場合' do
      it '404が返ることを確認する' do
        get '/memos/0'
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body['message']).to eq('メモが見つかりません')
      end
    end
  end
end
