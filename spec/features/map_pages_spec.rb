require 'spec_helper'

describe "Map pages" do
  #raise page.body.to_yaml

  subject { page }

  describe "GET /maps" do
    context "empty database" do
      before(:each) do
        Map.delete_all
        visit maps_path
      end

      its(:status_code) { should eq 200}

    end

    context "populated database" do
      let!(:map) {FactoryGirl.create(:map)}
      before(:each) do
        visit maps_path
      end

      it { should have_link(map.name, href: map_path(map))}
      pending { should have_content(map.map_type.name)}
    end

    context "filtering" do
      before do
        FactoryGirl.create(:map_type, name: "King of the Hill", prefix: "koth")
        FactoryGirl.create(:map_type, name: "Control Point", prefix: "cp")
        FactoryGirl.create(:map, name: "cp_badlands")
        FactoryGirl.create(:map, name: "koth_badlands")
        FactoryGirl.create(:map, name: "koth_viaduct")
        visit maps_path
      end

      pending "by name" do
        fill_in "search", with: "bad"
        click_on "Search Maps"
        expect(page).to have_content("koth_badlands")
        expect(page).to_not have_content("koth_viaduct")
      end

      it "by map type" do
        #raise page.body.to_yaml
        click_on "King of the Hill"
        expect(page).to have_content("koth_badlands")
        expect(page).to_not have_content("cp_badlands")

      end
    end
  end #/maps

  describe "GET /maps/:id" do
    let!(:map) {FactoryGirl.create(:map)}

    before(:each) do
      visit "/maps/#{map.name}"
    end

    it { should have_content(map.name)}
    it { should have_content(map.map_type.name)}
    it { should have_content("All Comments (0)")}
    it { should have_content("You must be logged in to leave a comment")}

    it { should_not have_link("", href: vote_map_path(map, type: "up"))}
    it { should_not have_link("", href: vote_map_path(map, type: "down"))}
    it { should_not have_link("", href: edit_map_path(map))}
    #it { should_not have_selector()}

    context "with comments" do
      let!(:comment) {FactoryGirl.create(:map_comment, map: map)}
      before do
        visit map_path(map)
      end

      it { should have_content(comment.comment)}
      it { should have_content(comment.user.nickname)}

    end

    context "with up votes" do
      let!(:user) {FactoryGirl.create(:user, nickname: "Upvote McGee")}
      let!(:vote) {FactoryGirl.create(:vote, map: map, user: user, value: 1)}

      before do
        visit map_path(map)
      end

      it { should have_content(user.nickname)}
      it { should have_content("Liked by")}
      it { should have_selector('span.up-vote', text: '1')}
    end

    context "with down votes" do
      let!(:user) {FactoryGirl.create(:user, nickname: "Map hater")}
      let!(:vote) {FactoryGirl.create(:vote, map: map, user: user, value: -1)}

      before do
        visit map_path(map)
      end

      it { should have_content(user.nickname)}
      it { should have_content("Hated by")}
      it { should have_selector('span.down-vote', text: '1')}
    end

    context "user logged in" do
      let!(:user) {FactoryGirl.create(:user)}
      before do
        login user
        visit map_path(map)
      end

      it "allows you to vote" do
        expect{click_on "like it" }.to change{Vote.count}.by(1)
        expect{click_on "hate it" }.to_not change{Vote.count}
      end

      it "won't let you enter blank comments" do
        click_on "Post Comment"
        expect(page).to have_content("Could not add comment")
      end

      it "allows you to enter comments" do
        fill_in "map_comment_comment", with: "This is a test comment"
        click_on "Post Comment"
        expect(page).to have_content("This is a test comment")
        expect(page).to have_content(map.name)
      end

      it "allows you to delete comments" do
        fill_in "map_comment_comment", with: "This is a test comment"
        click_on "Post Comment"
        click_on "Delete"
        expect(page).to_not have_content("This is a test")
      end

      pending "won't let you rapidly enter comments" do
        fill_in "map_comment_comment", with: "This is a test comment"
        click_on "Post Comment"
        fill_in "map_comment_comment", with: "Another comment"
        click_on "Post Comment"
        expect(page).to have_content(map.name)
        expect(page).to have_content("This is a test comment")
        expect(page).to_not have_content("Another comment")
        expect(page).to have_content("Can not add another comment so soon")

      end

    end
  end#/maps/:id
end
