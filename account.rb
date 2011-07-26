class Account    
  class CreditTransaction
    
    attr_reader :date
    
    def initialize(amount, date)
      @amount, @date = amount, date
    end
    
    def process(balance)
      balance - @amount
    end
    
  end  
  
  class InterestTransaction
    
    attr_reader :date
    
    def initialize(interest_rate, date)
      @interest_rate, @date = interest_rate, date
    end
    
    def process(balance)
      balance + (balance * @interest_rate)
    end
  end
  
  MINIMUM_PAYMENT_PERCENT = 0.03
  
  def initialize(limit, interest_rate, opening_date)
    @limit, @previous_balance = limit, 0
    @interest_rate = interest_rate / 100.0
    @previously_called = opening_date 
    @transactions = []   
  end
  
  def debit(debit, date)
    raise if balance(date) + debit > @limit
    credit(-debit, date)
  end
  
  def balance(date)
    charge_interest(date)
    @transactions.inject(0) { |balance, t| t.process(balance) } 
  end
  
  def credit(credit, date)
    @transactions << CreditTransaction.new(credit, date) 
    charge_interest(date)
  end

  
  def revert_debit(amount, date)
    credit(amount, date)
  end
  
  def minimum_payment(date)
    return 0 if balance(date) <= 0
    minimum_payment = balance(date) * MINIMUM_PAYMENT_PERCENT
    minimum_payment > 5 ? minimum_payment : 5
  end
  
  def monthly_payment(payment, date)
    credit(payment, date)
  end
  
  private
    def accrue(date)
      @transactions << InterestTransaction.new(@interest_rate, date) 
    end
    
    def charge_interest(date)
      previously_called = @previously_called
      while previously_called <= date.first_of_month do
        break if previously_called.month == date.month && previously_called.year == date.year
        accrue(previously_called.next_month)
        previously_called = previously_called.next_month
      end
      @previously_called = date
    end
end

class Time
  
  def first_of_month
    Time.local(self.year, self.month, 1)
  end
  
  def next_month
    self.month == 12 ? Time.local(self.year + 1, 1, 1) : Time.local(self.year, self.month + 1, 1)
  end
  
  
end