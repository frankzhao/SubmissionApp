require "faker"


User.create!([
  { :name => "Uwe Zimmer", :uni_id => 2222222 },
  { :name => "Buck Shlegeris", :uni_id => 5192430 },
  { :name => "Tessa Bradbury", :uni_id => 3333333 },
  { :name => "Eric McCreath", :uni_id => 4444444 },
  { :name => "James Fellows", :uni_id => 1234567 }
  ])



uwe = User.find_by_name("Uwe Zimmer")

james = User.find_by_name("James Fellows")
james.is_admin = true
james.save!

comp1100 = Course.new(:name => "Comp1100")
comp1100.convener = uwe
comp1100.save!

comp1130 = Course.new(:name => "Comp1130")
comp1130.convener = uwe
comp1130.save!

eric = User.find_by_name("Eric McCreath")
comp2300 = Course.new(:name => "Comp2300")
comp2300.convener = eric
comp2300.save!

buck = User.find_by_name("Buck Shlegeris")
buck.enroll_staff_in_course!(comp1100)
buck.enroll_staff_in_course!(comp1130)

tessa = User.find_by_name("Tessa Bradbury")
tessa.enroll_staff_in_course!(comp1100)
tessa.enroll_staff_in_course!(comp1130)

tute = GroupType.create!(:name => "Comp1100/1130 labs",
                         :courses => [comp1130, comp1100])

wireworld_description = "<p>Cellular automata!</p>"+ Faker::Lorem.paragraphs.map{|x| "<p>#{x}</p>"}.join("\n")

wireworld = Assignment.create!(:name => "Wireworld",
                               :info => wireworld_description,
                               :group_type => tute,
                               :due_date => "2014-05-03 23:04:26",
                               :behavior_on_submission => "check_compiling_haskell")

wireworld.create_marking_scheme([{:name => "Style",
                                  :description => "how good the code is",
                                  :maximum_mark => 30},
                                  {:name => "Correctness",
                                  :description => "how correct the code is",
                                  :maximum_mark => 30}])

kalaha = Assignment.create!(:name => "Kalaha",
                             :info => "board game!",
                             :group_type => tute,
                             :due_date => "2014-03-33 23:04:26",
                             :submission_format => "zipfile")

buck_tute, tessa_tute = tute.create_groups("Thursday A"=>[buck],
                                      "Thursday B"=>[tessa])

people = [['Michele Hirthe',5689215],
          ['Etha Medhurst',5167449],
          ['Julius Casper',5544508],
          ['Lessie Beier',4597441],
          ['Sylvia Kutch',5292181],
          ['Joanne Stanton',4957443],
          ['Daren Wolf',5972951],
          ['Jasen Schroeder',4625564],
          ['Rafaela Parisian',4643300],
          ['Emma Maggio',5671846],
          ['Martin Kris',4919654],
          ['Elvis Block',5228817],
          ['Christine Powlowski',4292920],
          ['Sammy Mueller',4648373],
          ['Leslie Bednar',4950106],
          ['Justice Rogahn',5930905],
          ['Toni Kuvalis',5440690],
          ['Garnet Thompson',4365727],
          ['Lindsey Kautzer',5438481],
          ['Osvaldo Spinka',4424755],
          ['Elisabeth Volkman',4704255],
          ["Dolly O'Keefe",4989649],
          ['Hoyt Williamson',5555554],
          ['Demarcus Johns',5555553],
          ['Brooks Kris',5555552],
          ['Katelyn Collier',5555551]]


[buck_tute, tessa_tute].each do |tute|
  [comp1100, comp1130].each do |course|
    5.times do |time|
      name, id = people.pop
      user = User.create!({ :name => name, :uni_id => id })

      user.enroll_in_course!(course)
      user.join_group!(tute)
    end
  end
end

5.times do |time|
  name, id = people.pop
  user = User.create!({ :name => name, :uni_id => id })
  user.enroll_in_course!(comp2300)
end

10.times do |time|
  p time
  name, id = "student#{time}", time
  user = User.create!({ :name => name, :uni_id => id })
  user.enroll_in_course!(comp1100)
  user.join_group!(buck_tute)
  AssignmentSubmission.create!(:user_id => user.id,
                              :body => "main = error \"first unimplemented\"",
                              :assignment_id => wireworld.id)
end

sub1 = AssignmentSubmission.create!(:user_id => buck_tute.students[0].id,
                              :body => "main = error \"first unimplemented\"",
                              :assignment_id => wireworld.id)

sub2 = AssignmentSubmission.create!(:user_id => buck_tute.students[1].id,
                              :body => "main = error \"unimplemented\"",
                              :assignment_id => wireworld.id)
