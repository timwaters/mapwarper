require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.
include AuthenticatedTestHelper

describe User do
  fixtures :users
  setup do
    #stub mailer
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  describe 'being created' do
    before do
      @user = nil
      @creating_user = lambda do
        @user = create_user
        violated "#{@user.errors.full_messages.to_sentence}" if @user.new_record?
      end
    end
    
    it 'increments User#count' do
      @creating_user.should change(User, :count).by(1)
    end

    it 'initializes #activation_code' do
      @creating_user.call
      @user.reload
      @user.activation_code.should_not be_nil
    end
  end

  it 'requires login' do
    lambda do
      u = create_user(:login => nil)
      u.errors.on(:login).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires password' do
    lambda do
      u = create_user(:password => nil)
      u.errors.on(:password).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires password confirmation' do
    lambda do
      u = create_user(:password_confirmation => nil)
      u.errors.on(:password_confirmation).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires email' do
    lambda do
      u = create_user(:email => nil)
      u.errors.on(:email).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'resets password' do
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    User.authenticate('quentin@example.com', 'new password').should == users(:quentin)
  end

  it 'does not rehash password' do
    users(:quentin).update_attributes(:email => 'quentin2@example.com')
    User.authenticate('quentin2@example.com', 'test').should == users(:quentin)
  end

  it 'authenticates user' do
    RAILS_DEFAULT_LOGGER.debug(User.authenticate('quentin@example.com', 'test').inspect)
    RAILS_DEFAULT_LOGGER.debug("before")
    User.authenticate('quentin@example.com', 'test').should == users(:quentin)
     RAILS_DEFAULT_LOGGER.debug(users(:quentin))
  end

  it 'sets remember token' do
    users(:quentin).remember_me
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
  end

  it 'unsets remember token' do
    users(:quentin).remember_me
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).forget_me
    users(:quentin).remember_token.should be_nil
  end

  it 'remembers me for one week' do
    before = 1.week.from_now.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.should == time
  end

  it 'remembers me default two weeks' do
    before = 2.weeks.from_now.utc
    users(:quentin).remember_me
    after = 2.weeks.from_now.utc
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

protected
  def create_user(options = {})
    #record = User.new({ :login => 'quentin3', :email => 'quentin3@example.com', :password => 'test', :password_confirmation => 'test' }.merge(options))
     record = User.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))

    record.save
    record
  end
end
