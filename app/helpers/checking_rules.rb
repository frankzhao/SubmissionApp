module CheckingRules
  def check_compiling_haskell(text)
    Dir.mkdir('temp') unless Dir.exists? 'temp'
    File.open("tmp/temp.hs","w") { |f| f.write(text) }
    comments = `ghc tmp/temp.hs 2>&1`
    ans = File.exist?("tmp/temp")
    system('rm tmp/temp*')
    [ans, comments]
  end
end