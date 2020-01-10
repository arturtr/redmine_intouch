module Intouch::Preview
  class Text
    include ApplicationHelper
    include ActionView::Helpers::SanitizeHelper

    def self.normalize(issue, journal)
      new(journal&.notes.presence || issue&.description.presence || issue&.subject.presence || '').normalized
    end

    def initialize(raw_text)
      @raw_text = raw_text
    end

    def normalized
      sanitizer.sanitize(textilizable(raw_text)).truncate(200)
    end

    private

    attr_reader :raw_text

    def sanitizer
      Rails::Html::FullSanitizer.new
    end
  end
end
