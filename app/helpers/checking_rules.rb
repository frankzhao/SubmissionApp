#### This module is included in AssignmentSubmission

# Your args are parsed as JSON.

module CheckingRules
  def receive_submission
    self.save_locally

    unless self.assignment.behavior_on_submission.empty?
      behavior_on_submission = JSON.parse(self.assignment.behavior_on_submission)

      behavior_on_submission.each do |command, args|
        self.interpret(command, args)
      end
    end
  end

  def interpret(command, args)
    case command
    when "check compiling haskell"
      self.check_compiling_haskell
    when "test haskell"
      self.test_haskell(args)
    when "check files"
      self.check_files(args)
    else
      throw "Unrecognised command: #{command}, #{args}"
    end
  end

  def check_files(args)
    file_list = self.all_zip_contents

    template = ERB.new(<<-TEXT)
      This submission should have the following files:
      <ul>
        <% args["required_files"].each do |file| %>
          <li>
            <%= file %>:
            <% if file_list.include?(file) %>
              present
            <% else %>
              <b>not present</b>
            <% end %>
          </li>
        <% end %>
      </ul>

      The following files are optional: it's okay if you chose not to submit them.
      But if you did submit them, they should be here:

      <ul>
        <% args["optional_files"].each do |file| %>
          <li>
            <%= file %>:
            <% if file_list.include?(file) %>
              present
            <% else %>
              not present
            <% end %>
          </li>
        <% end %>
      </ul>
    TEXT

    add_anonymous_comment(template.result(binding))
  end

  def check_compiling_haskell
    if self.assignment.submission_format == "plaintext"
      ans, errors = check_compiling_haskell_string(self.body)
      if ans
        add_anonymous_comment("This code compiles!")
      else
        add_anonymous_comment(
          "<strong>This code doesn't compile</strong>, with the following error:<br><code>
            <pre>#{errors}</pre></code>")
      end
    else
      check_compiling_haskell_module(self.zip_path)
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

  def test_haskell(tests, add_anonymous_comment=true)
    throw "not implemented for zips" if self.assignment.submission_format == "zipfile"

    text = self.body

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
        add_anonymous_comment(
            "You got #{score} out of #{tests.length} test cases correct. " +
            "Here's the results of each of the test cases:" +
            "<ol>#{results.map{|x| "<li>#{x.gsub("\n","\n<br>")}</li>" }.join()}</ol>")
      end

      self.specs_passing = score
    else
      if add_anonymous_comment
        add_anonymous_comment("Tests were not run because the code didn't compile.")
      end
      self.specs_passing = 0
    end
    self.save!
  end
end