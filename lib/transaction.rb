class Transaction
  include Comparable

  attr_accessor :timestamp, :transaction_id, :user_id, :amount

  def initialize(timestamp:, transaction_id:, user_id:, amount:)
    @timestamp = timestamp
    @transaction_id = transaction_id
    @user_id = user_id
    @amount = amount
  end

  def self.parse(str)
    timestamp, transaction_id, user_id, amount = str.split(',')
    return nil if [timestamp, transaction_id, user_id, amount].any?(nil)

    new(timestamp: timestamp, transaction_id: transaction_id, user_id: user_id, amount: amount.to_f)
  end

  def to_s
    [timestamp, transaction_id, user_id, amount].join(',').to_s
  end

  def <=>(other)
    amount <=> other.amount
  end
end
