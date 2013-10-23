require "base64"

module V1
  class ApiController < ApplicationController
    authorize_resource class: false
    before_filter :check_value, only: [:cast_vote]
    before_filter :check_comment, only: [:write_message]
    before_filter :find_or_create_user_and_map, only: [:cast_vote, :write_message]
    respond_to :json

    def cast_vote
      Vote.cast_vote @user, @map, @value
      head :created
    end

    def write_message
      MapComment.write_message @user, @map, @comment
      head :created
    end
    def server_query
      no_votes = User.where(uid: params["uids"]).where("users.id NOT IN (SELECT user_id from votes where map_id = ?)", params["map"]).map(&:uid)
      render json: no_votes
    end

    private
    def check_api_key
      api_key = ApiKey.authenticate(params[:access_token])
      head :unauthorized unless api_key
    end

    def find_or_create_user_and_map
      head :bad_request unless params["uid"] and params["map"]
      @user = User.find_by_provider_and_uid("steam", params["uid"]) || User.create_with_steam_id(params["uid"])
      @map = Map.find_or_create_by_name(params["map"])

    end

    def check_value
      @value = params["value"]
      head :bad_request unless @value
    end

    def check_comment
      @comment = params["comment"]
      if params["base64"]
        @comment = Base64.urlsafe_decode64 @comment
      end
      head :bad_request unless @comment
    end

  end
end
