namespace :article do
  desc 'Load data referenced in article'
  task data: :environment do
    (1..5).each do |page|
      puts "Loading GitHub Page #{page}"
      result = LoadGitHubJobs.call(page)
      break if result.jobs.empty?
    end

    puts 'Loading Hacker News Page 1'
    LoadHackerNewsJobs.call
  end
end
