module CheckingRules

  def interpret(command, args)
    case command
    when "check compiling haskell"
      self.check_compiling_haskell
    when "test haskell"
      self.test_haskell(args)
    else
      throw "Unrecognised command: #{command}, #{args}"
    end
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
    root = Rails.root.to_s

    Dir.mkdir("#{root}/temp") unless Dir.exists? "#{root}/temp"
    File.open("#{root}/temp/temp.hs","w") { |f| f.write(text) }
    comments = `ghc -XSafe #{root}/temp/temp.hs -i.:/dept/dcs/comp1100/supr/SubmissionApp/Library 2>&1`

    if comments.include?("The function `main' is not defined in module `Main'")
      File.open("#{root}/temp/temp.hs","w") do |f|
        f.write(text+"\n\nmain = undefined")
      end
      comments = `ghc -XSafe #{root}/temp/temp.hs 2>&1`
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