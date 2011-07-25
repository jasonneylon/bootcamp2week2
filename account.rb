class Account  
  MINIMUM_PAYMENT_PERCENT = 0.03
  
  def initialize(limit, interest_rate, opening_date)
    @limit, @balance, @previous_balance = limit, 0, 0
    @interest_rate = 1 + interest_rate / 100.0
    @previously_called = opening_date    
  end
  
  def debit(debit, date)
    raise if @balance + debit > @limit
    credit(-debit, date)
  end
  
  def balance(date)
    charge_interest(date)
    @balance
  end
  
  def credit(credit, date)
    @balance -= credit
    charge_interest(date)
  end
  
  def minimum_payment
    return 0 if @balance <= 0
    minimum_payment = @balance * MINIMUM_PAYMENT_PERCENT
    minimum_payment > 5 ? minimum_payment : 5
  end
  
  def monthly_payment(payment, date)
    credit(payment, date)
    accrue
  end

  private
    def accrue
      @previous_balance = @balance
      @balance = (@balance - @previous_balance) + (@previous_balance * @interest_rate)
    end
  
    def charge_interest(date)
      months = date.months_difference(@previously_called)
      return if months <= 0
      @previously_called = date
      months.times { accrue }
    end
end

class Time
  def months_difference(other)
    months_passed = (self.month - other.month) + 12 * (self.year - other.year)
  end
end