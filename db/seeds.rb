require "faker"


User.create!([
  { :name => "Uwe Zimmer", :uni_id => 4037267 }
  ])

`rm -rf upload/*`
`mkdir upload/comment_related_files`

uwe = User.find_by_name("Uwe Zimmer")

comp1100 = Course.new(:name => "Comp1100")
comp1100.convener = uwe
comp1100.save!

comp1130 = Course.new(:name => "Comp1130")
comp1130.convener = uwe
comp1130.save!

labs = GroupType.create!(:name => "Comp1100/1130 labs",
                         :courses => [comp1130, comp1100])

wireworld_description = "<p>Cellular automata!</p>"+ Faker::Lorem.paragraphs.map{|x| "<p>#{x}</p>"}.join("\n")

wireworld = Assignment.create!(:name => "Wireworld",
                               :info => wireworld_description,
                               :group_type => labs,
                               :due_date => "2014-05-03 23:04:26",
                               :behavior_on_submission => '{"check compiling haskell": []}')

wireworld.create_marking_scheme([{:name => "Style",
                                  :description => "how good the code is",
                                  :maximum_mark => 30},
                                  {:name => "Correctness",
                                  :description => "how correct the code is",
                                  :maximum_mark => 30}])

kalaha = Assignment.create!(:name => "Kalaha",
                             :info => "board game!",
                             :group_type => labs,
                             :due_date => "2014-03-33 23:04:26",
                             :submission_format => "zipfile")

tutors =  [ { :name => "Buck Shlegeris", :uni_id => 5192430 },
  { :name => "Frank Zhao", :uni_id => 5180967 },
  { :name => "Ivan Miljenovic", :uni_id => 4800393 },
  { :name => "Malcolm Macdonald", :uni_id => 9606423 },
  { :name => "Matt Alger", :uni_id => 5365162 },
  { :name => "Probie", :uni_id => 4849459 },
  { :name => "Vaibhav (V) Sagar", :uni_id => 4729291 }]


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

tutors.each do |tutor|
  tutor = User.create!(tutor)
  tutor.enroll_staff_in_course!(comp1100)
  tutor.enroll_staff_in_course!(comp1130)
  lab = labs.create_groups("#{tutor.name}'s lab" => [tutor])[0]
  1.times do
    [comp1100, comp1130].each do |course|
      name, id = people.pop
      p name, id
      user = User.create!({ :name => name, :uni_id => id })

      user.enroll_in_course!(course)
      user.join_group!(lab)

      AssignmentSubmission.create!(:user_id => user.id,
                              :body => "-- btw I'm bad at Haskell\nmain = error \"first unimplemented\"",
                              :assignment_id => wireworld.id)
    end
  end
end


