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

  def pretty_filename(user)
    user_name = self.context_name(self.user, user).gsub(" ","_")
    assignment_name = self.assignment.name.gsub(/ |-|:/, "_")
    user_name + "_" + assignment_name
  end
end
