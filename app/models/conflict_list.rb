class ConflictList < Array
  cattr_accessor :delimiter
  self.delimiter = ','

  attr_accessor :owner

  def initialize(*args)
    add(*args)
  end

  ##
  # Add conflicts to the ConflictList. Duplicate or blank conflicts will be ignored.
  # Use the <tt>:parse</tt> option to add an unparsed conflict string.
  #
  # Example:
  #   conflict_list.add("Fun", "Happy")
  #   conflict_list.add("Fun, Happy", :parse => true)
  def add(*names)
    extract_and_apply_options!(names)
    concat(names)
    clean!
    self
  end

  ##
  # Returns a new ConflictList using the given conflict string.
  #
  # Example:
  #   conflict_list = ConflictList.from("One , Two,  Three")
  #   conflict_list # ["One", "Two", "Three"]
  def self.from(string)
    glue   = delimiter.ends_with?(" ") ? delimiter : "#{delimiter} "
    string = string.join(glue) if string.respond_to?(:join)

    new.tap do |conflict_list|
      string = string.to_s.dup

      # Parse the quoted conflicts
      string.gsub!(/(\A|#{delimiter})\s*"(.*?)"\s*(#{delimiter}\s*|\z)/) { conflict_list << $2; $3 }
      string.gsub!(/(\A|#{delimiter})\s*'(.*?)'\s*(#{delimiter}\s*|\z)/) { conflict_list << $2; $3 }

      conflict_list.add(string.split(delimiter))
    end
  end

  ##
  # Add conflicts to the conflict_list. Duplicate or blank conflicts will be ignored.
  # Use the <tt>:parse</tt> option to add an unparsed conflict string.
  #
  # Example:
  #   conflict_list.add("Fun", "Happy")
  #   conflict_list.add("Fun, Happy", :parse => true)
  def add(*names)
    extract_and_apply_options!(names)
    concat(names)
    clean!
    self
  end

  ##
  # Remove specific conflicts from the conflict_list.
  # Use the <tt>:parse</tt> option to add an unparsed conflict string.
  #
  # Example:
  #   conflict_list.remove("Sad", "Lonely")
  #   conflict_list.remove("Sad, Lonely", :parse => true)
  def remove(*names)
    extract_and_apply_options!(names)
    delete_if { |name| names.include?(name) }
    self
  end

  ##
  # Transform the conflict_list into a conflict string suitable for edting in a form.
  # The conflicts are joined with <tt>conflictList.delimiter</tt> and quoted if necessary.
  #
  # Example:
  #   conflict_list = conflictList.new("Round", "Square,Cube")
  #   conflict_list.to_s # 'Round, "Square,Cube"'
  def to_s
    conflicts = frozen? ? self.dup : self
    conflicts.send(:clean!)

    conflicts.map do |name|
      name.include?(delimiter) ? "\"#{name}\"" : name
    end.join(delimiter.ends_with?(" ") ? delimiter : "#{delimiter} ")
  end

  private

  # Remove whitespace, duplicates, and blanks.
  def clean!
    reject!(&:blank?)
    map!(&:strip)
    uniq!
  end

  def extract_and_apply_options!(args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    options.assert_valid_keys :parse

    if options[:parse]
      args.map! { |a| self.class.from(a) }
    end

    args.flatten!
  end
end
