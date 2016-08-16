module TaskAPI
  class << self
    def start(new_task_description)
      report =
        if report_gist.nil?
          Report.create(new_task_description: new_task_description)
        else
          Report.create_from_gist(report_gist).tap(&:stop_all_tasks)
        end

      report.start_task(new_task_description)
      report.save_to_gist!
    end

    def stop
      return if no_gist?

      report = Report.create_from_gist(report_gist)
      report.stop_all_tasks
      report.save_to_gist!
      puts "All tasks stopped"
    end

    def continue(task_id)
      return if no_gist?

      report = Report.create_from_gist(report_gist)
      report.continue(task_id)
      report.save_to_gist!
    rescue Report::TaskAlreadyOngoing, Task::TaskOngoing => e
      puts "Task already underway - #{e.message}"
    end

    def list
      return if no_gist?

      Report.create_from_gist(report_gist).print_tasks
    end

    private
      def report_gist
        @report_gist ||=
          Gist.find_gist_from_today_by_description(Report.gist_description)
      end

      def no_gist?
        if report_gist.nil?
          puts 'No report exists for today - nothing to do.'
          puts 'See `report help` for usage info.'
          return true
        end

        false
      end
  end
end