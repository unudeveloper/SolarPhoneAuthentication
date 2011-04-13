require 'spec_helper'

describe Clearance::PasswordsController do

  include Shoulda::ActionMailer::Matchers

  it { should route(:get, '/users/1/password/edit').
                to(:controller => 'clearance/passwords', :action  => 'edit', :user_id => '1') }

  describe "a signed up user" do
    before do
      @user = Factory(:user)
    end

    describe "on GET to #new" do
      before { get :new, :user_id => @user.to_param }

      it { should respond_with(:success) }
      it { should render_template(:new) }
    end

    describe "on POST to #create" do
      describe "with correct email address" do
        before do
          ActionMailer::Base.deliveries.clear
          post :create, :password => { :email => @user.email }
        end

        it "should generate a token for the change your password email" do
          @user.reload.confirmation_token.should_not be_nil
        end

        it { should have_sent_email.with_subject(/change your password/i) }

        it { should set_the_flash.to(/password/i) }
        it { should redirect_to_url_after_create }
      end

      describe "with incorrect email address" do
        before do
          email = "user1@example.com"
          (::User.exists?(['email = ?', email])).should_not be
          ActionMailer::Base.deliveries.clear
          @user.reload.confirmation_token.should == @user.confirmation_token

          post :create, :password => { :email => email }
        end

        it "should not generate a token for the change your password email" do
          @user.reload.confirmation_token.should == @user.confirmation_token
        end

        it "should not send a password reminder email" do
          ActionMailer::Base.deliveries.should be_empty
        end

        it "should set the failure flash to Unknown email" do
          flash.now[:failure].should =~ /unknown email/i
        end

        it { should render_template(:new) }
      end
    end
  end

  describe "a signed up user and forgotten password" do
    before do
      @user = Factory(:user)
      @user.forgot_password!
    end

    describe "on GET to #edit with correct id and token" do
      before do
        get :edit, :user_id => @user.to_param,
                   :token   => @user.confirmation_token
      end

      it "should find the user" do
        assigns(:user).should == @user
      end

      it { should respond_with(:success) }
      it { should render_template(:edit) }
    end

    describe "on GET to #edit with correct id but blank token" do
      before do
        get :edit, :user_id => @user.to_param, :token => ""
      end

      it { should set_the_flash.to(/double check the URL/i) }
      it { should render_template(:new) }
    end

    describe "on GET to #edit with correct id but no token" do
      before do
        get :edit, :user_id => @user.to_param
      end

      it { should set_the_flash.to(/double check the URL/i) }
      it { should render_template(:new) }
    end

    describe "on PUT to #update with matching password and password confirmation" do
      before do
        new_password = "new_password"
        @encrypted_new_password = @user.send(:encrypt, new_password)
        @user.encrypted_password.should_not == @encrypted_new_password

        put(:update,
            :user_id  => @user,
            :token    => @user.confirmation_token,
            :user     => {
              :password              => new_password,
              :password_confirmation => new_password
            })
        @user.reload
      end

      it "should update password" do
        @user.encrypted_password.should == @encrypted_new_password
      end

      it "should clear confirmation token" do
        @user.confirmation_token.should be_nil
      end

      it "should set remember token" do
        @user.remember_token.should_not be_nil
      end

      it { should set_the_flash.to(/signed in/i) }
      it { should redirect_to_url_after_update }
    end

    describe "on PUT to #update with password but blank password confirmation" do
      before do
        new_password = "new_password"
        @encrypted_new_password = @user.send(:encrypt, new_password)

        put(:update,
            :user_id => @user.to_param,
            :token   => @user.confirmation_token,
            :user    => {
              :password => new_password,
              :password_confirmation => ''
            })
        @user.reload
      end

      it "should not update password" do
        @user.encrypted_password.should_not == @encrypted_new_password
      end

      it "should not clear token" do
        @user.confirmation_token.should_not be_nil
      end

      it "should not be signed in" do
        cookies[:remember_token].should be_nil
      end

      it { should_not set_the_flash }
      it { should respond_with(:success) }
      it { should render_template(:edit) }
    end
  end

  describe "given two users and user one signs in" do
    before do
      @user_one = Factory(:user)
      @user_two = Factory(:user)
      sign_in_as @user_one
    end
  end

end
