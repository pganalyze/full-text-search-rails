class LoadHackerNewsJobs
  extend LightService::Organizer

  def self.call
    reduce(FetchJobsIds, iterate(:job_ids, [FetchJob]))
  end

  class FetchJobsIds
    extend LightService::Action
    promises :job_ids

    executed do |context|
      url = 'https://hacker-news.firebaseio.com/v0/jobstories.json'
      response = HTTP.get(url)

      if response.status.success?
        context.job_ids = response.parse
      else
        context.fail_and_return!('Unable to fetch jobs')
      end
    end
  end

  class FetchJob
    extend LightService::Action
    expects :job_id

    executed do |context|
      job_id = context.job_id
      next if Job.where(source: 'HackerNews', source_id: job_id).exists?

      url = "https://hacker-news.firebaseio.com/v0/item/#{job_id}.json"
      response = HTTP.get(url)
      next unless response.status.success?

      data = response.parse
      description = data['text'].presence
      description ||= og_description(data['url']) if data['url'].present?
      next if description.blank?

      Job.create!(
        source: 'HackerNews',
        source_id: job_id,
        title: data['title'],
        description: description,
        url: data['url'],
        posted_at: Time.zone.at(data['time'])
      )
    end

    def self.og_description(url)
      response = HTTP.get(url)
      return nil unless response.status.success?

      doc = Nokogiri(response.body.to_s)

      node = doc.at('meta[property="og:description"]')
      return node['content'] if node.present? && node['content'].present?

      node = doc.at('meta[name="description"]')
      return node['content'] if node.present? && node['content'].present?

      nil
    end
  end
end
