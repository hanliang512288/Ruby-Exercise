require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.every '10m' do
  Datarecord.update_all
end
