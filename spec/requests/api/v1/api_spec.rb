require "spec_helper"

shared_examples_for "ApiController" do |route,params|
  context "without access_token" do
    before {post route, params}
    its(:code) { should eql("403")}
  end
  context "with invalid access_token" do
    before do
      ApiKey.delete_all
      post route, params.merge({access_token: "badtoken"})
    end
    its(:code) { should eql("403")}
  end

  context "with valid access_token" do
    let!(:api_key) {FactoryGirl.create(:api_key)}
    params.each_key do |key|
      it "should complain about missing #{key}" do
        post route, params.except(key).merge({access_token: api_key.access_token})
        expect(response).to be_bad_request
      end
    end

    it "should pass" do
      post route, params.merge({access_token: api_key.access_token})
      expect(response).to be_success
    end
  end
end

share_examples_for "map query" do |route, params|
  let!(:api_key) {FactoryGirl.create(:api_key)}
  it "adds new maps if they do not exist in the database" do
    expect do
      post route, params.merge({access_token: api_key.access_token})
    end.to change{Map.count}.by(1)
  end
end

describe "POST /v1/api" do
  subject { response }

  describe "/cast_vote" do
    let!(:user) {FactoryGirl.create(:user, provider: "steam", uid: "123456")}
    let!(:map) {FactoryGirl.create(:map)}
    route = "/v1/api/cast_vote"

    it_should_behave_like "ApiController", route, {
      uid: "123456",
      map: "auto_map",
      value: 1
    }
    it_should_behave_like "map query", route, {
      uid: "123456",
      map: "auto_map",
      value: 1
    }

    context "with valid access_token" do
      let!(:api_key) {FactoryGirl.create(:api_key)}

      it "casts a vote with valid information" do
        expect do
          post route,
            access_token: api_key.access_token,
            uid: user.uid,
            map: map.name,
            value: 1
        end.to change{Vote.count}.by(1)
      end
      it "does not cast a vote with invalid value" do
        expect do
          post route,
            access_token: api_key.access_token,
            uid: user.uid,
            map: map.name,
            value: 292
        end.to raise_error(ActiveRecord::RecordInvalid)
      end

    end

  end

  describe "/write_message" do
    let!(:user) {FactoryGirl.create(:user, provider: "steam", uid: "123456")}
    let!(:map) {FactoryGirl.create(:map)}
    route = "/v1/api/write_message"

    it_should_behave_like "ApiController", route, {
      uid: "123456",
      map: "auto_map",
      comment: "Comment"
    }
    it_should_behave_like "map query", route, {
      uid: "123456",
      map: "New_Map",
      comment: "Comment"
    }

    context "with valid access_token" do
      let!(:api_key) {FactoryGirl.create(:api_key)}

      it "writes a comment" do
        expect do
          post route,
            access_token: api_key.access_token,
            uid: user.uid,
            map: map.name,
            comment: "Comment"
        end.to change{MapComment.count}.by(1)
      end

      it "adds new maps if they do not exist in the database" do
        expect do
          post route,
            access_token: api_key.access_token,
            uid: user.uid,
            map: "New_Map",
            comment: "Comment"
        end.to change{Map.count}.by(1)
      end

      it "Can read and convert a base64 url safe comment" do
        post route,
          access_token: api_key.access_token,
          uid: user.uid,
          map: map.name,
          base64: 1,
          comment: "QmFzZTY0RW5jb2RlZE1lc3NhZ2U="
        expect(MapComment.last.comment).to eql("Base64EncodedMessage")
      end

    end

  end

  describe "/favorite" do
    route = "/v1/api/favorite"

    let!(:user) {FactoryGirl.create(:user, provider: "steam", uid: "123456")}
    let!(:map) {FactoryGirl.create(:map)}

    it_should_behave_like "ApiController", route, {
      uid: "123456",
      map: "auto_map"
    }
    it_should_behave_like "map query", route, {
      uid: "123456",
      map: "New_Map"
    }
    context "with valid access_token" do
      let!(:api_key) {FactoryGirl.create(:api_key)}

      it "adds map to user's favorites" do
        expect do
          post route,
            access_token: api_key.access_token,
            uid: user.uid,
            map: map.name
        end.to change{MapFavorite.count}.from(0).to(1)
      end

      it "does nothing if map is already favorited" do
        FactoryGirl.create(:map_favorite, user: user, map: map)
        expect do
          post route,
            access_token: api_key.access_token,
            uid: user.uid,
            map: map.name
        end.to_not change{MapFavorite.count}
      end
    end

  end
  pending "/unfavorite" do
    route = "/v1/api/unfavorite"

    let!(:user) {FactoryGirl.create(:user, provider: "steam", uid: "123456")}
    let!(:map) {FactoryGirl.create(:map)}

    it_should_behave_like "ApiController", route, {
      uid: "123456",
      map: "auto_map"
    }
    it_should_behave_like "map query", route, {
      uid: "123456",
      map: "New_Map"
    }
    context "with valid access_token" do
      let!(:api_key) {FactoryGirl.create(:api_key)}

      it "removes map from user's favorites" do
        FactoryGirl.create(:map_favorite, user: user, map: map)
        expect do
          post route,
            access_token: api_key.access_token,
            uid: user.uid,
            map: map.name
        end.to change{MapFavorite.count}.from(1).to(0)
      end

      it "does nothing if map is not favorited" do
        expect do
          post route,
            access_token: api_key.access_token,
            uid: user.uid,
            map: map.name
        end.to_not change{MapFavorite.count}
      end
    end

  end
  pending "/have_not_voted" do
    route = "/v1/api/have_not_voted"
    let!(:user1) {FactoryGirl.create(:user, provider: "steam", uid: "123456")}
    let!(:user2) {FactoryGirl.create(:user, provider: "steam", uid: "223456")}
    let!(:user3) {FactoryGirl.create(:user, provider: "steam", uid: "323456")}
    let!(:map) {FactoryGirl.create(:map)}
    let!(:other_map) {FactoryGirl.create(:map, name: "cp_other_map_b1")}

    before do
      FactoryGirl.create(:vote, user: user2, map: map, value:1)
      FactoryGirl.create(:vote, user: user2, map: other_map, value:1)
      FactoryGirl.create(:vote, user: user3, map: other_map, value:-1)
    end

    it_should_behave_like "ApiController", route, {
      uids: ["123456","223456","323456"],
      map: "auto_map",
      players: [7,2,22]
    }
    it_should_behave_like "map query", route, {
      uids: ["123456","223456","323456"],
      map: "New_Map",
      players: [7,2,22]
    }

    context "with valid access_token" do
      let!(:api_key) {FactoryGirl.create(:api_key)}

      it "returns players who have not voted on map" do
        expect do
          post route,
            access_token: api_key.access_token,
            uids: user.uid,
            map: map.name,
            comment: "Comment"
        end.to change{MapComment.count}.by(1)
      end
    end
  end

  describe "/server_query" do

  end

end
