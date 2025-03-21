require "transaction"

RSpec.describe Transaction do
  describe '#compare' do
    let(:transaction1) do
      Transaction.new(timestamp: '2023-09-03T12:45:00Z', transaction_id: 'txn12345', user_id: 'user987', amount: 500.25)
    end
    let(:transaction2) do
      Transaction.new(timestamp: '2023-09-03T12:45:00Z', transaction_id: 'txn12345', user_id: 'user987', amount: 400.99)
    end

    it 'returns compare result' do
      expect(transaction2 < transaction1).to be true
    end

    it 'returns compare result reverse' do
      expect(transaction2 > transaction1).to be false
    end

    it 'returns not equal' do
      expect(transaction1 == transaction2).to be false
    end
  end

  describe '#to_s' do
    let(:transaction) do
      Transaction.new(timestamp: '2023-09-03T12:45:00Z', transaction_id: 'txn12345', user_id: 'user987', amount: 400.99)
    end

    it 'transforms transaction to string' do
      expect(transaction.to_s).to eq('2023-09-03T12:45:00Z,txn12345,user987,400.99')
    end
  end

  describe '#parse' do
    context 'when valid line' do
      let(:input_line) { '2023-09-03T12:45:00Z,txn12345,user987,369.73' }
      let(:transaction) do
        Transaction.new(timestamp: '2023-09-03T12:45:00Z', transaction_id: 'txn12345', user_id: 'user987',
                        amount: 369.73)
      end

      it 'parses input line' do
        expect(Transaction.parse(input_line)).to eq(transaction)
      end
    end

    context 'when invalid line' do
      let(:input_line) { '2023-09-03T12:45:00Z,user987,369.73' }
      let(:transaction) do
        Transaction.new(timestamp: '2023-09-03T12:45:00Z', transaction_id: 'txn12345', user_id: 'user987',
                        amount: 369.73)
      end

      it 'returns nil' do
        expect(Transaction.parse(input_line)).to be nil
      end
    end
  end
end
