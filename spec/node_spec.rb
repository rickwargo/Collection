require 'spec_helper'

describe Node do

  let(:node) { Node.new }

  context 'when interrogating its interface' do
    it { is_expected.to respond_to(:index, :value, :next) }
    it { is_expected.to respond_to(:index=, :value=, :next=) }
  end

  context 'when instantiating' do
    it 'should save string value' do
      val = 'abcde'
      expect(Node.new(val).value).to eq(val)
    end

    it 'should save float value' do
      val = 123.45
      expect(Node.new(val).value).to eq(val)
    end

    it 'should save symbol value' do
      val = :here
      expect(Node.new(val).value).to eq(val)
    end
  end
end