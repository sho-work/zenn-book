RSpec.describe Memo do
  describe 'バリデーションのテスト' do
    let!(:memo) { build(:memo) }

    context '属性が正常な場合' do
      it 'trueを返す' do
        expect(memo).to be_valid
      end
    end

    context 'titleが空文字の場合' do
      before do
        memo.title = ''
      end

      it 'falseを返し、errorが格納される' do
        expect(memo).not_to be_valid
        expect(memo.errors.full_messages).to eq ['タイトルを入力してください']
      end
    end

    context 'titleがnilの場合' do
      before { memo.title = nil }

      it 'falseになり、errorが格納される' do
        expect(memo).not_to be_valid
        expect(memo.errors.full_messages).to eq ['タイトルを入力してください']
      end
    end

    context 'contentが空文字の場合' do
      before { memo.content = '' }

      it 'falseが返り、errorsに「コンテンツを入力してください」と格納されること' do
        expect(memo).not_to be_valid
        expect(memo.errors.full_messages).to eq ['コンテンツを入力してください']
      end
    end

    context 'contentがnilの場合' do
      before { memo.content = nil }

      it 'falseになり、errorsが格納されること' do
        expect(memo).not_to be_valid
        expect(memo.errors.full_messages).to eq ['コンテンツを入力してください']
      end
    end
  end
end
