class Candidate
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::TagCollectible::Tagged

  field :name #Nome do Candidato
  field :document_number #CPF
  field :birthdate, type: Date #Data de Nascimento

  index({ document_number: 1 }, { unique: true })

  validates :name, presence: true
  validates :birthdate, presence: true
  validates :document_number, presence: true, uniqueness: true
  validate :validate_age
  validate :validate_document_number

  before_validation :downcase_tags

  private

  def validate_age
    if birthdate.present? && birthdate.to_date > 18.years.ago.to_date
      errors.add(:birthdate, 'You should be over 18 years old.')
    end
  end

  def validate_document_number
    if not (document_number.present? && CPF.valid?(document_number))
      errors.add(:document_number, 'Invalid document_number.')
    end
  end

  def downcase_tags
    tags = tags.map(&:downcase) if tags
  end

  def self.search(params)
    results = Array.new
    any_of({:name => /.*#{params[:q]}.*/ }, {document_number: /.*#{params[:q]}.*/}).only(:id, :name, :document_number).each do |candidate|
      results << {
        id: candidate.id.to_s,
        text: candidate.name + " | " + candidate.document_number
      }
    end
    {results: results}
  end
end
