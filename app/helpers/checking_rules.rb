# Every checking rule is passed a submission object and the arguments to the rule.
# For example, test_haskell might be passed a new submission and also the array
# ["reverse [1,2,3] == [3,2,1]", "reverse [] == []"]

module CheckingRules
  def check_files(submission, args)
    file_list = submission.all_zip_contents

    template = ERB.new(<<-TEXT)
      This submission should have the following files:
      <ul>
        <% args["required_files"].each do |file| %>
          <li>
            <%= file %>:
            <% if file_list.any? {|f| f =~ Regexp.new(file) } %>
              present
            <% else %>
              <b>not present</b>
            <% end %>
          </li>
        <% end %>
      </ul>

      <p>If those aren't here, maybe resubmit after rejigging your archive.</p>

      <p>The following files are optional: it's okay if you chose not to submit them.
      But if you did submit them, they should be here:</p>

      <ul>
        <% args["optional_files"].each do |file| %>
          <li>
            <%= file %>:
            <% if file_list.any? {|f| f =~ Regexp.new(file) } %>
              present
            <% else %>
              not present
            <% end %>
          </li>
        <% end %>
      </ul>
    TEXT

    Comment.create(:body => template.result(binding),
                   :submission_id => submission.id,
                   :custom_behavior_id => self.id)
  end

  def check_compiling_haskell(submission, args)
    if submission.assignment.submission_format == "plaintext"
      ans, errors = check_compiling_haskell_string(submission.body)
      if ans
        Comment.create(:body => "This code compiles!",
                   :assignment_submission_id => submission.id,
                   :custom_behavior_id => self.id)
      else
        Comment.create(:body =>
          "<strong>This code doesn't compile</strong>, with the following error:<br><code>
            <pre>#{errors}</pre></code>",
                  :assignment_submission_id => submission.id,
                  :custom_behavior_id => self.id)
      end
    else
      check_compiling_haskell_module(submission.zip_path)
    end
  end

  # TODO: this stuff should be more resilient against files named "temp"
  def check_compiling_haskell_string(text)
    logger.info("checking compiling haskell")
    root = Rails.root.to_s

    Dir.mkdir("#{root}/temp") unless Dir.exists? "#{root}/temp"
    File.open("#{root}/temp/temp.hs","w") { |f| f.write(text) }
    command_to_run = "ghc -XSafe #{root}/temp/temp.hs -i.:/dept/dcs/comp1100/supr/SubmissionApp/Library 2>&1"
    comments = `#{command_to_run}`
    logger.info("Running:\n#{command_to_run}")
    logger.info("Result:\n#{comments}")

    if comments.include?("The function `main' is not defined in module `Main'")
      File.open("#{root}/temp/temp.hs","w") do |f|
        f.write(text+"\n\nmain = undefined")
      end
      command_to_run = "ghc -XSafe #{root}/temp/temp.hs -i.:/dept/dcs/comp1100/supr/SubmissionApp/Library 2>&1"
      comments = `#{command_to_run}`
      logger.info("Running:\n#{command_to_run}")
      logger.info("Result:\n#{comments}")
    end

    ans = File.exist?("#{root}/temp/temp")
    system("rm #{root}/temp/temp*")
    [ans, comments]
  end

  def check_compiling_haskell_module
    raise "not implemented"
    Dir.mkdir('temp') unless Dir.exists? 'temp'
    todo
  end

  def test_haskell(submission, tests, add_anonymous_comment=true)
    if submission.assignment.submission_format == "zipfile"
      throw "not implemented for zips"
    end

    text = submission.body

    if check_compiling_haskell_string(text)[0]
      results = []

      score = 0

      tests.each do |test|
        root = Rails.root.to_s
        File.open("#{root}/temp/temp.hs","w") { |f| f.write(text) }
        command_to_run = ("timeout 3 ghc -i.:/dept/dcs/comp1100/supr/SubmissionApp/Library"+
            " -XSafe #{root}/temp/temp.hs 2>&1 -e " +
            "\"#{test.gsub('"','\"')}\"")
        logger.info("Running:\n#{command_to_run}")
        result = `#{command_to_run}`.strip

        if result == "True"
          score += 1
        end
        results << test + ": "+ result
      end

      if add_anonymous_comment
        Comment.create(:assignment_submission_id => submission.id,
                   :custom_behavior_id => self.id,
                   :body =>
            "You got #{score} out of #{tests.length} test cases correct. " +
            "Here's the results of each of the test cases:" +
            "<ol>#{results.map{|x| "<li>#{x.gsub("\n","\n<br>")}</li>" }.join()}</ol>")
      end

      submission.specs_passing = score
    else
      if add_anonymous_comment
        Comment.create(:assignment_submission_id => submission.id,
                   :custom_behavior_id => self.id,
                   :body => "Tests were not run because the code didn't compile.")
      end
      submission.specs_passing = 0
    end
    submission.save!
  end
end