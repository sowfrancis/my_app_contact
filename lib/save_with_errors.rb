module SaveWithErrors

  def save_with_errors!(*args)
    save_without_errors! *args
  rescue ActiveRecord::RecordInvalid
    save_anyway
    raise # this re-raises the exception we just rescued
  end

  def save_with_errors(*args)
    save_without_errors *args or save_anyway
  end

  def self.included(receiver)
    receiver.serialize :record_errors, Hash
    receiver.alias_method_chain :save, :errors
    receiver.alias_method_chain :save!, :errors
  end

  private

  def save_anyway
    dup.tap { |s| s.record_error = errors.messages }.save(validate: false)
    false
  end

end