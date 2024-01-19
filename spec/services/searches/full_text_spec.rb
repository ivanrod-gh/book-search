require 'rails_helper'

RSpec.describe Services::Searches::FullText do
  let(:warning_restricted_chars) { {"warning"=>{"restricted_chars"=>"![]"}} }
  let(:warning_query_too_short) do
    {
      "warning" => {
        "query_length_data" => {
          "current" => 'ab'.length,
          "maximum" => Services::Searches::FullText::MAXIMUM_QUERY_LENGTH,
          "minimum" => Services::Searches::FullText::MINIMUM_QUERY_LENGTH
        }
      }
    }
  end
  let(:warning_query_too_long) do
    { 
      "warning" => {
        "query_length_data" => {
          "current" => ("ab"*50).length,
          "maximum" => Services::Searches::FullText::MAXIMUM_QUERY_LENGTH,
          "minimum" => Services::Searches::FullText::MINIMUM_QUERY_LENGTH
        }
      }
    }
  end

  it 'respond with warning if restricted chars in query found' do
    expect(Services::Searches::FullText.new('query![]').call).to eq warning_restricted_chars
  end

  it 'respond with warning if in is too short' do
    expect(Services::Searches::FullText.new('ab').call).to eq warning_query_too_short
  end

  it 'respond with warning if in is too long' do
    expect(Services::Searches::FullText.new("ab"*50).call).to eq warning_query_too_long
  end

  # No Unit tests for Sphinx search calls
end
