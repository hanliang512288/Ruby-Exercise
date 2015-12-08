class SessionsController < ApplicationController
  def login
  end

  def staff
    
  end


  def admin

  end

  def login_attempt
  	authorized_user = User.authenticate(params[:username_or_email],params[:login_password])
  	
    if authorized_user
  		session[:user_id] = authorized_user.id
  		flash[:notice] = "Welcome, you logged in as #{authorized_user.username}"
  		redirect_to(:action => 'staff')
  	else
  		flash[:notice] = "Invalid Username or Password"
  		flash[:color] = "Invalid"
      # redirect_to(:action => 'staff')
  		render "login"
  	end
  end

  def logout
  	session[:user_id] = nil
  	redirect_to :action => 'login'
  end


end
