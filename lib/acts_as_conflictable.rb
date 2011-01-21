module ActsAsConflictable
  def self.included(base)
    base.class_eval do
      has_many :conflictions, :as => :conflictable, :dependent => :destroy, :include => :conflict
      has_many :conflicts, :through => :conflictions

      after_save :save_conflicts
    end

    base.send :extend, ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
      ##
      # Return a scope of objects that conflict with the specified conflicts
      #
      # @param conflicts The conflicts that we want to query for
      # @param [Hash] options A hash of options to alter you query:
      #                       * <tt>:exclude</tt> - if set to true, return objects that do *NOT* conflict with the specified conflicts
      #                       * <tt>:any</tt> - if set to true, return objects that conflict with *ANY* of the specified conflicts
      #                       * <tt>:match_all</tt> - if set to true, return objects that *ONLY* conflict with the specified conflicts
      #
      # Example:
      #   Member.conflicts_with(["awesome", "cool"])                     # Members that conflict with awesome and cool
      #   Member.conflicts_with(["awesome", "cool"], :exclude => true)   # Members that do not conflict with awesome or cool
      #   Member.conflicts_with(["awesome", "cool"], :any => true)       # Members that conflict with awesome or cool
      #   Memeber.conflicts_with(["awesome", "cool"], :match_all => true) # Members that conflict with just awesome and cool
      def conflicts_with(conflicts, options = {})
        conflict_list = ConflictList.from(conflicts)

        return {} if conflict_list.empty?

        joins = []
        conditions = []

        if options.delete(:exclude)
          conflicts_conditions = conflict_list.map { |t| sanitize_sql(["conflicts.name LIKE ?", t]) }.join(" OR ")
          conditions << "#{table_name}.#{primary_key} NOT IN (SELECT conflictions.conflictable_id FROM conflictions JOIN conflicts ON conflictions.conflict_id = conflicts.id AND (#{conflicts_conditions}) WHERE conflictions.conflictable_type = #{quote_value(base_class.name)})"

        elsif options.delete(:any)
          conflicts_conditions = conflict_list.map { |t| sanitize_sql(["conflicts.name LIKE ?", t]) }.join(" OR ")
          conditions << "#{table_name}.#{primary_key} IN (SELECT conflictions.conflictable_id FROM conflictions JOIN conflicts ON conflictions.conflict_id = conflicts.id AND (#{conflicts_conditions}) WHERE conflictions.conflictable_type = #{quote_value(base_class.name)})"

        else
          conflicts = Conflict.named_any(conflict_list)
          return scoped(:conditions => "1 = 0") unless conflicts.length == conflict_list.length

          conflicts.each do |conflict|
            safe_conflict = conflict.name.gsub(/[^a-zA-Z0-9]/, '')
            prefix   = "#{safe_conflict}_#{rand(1024)}"

            conflictions_alias = "#{undecorated_table_name}_conflictions_#{prefix}"

            confliction_join  = "JOIN conflictions #{conflictions_alias}" +
                            "  ON #{conflictions_alias}.conflictable_id = #{table_name}.#{primary_key}" +
                            " AND #{conflictions_alias}.conflictable_type = #{quote_value(base_class.name)}" +
                            " AND #{conflictions_alias}.conflict_id = #{conflict.id}"

            joins << confliction_join
          end
        end

        conflictions_alias, conflicts_alias = "#{undecorated_table_name}_conflictions_group", "#{undecorated_table_name}_conflicts_group"

        if options.delete(:match_all)
          joins << "LEFT OUTER JOIN conflictions #{conflictions_alias}" +
                   "  ON #{conflictions_alias}.conflictable_id = #{table_name}.#{primary_key}" +
                   " AND #{conflictions_alias}.conflictable_type = #{quote_value(base_class.name)}"


          group_columns = column_names.map { |column| "#{table_name}.#{column}" }.join(", ")
          group = "#{group_columns} HAVING COUNT(#{conflictions_alias}.conflictable_id) = #{conflicts.size}"
        end


        scoped(:joins      => joins.join(" "),
               :group      => group,
               :conditions => conditions.join(" AND "),
               :order      => options[:order],
               :readonly   => false)
      end
  end

  module InstanceMethods
    def conflicts_list
      @conflicts_list ||= ConflictList.new(self.conflicts.map(&:name))
    end

    def conflicts_list=(new_list)
      @conflicts_list = ConflictList.from(new_list)
    end

    def save_conflicts

      # Find existing conflicts or create non-existing conflicts:
      conflicts_from_list = Conflict.find_or_create_all_with_like_by_name(self.conflicts_list)

      current_conflicts   = conflicts
      old_conflicts       = current_conflicts - conflicts_from_list
      new_conflicts       = conflicts_from_list - current_conflicts

      # Find conflictions to remove:
      old_conflictions = conflictions.where(:conflict_id => old_conflicts)

      if old_conflictions.present?
        # Destroy old conflictions:
        old_conflictions.destroy_all
      end

      # Create new conflictions:
      new_conflicts.each do |conflict|
        conflictions.create!(:conflict_id => conflict.id)
      end

      true
    end

    def conflicts_with?(conflictable)
      !(conflicts_list & conflictable.conflicts_list).empty?
    end
  end
end
