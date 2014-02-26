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
          "<strong>This code doesn't compile</strong>, with the following error:<br>
            <pre>#{errors}</pre>")
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
    comments = `ghc -XSafe #{root}/temp/temp.hs 2>&1`
    ans = File.exist?("#{root}/temp/temp")
    system("rm #{root}/temp/temp*")
    [ans, comments]
  end

  def check_compiling_haskell_module
    Dir.mkdir('temp') unless Dir.exists? 'temp'
    todo
  end

  def test_haskell(tests)
    throw "not implemented for zips" if self.assignment.submission_format == "zipfile"
    text = self.body
    results = []

    score = 0

    tests.each do |test|
      root = Rails.root.to_s
      File.open("#{root}/temp/temp.hs","w") { |f| f.write(text) }
      result = `ghc -XSafe #{root}/temp/temp.hs 2>&1 -e "#{test}"`.strip
      if result == "True"
        score += 1
      end
      results << test + ": "+ result
    end

    add_anonymous_comment(
          "You got #{score} out of #{tests.length} test cases correct. " +
          "Here's the results of each of the test cases:" +
          "<ol>#{results.map{|x| "<li>#{x}</li>" }.join()}</ol>")
  end
end