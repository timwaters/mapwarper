class MembershipsController < ApplicationController
  before_filter :find_group
  before_filter :login_required

  def new
    membership =  @group.memberships.new(:user => current_user)
    if membership.save
      flash[:notice] = "Added to group!"
    else
      flash[:notice] = membership.errors.on(:user_id)
    end
    redirect_to group_path(@group)
  end

  def destroy
    membership = @group.memberships.find_by_user_id(params[:id])
    if membership.destroy
      flash[:notice] = "You have left the group"
    else
      flash[:notice] = "Couldn't leave group for some reason."
    end

    redirect_to group_path(@group)
  end


  protected

  def find_group
    @group = Group.find(params[:group_id])
  end

end
