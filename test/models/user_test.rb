require 'test_helper'

class UserTest < ActiveSupport::TestCase
  EMAIL = 'test@gmail.com'
  USERNAME = 'testuser'
  PASSWORD = 'Valid#123'

  def setup
    @user = User.new(
      email: EMAIL,
      username: USERNAME,
      password: PASSWORD,
      password_confirmation: PASSWORD
    )
  end

  test 'should be valid with valid attributes' do
    assert @user.valid?
  end

  test 'should require email' do
    @user.email = ''
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test 'should reject invalid email formats' do
  invalid_emails = ['missingdomain', '@missingusername.com', 'username@.com', 'username@.com.', 'username@domain..com']
    invalid_emails.each do |email|
      @user.email = email
      assert_not @user.valid?, "#{email.inspect} should be invalid"
      assert_includes @user.errors[:email], 'must be a valid email address'
    end
  end

  test 'should require username' do
    @user.username = ''
    assert_not @user.valid?
    assert_includes @user.errors[:username], "can't be blank"
  end

  test 'should reject invalid username format' do
    @user.username = 'Invalid Username!'
    assert_not @user.valid?
  end

  test 'should enforce password complexity' do
    @user.password = @user.password_confirmation = 'simple'
    assert_not @user.valid?
    assert_includes @user.errors[:password],
                    'Password must include: 1 uppercase letter, 1 lowercase letter, 1 digit, and 1 special character (#?!@$%^&*-)'
  end

  test 'login should return username by default' do
    assert_equal USERNAME, @user.login
  end

  test 'default_name returns display_name if present' do
    @user.display_name = 'Test User'
    assert_equal 'Test User', @user.default_name
  end

  test 'default_name returns username when display_name is blank' do
    @user.display_name = ''
    assert_equal USERNAME, @user.default_name
  end

  test 'first_name returns first word of display_name' do
    @user.display_name = 'Test User'
    assert_equal 'Test', @user.first_name
  end

  test 'first_name returns username when display_name is blank' do
    @user.display_name = ''
    assert_equal USERNAME, @user.first_name
  end

  test 'should reject disposable email addresses' do
    @user.email = 'user@example.com'
    assert_not @user.valid?
    assert_includes @user.errors[:email], 'is a disposable email address and cannot be used.'
  end

  # Test uniqueness of email
  test 'should enforce unique email' do
    @user.save!
    duplicate_user = @user.dup
    duplicate_user.username = 'anotheruser'
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email], 'has already been taken'
  end

  # Test uniqueness of username
  test 'should enforce unique username' do
    @user.save!
    duplicate_user = @user.dup
    duplicate_user.email = 'another@example.com'
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:username], 'has already been taken'
  end

  # Test username length validation
  test 'username should not be too short' do
    @user.username = 'a'
    assert_not @user.valid?
    assert_includes @user.errors[:username], 'is too short (minimum is 3 characters)'
  end

  test 'username should not be too long' do
    @user.username = 'a' * 51
    assert_not @user.valid?
    assert_includes @user.errors[:username], 'is too long (maximum is 50 characters)'
  end

  # Test email length validation
  test 'email should not be too long' do
    @user.email = 'a' * 244 + '@example.com'
    assert_not @user.valid?
    assert_includes @user.errors[:email], 'is too long (maximum is 255 characters)'
  end

  # Test password length validation
  test 'password should be at least 6 characters long' do
    @user.password = @user.password_confirmation = 'short'
    assert_not @user.valid?
    assert_includes @user.errors[:password], 'is too short (minimum is 6 characters)'
  end

  test 'password should not be too long' do
    @user.password = @user.password_confirmation = 'a' * 129
    assert_not @user.valid?
    assert_includes @user.errors[:password], 'is too long (maximum is 128 characters)'
  end

  # Test password confirmation mismatch
  test 'should reject mismatched password confirmation' do
    @user.password_confirmation = 'Mismatch#123'
    assert_not @user.valid?
    assert_includes @user.errors[:password_confirmation], "doesn't match Password"
  end

  # Test email case normalization
  test 'email should be saved as lowercase' do
    mixed_case_email = 'Foo@GmAiL.CoM'
    @user.email = mixed_case_email
    @user.save!
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  # Test username case normalization
  test 'username should be saved as lowercase' do
    mixed_case_username = 'TestUser'
    @user.username = mixed_case_username
    @user.save!
    assert_equal mixed_case_username.downcase, @user.reload.username
  end
end
