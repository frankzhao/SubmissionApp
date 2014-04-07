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
    name = self.user.name.gsub(" ","_")
    datetime = self.created_at.to_s.gsub(" ","_")
    self.assignment.path + "/#{self.id}_#{datetime}"
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
    user_name + "_" + assignment_name
  end

  def make_pdf
    self.submission_files.select{ |f| f.body != nil }.each_with_index do |file, index|
      if file.name =~ /pdf/
        File.open("/tmp/#{index}.pdf", "wb") do |f|
          f.write(file.file_blob)
        end
      else
        escaped_body = file.body.gsub(/(?<foo>[$%\\])/, '\\\\\k<foo>')
        File.open("/tmp/#{index}.tex", "w") do |f|
          f.write(<<-FILE)
\\nonstopmode
\\documentclass[12pt]{report}
\\usepackage[margin=0.5in]{geometry}
\\begin{document}
\\textbf{#{file.name.gsub(/(?<foo>[$%_\\])/, '\\\\\k<foo>')}}\\\\
\\textbf{#{self.user.name}}
\\begin{verbatim}
#{escaped_body}
\\end{verbatim}
\\end{document}
          FILE
        end
        system("pdflatex -output-directory=/tmp /tmp/#{index}.tex")
      end
    end

    num_files = self.submission_files.length
    files_string = (0...num_files).map { |x| "/tmp/#{x}.pdf" }.join(" ")
    system("pdfconcat -o /tmp/#{self.pretty_filename}.pdf #{files_string}")
    "/tmp/#{self.pretty_filename}.pdf"
  end
end
