class Account  
  Transaction = Struct.new(:date, :fun)
  
  
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
    @transactions.map(&:fun).inject(0) { |balance, fun| balance + fun.call(balance) } 
  end
  
  def credit(credit, date)
    add_transaction(date) {|balance| return -credit }
    charge_interest(date)
  end

  
  def revert(amount, date)
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
      add_transaction(date) {|balance| balance * @interest_rate }
    end
    
    def add_transaction(date, &fun)
      @transactions << Transaction.new(date, lambda(&fun))
    end

    def charge_interest(date)
      while @previously_called < date do
        break if @previously_called.month == date.month && @previously_called.year == date.year
        accrue(@previously_called.next_month)
        @previously_called = @previously_called.next_month
      end
      @previously_called = date
    end
end

class Time
  
  def next_month
    next_month = self.month == 12 ? 1 : self.month + 1
    year = self.month == 12 ? self.year + 1 : self.year
    Time.local(year, next_month, 1)
  end
  
  
end