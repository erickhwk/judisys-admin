class ProfilesController < ApplicationController
  before_action :set_tenancies, only: %i[ new edit create update ]
  before_action :set_users, only: %i[ new edit create update ]
  before_action :set_profile, only: %i[ show edit update destroy ]
  before_action :not_authorized, only: %i[ new edit create update destroy ]
  before_action :available_roles_for_assignment, only: %i[ new edit create update ]

  # GET /profiles or /profiles.json
  def index
    case current_user.profile.role
    when 'developer'
      @profiles = Profile.all
    when 'admin'
      @profiles = Profile.where(tenancy_id: current_user.profile.tenancy_id)
    when 'member'
      if current_user.profile.tenancy_id.present?
        @profiles = Profile.where(tenancy_id: current_user.profile.tenancy_id)
      else
        @profiles = [current_user.profile]
      end
    end
  end

  # GET /profiles/1 or /profiles/1.json
  def show
  end

  # GET /profiles/new
  def new
    @profile = Profile.new
  end

  # GET /profiles/1/edit
  def edit
  end

  # POST /profiles or /profiles.json
  def create
    @profile = Profile.new(profile_params)

    respond_to do |format|
      if @profile.save
        format.html { redirect_to profiles_url, notice: "Profile was successfully created." }
        format.json { render :show, status: :created, location: @profile }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /profiles/1 or /profiles/1.json
  def update
    respond_to do |format|
      if @profile.update(profile_params)
        format.html { redirect_to profiles_url, notice: "Profile was successfully updated." }
        format.json { render :show, status: :ok, location: @profile }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /profiles/1 or /profiles/1.json
  def destroy
    @profile.destroy!

    respond_to do |format|
      format.html { redirect_to profiles_url, notice: "Profile was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def available_roles_for_assignment
      @roles = []
      Profile.roles.keys.each do |k|
        if current_user.profile.role == 'developer'
          @roles << k
        else
          if k != 'developer'
            @roles << k
          end
        end
      end
      @roles
    end

    def set_users
      if current_user.profile.role == 'developer'
        @users = User.all
      else
        @users = User.joins(:profile).where(profile: {tenancy_id: current_user.profile.tenancy_id })
      end 
    end

    def set_tenancies
      if current_user.profile.role == 'developer'
        @tenancies = Tenancy.all
      else
        @tenancies = Tenancy.find(current_user.profile.tenancy_id)
      end
    end

    def not_authorized
      redirect_to profiles_path, alert: "You are not authorized to perform this action" if params[:id].to_i != current_user.profile.id and current_user.profile.role == 'member'
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_profile
      @profile = Profile.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def profile_params
      params.require(:profile).permit(:user_id, :first_name, :last_name, :role, :tenancy_id)
    end
end
