# frozen_string_literal: true

describe 'Barong unit testing' do
  it 'works' do
    expect(true).to be_truthy
  end
end

describe 'Barong functional testing', type: :feature do
  it 'works' do
    visit root_path
    expect(page).to have_text 'Hello, world!'
  end
end
