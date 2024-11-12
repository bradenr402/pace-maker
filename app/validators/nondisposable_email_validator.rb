class NondisposableEmailValidator < ActiveModel::EachValidator
  DISPOSABLE_DOMAINS = EmailData::disposable_domains

  def validate_each(record, attribute, value)
    domain = value.split('@').last

    return unless DISPOSABLE_DOMAINS.include?(domain)

    record.errors.add(attribute, options[:message] || 'is a disposable email address and cannot be used.')
  end
end
