# frozen_string_literal: true

describe 'Pager' do
  subject { Dimples::Pager.new('/', posts, options) }

  let(:options) { {} }
  let(:posts) { Array.new(30) { double } }

  describe '#each' do
    context 'with default options' do
      it 'yields the correct page numbers' do
        expect { |b| subject.each(&b) }.to yield_successive_args(1, 2, 3)
      end
    end

    context 'with custom options' do
      before { options[:per_page] = 5 }

      it 'yields the correct page numbers' do
        expect { |b| subject.each(&b) }.to yield_successive_args(*1..6)
      end
    end
  end

  describe '#posts_at' do
    context 'with default options' do
      it 'returns the correct number of paginated items' do
        count = subject.posts_at(1).count
        expect(count).to eq(Dimples::Pager::PER_PAGE_DEFAULT)
      end
    end

    context 'with custom options' do
      before { options[:per_page] = 5 }

      it 'returns the correct number of paginated items' do
        expect(subject.posts_at(1).count).to eq(5)
      end
    end
  end

  describe '#first_page_url' do
    it 'returns the correct URL' do
      expect(subject.first_page_url).to eq('/')
    end
  end

  describe '#last_page_url' do
    context 'with default options' do
      it 'returns the correct URL' do
        expect(subject.last_page_url).to eq('/page_3')
      end
    end

    context 'with custom options' do
      before { options[:per_page] = 30 }

      it 'returns the correct URL' do
        expect(subject.last_page_url).to eq('/')
      end
    end
  end

  describe '#current_page_url' do
    context 'with default options' do
      context 'on the first page' do
        it 'returns the correct URL' do
          expect(subject.current_page_url).to eq('/')
        end
      end

      context 'on the second page' do
        before { subject.step_to(2) }

        it 'returns the correct URL' do
          expect(subject.current_page_url).to eq('/page_2')
        end
      end

      context 'on the last page' do
        before { subject.step_to(3) }

        it 'returns the correct URL' do
          expect(subject.current_page_url).to eq('/page_3')
        end
      end
    end

    context 'with custom options' do
      before { options[:page_prefix] = '?p=' }

      context 'on the first page' do
        it 'returns the correct URL' do
          expect(subject.current_page_url).to eq('/')
        end
      end

      context 'on the second page' do
        before { subject.step_to(2) }

        it 'returns the correct URL' do
          expect(subject.current_page_url).to eq('/?p=2')
        end
      end

      context 'on the last page' do
        before { subject.step_to(3) }

        it 'returns the correct URL' do
          expect(subject.current_page_url).to eq('/?p=3')
        end
      end
    end
  end

  describe '#previous_page_url' do
    context 'with default options' do
      context 'on the first page' do
        it 'returns the correct URL' do
          expect(subject.previous_page_url).to be_nil
        end
      end

      context 'on the second page' do
        before { subject.step_to(2) }

        it 'returns the correct URL' do
          expect(subject.previous_page_url).to eq('/')
        end
      end

      context 'on the last page' do
        before { subject.step_to(3) }

        it 'returns the correct URL' do
          expect(subject.previous_page_url).to eq('/page_2')
        end
      end
    end

    context 'with custom options' do
      before { options[:page_prefix] = '?p=' }

      context 'on the first page' do
        it 'returns the correct URL' do
          expect(subject.previous_page_url).to be_nil
        end
      end

      context 'on the second page' do
        before { subject.step_to(2) }

        it 'returns the correct URL' do
          expect(subject.previous_page_url).to eq('/')
        end
      end

      context 'on the last page' do
        before { subject.step_to(3) }

        it 'returns the correct URL' do
          expect(subject.previous_page_url).to eq('/?p=2')
        end
      end
    end
  end

  describe '#next_page_url' do
    context 'with default options' do
      context 'on the first page' do
        it 'returns the correct URL' do
          expect(subject.next_page_url).to eq('/page_2')
        end
      end

      context 'on the second page' do
        before { subject.step_to(2) }

        it 'returns the correct URL' do
          expect(subject.next_page_url).to eq('/page_3')
        end
      end

      context 'on the last page' do
        before { subject.step_to(3) }

        it 'returns the correct URL' do
          expect(subject.next_page_url).to be_nil
        end
      end
    end

    context 'with custom options' do
      before { options[:page_prefix] = '?p=' }

      context 'on the first page' do
        it 'returns the correct URL' do
          expect(subject.next_page_url).to eq('/?p=2')
        end
      end

      context 'on the second page' do
        before { subject.step_to(2) }

        it 'returns the correct URL' do
          expect(subject.next_page_url).to eq('/?p=3')
        end
      end

      context 'on the last page' do
        before { subject.step_to(3) }

        it 'returns the correct URL' do
          expect(subject.next_page_url).to be_nil
        end
      end
    end
  end

  describe '#to_context' do
    let(:pager_context) { subject.to_context }

    context 'on the first page' do
      it 'returns a valid context' do
        expect(pager_context.current_page).to eq(1)
        expect(pager_context.next_page).to eq(2)
        expect(pager_context.page_count).to eq(3)
        expect(pager_context.post_count).to eq(30)
        expect(pager_context.posts).to eq(posts[0..9])
      end
    end

    context 'on the second page' do
      before { subject.step_to(2) }

      it 'returns a valid context' do
        expect(pager_context.current_page).to eq(2)
        expect(pager_context.next_page).to eq(3)
        expect(pager_context.posts).to eq(posts[10..19])
      end
    end

    context 'on the last page' do
      before { subject.step_to(3) }

      it 'returns a valid context' do
        expect(pager_context.current_page).to eq(3)
        expect(pager_context.posts).to eq(posts[20..29])
      end
    end
  end
end
