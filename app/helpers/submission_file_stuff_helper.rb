module SubmissionFileStuffHelper
  DATA_FILE_TYPES = /.pdf|.bmp/

  def save_locally
    if self.assignment.submission_format == "plaintext"
      File.open(self.file_path+".txt", 'w') do |f|
        f.write(self.body)
      end
    end
  end

  def save_data(data)
    File.open(self.zip_path, 'wb') do |f|
      f.write(data)
    end
  end

  def file_path
    self.assignment.path + self.file_path_without_assignment_path
  end

  def file_path_without_assignment_path
    name = self.user.name.gsub(" ","_")
    datetime = self.created_at.to_s.gsub(" ","_")
    "/#{self.id}_#{datetime}"
  end

  def zip_path
    self.file_path+".zip"
  end

  def upload=(whatever)
    @upload = whatever
  end

  def all_zip_contents
    begin

      Zip::File.open(self.zip_path, "b") do |zipfile|
        names = zipfile.map{|e| e.name}
               .select{|x| x[0..5]!= "__MACO" }
        return names
      end
    rescue
      return []
    end
  end

  def zip_contents
    begin
      zip_contents = {}
      Zip::File.open(self.zip_path, "b") do |zipfile|
        names = zipfile.map{|e| e.name}
               .select{|x| x[0..5]!= "__MACO" }

        regexp = Regexp.new(self.assignment.filepath_regex)



        names.select! { |x| regexp =~ x }

        names.each do |name|
          begin
            if zipfile.read(name)
              if name =~ DATA_FILE_TYPES
                result = zipfile.read(name)
              else
                result = zipfile.read(name).encode('utf-8', :invalid => :replace,
                                                           :undef => :replace,
                                                           :replace => '_')
              end

              zip_contents[name] = result
            end
          rescue NoMethodError
            return {}
          end
        end
      end
    rescue
      {}
    end
    zip_contents
  end

  def tail_match?(str1, str2)
    str1[-str2.length..-1] == str2
  end

  def make_files
    return unless self.assignment
    if self.assignment.submission_format == "plaintext"
      self.make_file_from_body
    elsif self.assignment.submission_format == "zipfile"
      self.make_files_from_zip_contents
    else
      fail
    end
  end

  def make_files_from_zip_contents
    contents = self.zip_contents
    if contents
      self.submission_files.destroy_all
      contents.each do |name, value|
        if name =~ DATA_FILE_TYPES
          SubmissionFile.create!(:name => name, :file_blob => value,
                                :assignment_submission_id => self.id)
        else
          SubmissionFile.create!(:name => name, :body => value,
                                :assignment_submission_id => self.id)
        end
      end
    end
  end

  def make_file_from_body
    contents = self.zip_contents
    if contents
      self.submission_files.destroy_all
      SubmissionFile.create!(:name => "main", :body => self.body,
                            :assignment_submission_id => self.id)
    end
  end

  def pretty_filename(user = nil)
    if user.nil?
      user_name = self.user.name.gsub(" ","_")
    else
      user_name = self.context_name(self.user, user).gsub(" ","_")
    end
    assignment_name = self.assignment.name.gsub(/ |-|:/, "_")
    return "u#{self.user.uni_id.to_s}_#{user_name}_#{assignment_name}_#{self.id}" 
  end

  def make_pdf
    if File.exists?("/tmp/pdf/#{self.pretty_filename}.pdf")
      return "/tmp/pdf/#{self.pretty_filename}.pdf"
    else
      hash = Digest::SHA1.hexdigest("#{rand(10000)}#{Time.now}")
      system "mkdir -p /tmp/pdf/#{hash}"
      self.submission_files.each_with_index do |file, index|
        p file.name
        if file.name =~ /pdf/
          File.open("/tmp/pdf/#{hash}/#{index}.pdf", "wb") do |f|
            f.write(file.file_blob)
          end
        else
          escaped_body = file.body.gsub(/(?<foo>[$%\\])/, '\\\\\k<foo>')
          File.open("/tmp/pdf/#{hash}/#{index}.tex", "w") do |f|
            f.write(<<-FILE)
\\nonstopmode
\\documentclass[a4paper, 8pt]{article}
\\usepackage[usenames]{color}
\\usepackage{hyperref}
\\oddsidemargin 0in
\\textwidth 6in
\\topmargin -0.5in
\\textheight 9in
\\columnsep 0.25in
\\newsavebox{\\spaceb}
\\newsavebox{\\tabb}
\\savebox{\\spaceb}[1ex]{~}
\\savebox{\\tabb}[4ex]{~}
\\newcommand{\\hsspace}{\\usebox{\\spaceb}}
\\newcommand{\\hstab}{\\usebox{\\tabb}}
\\newcommand{\\conceal}[1]{}
\\begin{document}
\\textbf{#{file.name.gsub(/(?<foo>[$%_\\])/, '\\\\\k<foo>')}}\\\\
\\textbf{#{self.user.name}}\ \ \\textbf{u#{self.user.uni_id}}
\\begin{verbatim}
#{escaped_body}
\\end{verbatim}
\\end{document}
            FILE
          end
          system("pdflatex -output-directory=/tmp/pdf/#{hash} /tmp/pdf/#{hash}/#{index}.tex")
        end
      end

      num_files = self.submission_files.length
      files_string = (0...num_files).map { |x| "/tmp/pdf/#{hash}/#{x}.pdf" }.join(" ")
      system("gs -q -sPAPERSIZE=letter -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=/tmp/pdf/#{self.pretty_filename}.pdf #{files_string}")
      "/tmp/pdf/#{hash}/#{self.pretty_filename}.pdf"
      system("rm -rf /tmp/pdf/#{hash}")
      return "/tmp/pdf/#{self.pretty_filename}.pdf"
    end
  end
end
