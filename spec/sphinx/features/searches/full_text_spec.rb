require 'sphinx_helper'

feature 'User can search for books and authors with full-text search', %q{
  In order to find a needed books or authors
  As an any user
  I'd like to be able to search for the books and authors by their names
} do
  given(:book) { create(:book, :frontier) }
  given(:specific_book) { create(:book, :named_specific) }
  given(:specific_author) { create(:author, :named_specific) }

  describe 'Any user tries to search for a book or author' do
    scenario 'with too short query', js: true do
      visit(searches_show_variants_path)
      find('.search-full-text-button-area').click
      fill_in 'query', with: 'a'
      click_on 'Найти'

      wait_for_ajax
      expect(page).to have_content 'Длина запроса должна быть'
    end

    scenario 'with too long query', js: true do
      visit(searches_show_variants_path)
      find('.search-full-text-button-area').click
      fill_in 'query', with: "a"*100
      click_on 'Найти'

      wait_for_ajax
      expect(page).to have_content 'Длина запроса должна быть'
    end

    scenario 'with invalid query', js: true do
      visit(searches_show_variants_path)
      find('.search-full-text-button-area').click
      fill_in 'query', with: 'abcde!%'
      click_on 'Найти'

      wait_for_ajax
      expect(page).to have_content 'В запросе присутствуют запрещенные символы'
    end

    scenario 'then book does not exist', sphinx: true, js: true do
      visit(searches_show_variants_path)

      find('.search-full-text-button-area').click
      fill_in 'query', with: attributes_for(:book, :frontier)[:name]

      ThinkingSphinx::Test.run do
        click_on 'Найти'

        wait_for_ajax
        within '.search-result-list' do
          expect(page).to have_content 'По вашему запросу ничего не найдено'
        end
      end
    end

    scenario 'and find a book by full book name', sphinx: true, js: true do
      book
      visit(searches_show_variants_path)

      find('.search-full-text-button-area').click
      fill_in 'query', with: attributes_for(:book, :frontier)[:name]

      ThinkingSphinx::Test.run do
        click_on 'Найти'

        wait_for_ajax
        within '.search-result-list' do
          expect(page).to have_content attributes_for(:book, :frontier)[:name]
        end
      end
    end

    scenario 'and find a book by part of it name', sphinx: true, js: true do
      book
      visit(searches_show_variants_path)

      find('.search-full-text-button-area').click
      fill_in 'query', with: attributes_for(:book, :frontier)[:name][1..-1]

      ThinkingSphinx::Test.run do
        click_on 'Найти'

        wait_for_ajax
        within '.search-result-list' do
          expect(page).to have_content attributes_for(:book, :frontier)[:name]
        end
      end
    end

    scenario 'and find a book and an author', sphinx: true, js: true do
      specific_book
      specific_author
      visit(searches_show_variants_path)

      find('.search-full-text-button-area').click
      fill_in 'query', with: attributes_for(:book, :named_specific)[:name]

      ThinkingSphinx::Test.run do
        click_on 'Найти'

        wait_for_ajax
        within '.search-result-list' do
          expect(page).to have_content attributes_for(:book, :named_specific)[:name]
        end
      end
    end
  end
end

