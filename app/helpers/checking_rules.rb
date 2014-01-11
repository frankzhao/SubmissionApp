module CheckingRules
  def check_compiling_haskell_string(text)
    Dir.mkdir('temp') unless Dir.exists? 'temp'
    File.open("tmp/temp.hs","w") { |f| f.write(text) }
    comments = `ghc tmp/temp.hs 2>&1`
    ans = File.exist?("tmp/temp")
    system('rm tmp/temp*')
    [ans, comments]
  end

  def check_compiling_haskell
    if self.assignment.submission_format == "plaintext"
      ans, errors = check_compiling_haskell_string(self.body)
      if ans
        add_anonymous_comment("This code compiles!")
      else
        add_anonymous_comment(
            "This code doesn't compile, with the following error:<br>"+errors)
      end
    else
      throw "this one assumes it's given a plain text file"
    end
  end
end