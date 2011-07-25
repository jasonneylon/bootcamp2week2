require "test/unit"

require "account"

class TestLibraryFileName < Test::Unit::TestCase
  def setup
    @acc = Account.new(20000, 1, Time.local(2011,1,31))
  end
  
  def test_account_charge
    
    @acc.debit(5000, Time.local(2011,1,1))
    assert_raise(RuntimeError) { @acc.debit(16000, Time.local(2011,1,1)) }
    @acc.credit(400, Time.local(2011,1,1))
    assert_equal 4600, @acc.balance(Time.local(2011,1,1))
  end
  
  def test_accrue_interest
    @acc.debit(20000, Time.local(2011,1,1))
    @acc.monthly_payment(10000, Time.local(2011,1,1))
    assert_equal 10100, @acc.balance(Time.local(2011,1,1))
  end
  
  def test_minimum_payment
    @acc.debit(1000, Time.local(2011,1,1))
    assert_equal 30, @acc.minimum_payment
  end      
   
  def test_interest_charging
    @acc.debit(5000, Time.local(2011,1,31))
    assert_equal 5050, @acc.balance(Time.local(2011,2,28))
    assert_equal 5100.5, @acc.balance(Time.local(2011,3,31))
  end  
end
