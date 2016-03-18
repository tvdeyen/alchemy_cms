class CreatePublicVersionsForAlchemyPages < ActiveRecord::Migration[5.0]
  class Page < ActiveRecord::Base
    self.table_name = 'alchemy_pages'

    belongs_to :public_version,
      class_name: 'Alchemy::PageVersion',
      required: false

    def self.published
      joins(:public_version).
        where("#{table_name}.public_on <= :time AND " \
              "(#{table_name}.public_until IS NULL " \
              "OR #{table_name}.public_until >= :time)", time: Time.current)
    end

    def publish
      current_time = Time.current
      update_columns(
        published_at: current_time,
        public_on: already_public_for?(current_time) ? public_on : current_time,
        public_until: still_public_for?(current_time) ? public_until : nil
      )
    end

    private

    def already_public_for?(time)
      !public_on.nil? && public_on <= time
    end

    def still_public_for?(time)
      public_until.nil? || public_until >= time
    end
  end

  def up
    Page.published.each do |page|
      next if page.public_version
      page.update_columns(public_version_id: page.create_version.id)
      say "Created public version for #{page}"
    end
  end

  def down
    Page.where.not(public_version_id: nil).each do |page|
      page.publish
      say "Published #{page}"
    end
  end
end
