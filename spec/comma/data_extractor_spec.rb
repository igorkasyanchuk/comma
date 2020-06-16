# frozen_string_literal: true

require 'spec_helper'

# comma do
#   name 'Title'
#   description
#
#   isbn :number_10 => 'ISBN-10', :number_13 => 'ISBN-13'
# end

describe Comma::DataExtractor do # rubocop:disable Metrics/BlockLength
  before do
    @isbn = Isbn.new('123123123', '321321321')
    @book = Book.new('Smalltalk-80', 'Language and Implementation', @isbn)

    @data = @book.to_comma
  end

  describe 'when no parameters are provided' do
    it 'should use the string value returned by sending the method name on the object' do
      expect(@data).to include('Language and Implementation')
    end
  end

  describe 'when given a string description as a parameter' do
    it 'should use the string value returned by sending the method name on the object' do
      expect(@data).to include('Smalltalk-80')
    end
  end

  describe 'when an hash is passed as a parameter' do
    describe 'with a string value' do
      it 'should use the string value, returned by sending the hash key to the object' do
        expect(@data).to include('123123123')
        expect(@data).to include('321321321')
      end

      it 'should not fail when an associated object is nil' do
        expect { Book.new('Smalltalk-80', 'Language and Implementation', nil).to_comma }.not_to raise_error
      end
    end
  end
end

describe Comma::DataExtractor, 'id attribute' do
  before do
    @data = Class.new(Struct.new(:id)) do
      comma do
        id 'ID' do |_id| '42' end
      end
    end.new(1).to_comma
  end

  it 'id attribute should yield block' do
    expect(@data).to include('42')
  end
end

describe Comma::DataExtractor, 'with static column method' do
  before do
    @data = Class.new(Struct.new(:id, :name)) do
      comma do
        __static_column__
        __static_column__ 'STATIC'
        __static_column__ 'STATIC' do '' end
        __static_column__ 'STATIC', &:name
      end
    end.new(1, 'John Doe').to_comma
  end

  it 'should extract headers' do
    expect(@data).to eq([nil, nil, '', 'John Doe'])
  end
end

describe Comma::DataExtractor, 'nil value' do
  before do
    @data = Class.new(Struct.new(:id, :name)) do
      comma do
        name
        name 'Name'
        name 'Name' do |_name| nil end
      end
    end.new(1, nil).to_comma
  end

  it 'should extract nil' do
    expect(@data).to eq([nil, nil, nil])
  end
end
