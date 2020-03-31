class Job < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_title, against: :title
  pg_search_scope :search_job,
                  against: { title: 'A', description: 'B' },
                  using: {
                    tsearch: {
                      dictionary: 'english', tsvector_column: 'searchable'
                    }
                  }
end
