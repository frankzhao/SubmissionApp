require 'spec_helper'

describe User do
  it "lets you create by CSV" do
    User.delete_all
    User.create_by_csv!("name,uni id\nBuck,1234\nUwe,6543")
    expect(User.all.map{|user| [user.name, user.uni_id]}).to(
               eq([["Buck", 1234], ["Uwe", 6543]]))
  end

  describe "person who hasn't joined anything" do

    before(:each) do
      User.delete_all
      User.create!(:name => "Buck", :uni_id => "1234")
    end

    it "doesn't say that they're a convener or admin" do
      buck = User.first
      expect(buck.is_convener?).to eq(false)
      expect(buck.is_admin_or_convener?).to eq(false)
    end

    it "doesn't say they've joined any courses" do
      buck = User.first
      expect(buck.courses).to eq([])
    end
  end

  describe "convener" do
    it "knows what courses they convene" do
      uwe = User.create(:name => "Uwe", :uni_id => "1234")
      comp1100 = Course.new(:name => "Comp1100")
      comp1100.convener = uwe
      comp1100.save!

      expect(uwe.convened_courses).to eq([comp1100])
    end
  end

  describe "methods: " do
    describe "touch" do
      it "creates users" do
        User.touch("Buck", 12345)
        expect(User.first.name).to eq("Buck")
        expect(User.first.uni_id).to eq(12345)
      end
    end

    describe "touch" do
      it "creates users" do
        User.touch("Buck", 12345)
        expect(User.first.name).to eq("Buck")
        expect(User.first.uni_id).to eq(12345)
      end

      it "doesn't create users if they exist" do
        u = User.touch("Buck", 12345)
        v = User.touch("Buck", 12345)
        expect(v.name).to eq("Buck")
        expect(v.uni_id).to eq(12345)
        expect(User.all.length).to eq(1)
      end
    end

    describe "is_convener?" do
      it "knows that randoms aren't conveners" do
        u = User.create!(:name => "Buck", :uni_id => 12345)
        expect(u.is_convener?).to eq(false)
      end

      it "knows that conveners are conveners" do
        u = User.create!(:name => "Buck", :uni_id => 12345)
        c = Course.create!(:name => "comp1104", :convener_id => u.id)
        expect(u.is_convener?).to eq(true)
      end
    end

    describe "is_admin_or_convener?" do
      [true, false].each do |is_admin|
        $is_admin = is_admin
        [true, false].each do |is_convener|
          $is_convener = is_convener
          it "works when is_admin is #{$is_admin} and is_convener is #{$is_convener}" do
            u = User.create!(:name => "Buck", :uni_id => 12345)
            u.is_admin = true if $is_admin
            c = Course.create(:name => "comp1100", :convener_id => u.id) if $is_convener
            p u.is_admin_or_convener?, $is_admin || $is_convener
            expect(u.is_admin_or_convener?).to eq($is_admim || $is_convener)
          end
        end
      end
    end

    describe "join_group!" do
      it "makes users join groups" do
        u = User.create!(:name => "Buck", :uni_id => 12345)
      end
    end
  end
end