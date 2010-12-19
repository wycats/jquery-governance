class ExistenceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    begin 
      Motion.find(value) 
    rescue ActiveRecord::RecordNotFound
      record.errors[attribute] << "does not exist" 
    end
  end
end
