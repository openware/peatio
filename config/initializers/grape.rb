class << GrapeSwagger::DocMethods::ParseParams
  def document_description(settings)
    description = settings[:desc].presence || settings[:description].presence
    description = description.respond_to?(:call) ? description.call : description
    description = '' unless description.kind_of?(String) && description.present?
    @parsed_param[:description] = description
  end
end
