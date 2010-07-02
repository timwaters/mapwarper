class RolesController < ApplicationController
   layout 'application'
   before_filter :check_super_user_role

   def index
      @user = User.find(params[:user_id])
      @all_roles = Role.find(:all)
   end

   def update
      @user = User.find(params[:user_id])
      @role = Role.find(params[:id])
      unless @user.has_role?(@role.name)
         @user.roles << @role
      end
      redirect_to :action => 'index'
   end

   def destroy
      @user = User.find(params[:user_id])
      @role = Role.find(params[:id])
      if @user.has_role?(@role.name)
         @user.roles.delete(@role)
         redirect_to :action => 'index'
      else
         redirect_to :action => 'index'
      end

   end
   
   end
