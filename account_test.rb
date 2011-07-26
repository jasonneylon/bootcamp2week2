require "test/unit"

require "account"

class TimeTest < Test::Unit::TestCase
  
  def test_next_month
    assert_equal Time.local(2002, 1, 1),  Time.local(2001, 12, 12).next_month
  end
  
end

class AccountTest < Test::Unit::TestCase
  def setup
    @acc = Account.new(20000, 1, Time.local(2011,1,1))
  end
  
  def test_account_charge    
    @acc.debit(5000, Time.local(2011,1,1))
    assert_raise(RuntimeError) { @acc.debit(16000, Time.local(2011,1,3)) }
    @acc.credit(400, Time.local(2011,1,4))
    assert_equal 4600, @acc.balance(Time.local(2011,1,5))
  end
  
  def test_accrue_interest
    @acc.debit(20000, Time.local(2011,1,1))
    @acc.monthly_payment(10000, Time.local(2011,1,2))
    assert_equal 10000, @acc.balance(Time.local(2011,1,3))
  end
  
  def test_minimum_payment
    @acc.debit(1000, Time.local(2011,1,1))
    assert_equal 30, @acc.minimum_payment(Time.local(2011,1,1))
  end      
   
  def test_interest_charging
    @acc.debit(5000, Time.local(2010,1,31))
    assert_equal 5100.5, @acc.balance(Time.local(2010,3,28))
    assert_in_delta(5690.4664, @acc.balance(Time.local(2011,2,28)), 0.0001)
  end  
  
  def test_remove_transaction
    @acc.debit(5000, Time.local(2011, 1,31))
    @acc.debit(4950, Time.local(2011,2,2))
    assert_equal 9950 + 50, @acc.balance(Time.local(2011, 2,2))
    
    @acc.credit(5000, Time.local(2011,2,3))
    assert_equal 5000, @acc.balance(Time.local(2011,2,3))
    
    @acc.revert_debit(4950, Time.local(2011,2,2))
    assert_equal 50, @acc.balance(Time.local(2011,2, 3))
    
    @acc.debit(50, Time.local(2011,3,1))
    assert_equal 50 + 0.50 + 50, @acc.balance(Time.local(2011,3,6))
  end
end
