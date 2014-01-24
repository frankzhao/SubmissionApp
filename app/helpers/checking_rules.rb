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
    Dir.mkdir('temp') unless Dir.exists? 'temp'
    File.open("tmp/temp.hs","w") { |f| f.write(text) }
    comments = `ghc -XSafe tmp/temp.hs 2>&1`
    ans = File.exist?("tmp/temp")
    system('rm tmp/temp*')
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

    tests.each do |test|
      File.open("tmp/temp.hs","w") { |f| f.write(text) }
      results << test + ": "+ `ghc -XSafe tmp/temp.hs 2>&1 -e "#{test}"`.strip
    end

    score = results.count("True")

    add_anonymous_comment(
          "You got #{score} out of #{tests.length} test cases correct. " +
          "Here's the results of each of the test cases:" +
          "<ol>#{results.map{|x| "<li>#{x}</li>" }.join()}</ol>")
  end
end