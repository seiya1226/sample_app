require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup #準備
   @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do #有効
    assert @user.valid? #テスト
  end

  test "name should be present" do #有効ではない
    @user.name = ""
    assert_not @user.valid?
  end

  test "email should be present" do #有効でない値があったらエラー
    @user.email = "     "
    assert_not @user.valid?
  end
  
  test "name should not be too long" do #文字数が多いとエラー
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do #文字数が多いとエラー
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end
  
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org 
                         first.last@foo.jp alice+bob@baz.cn] #配列
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end
  
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end
  
  test "email addresses should be unique" do #重複しないよう
    duplicate_user = @user.dup #dup同じものを作る
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end
  
   test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end
  
   test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
  
  test "" do
   @user.password = @user.password_confirmation = "a" * 6
   @user.save
    assert_not_equal @user.password, @user.reload.password_digest
  end
  
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end
  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end
end
