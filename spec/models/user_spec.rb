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

end