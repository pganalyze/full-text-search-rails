class LoadGitHubJobs
  extend LightService::Organizer

  def self.call(page = 1)
    with(page: page).reduce(FetchJobs, iterate(:jobs, [SaveJob]))
  end

  class FetchJobs
    extend LightService::Action
    expects :page
    promises :jobs

    executed do |context|
      page = context.page
      url = "https://jobs.github.com/positions.json?page=#{page}&search=code"
      response = HTTP.get(url)

      if response.status.success?
        context.jobs = response.parse
      else
        context.fail_and_return!('Unable to fetch jobs')
      end
    end
  end

  class SaveJob
    extend LightService::Action
    expects :job

    executed do |context|
      data = context.job
      next if Job.where(source: 'GitHub', source_id: data['id']).exists?

      fragment = Nokogiri::HTML.fragment(data['description'], encoding = nil)
      description = fragment.content

      Job.create!(
        source: 'GitHub',
        source_id: data['id'],
        title: data['title'],
        description: description,
        url: data['url'],
        posted_at: Time.zone.parse(data['created_at'])
      )
    end
  end
end
