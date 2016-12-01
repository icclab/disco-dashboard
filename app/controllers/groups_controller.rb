class GroupsController < ApplicationController
  before_action :logged_in_user

  def index
    @groups = current_user.groups.all
  end

  def show

  end

  def new

  end

  def create

  end

  def destroy

  end

  private
    def group_params

    end
end
