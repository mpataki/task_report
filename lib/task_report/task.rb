require 'time' # Time.parse)
require 'securerandom'

module TaskReport
  class Task
    TaskOngoing = Class.new StandardError

    attr_reader :id, :description, :notes

    def self.from_existing_tasks(hash)
      time =
        hash['time'].map do |t|
          {
            start: Time.parse(t['start']),
            end: t['end'].nil? ? nil : Time.parse(t['end'])
          }
        end

      self.new(
        id: hash['id'],
        description: hash['description'],
        time: time,
        notes: hash['notes']
      )
    end

    def initialize(description:, time: nil, id: nil, notes: nil)
      @description = description
      @time = time || [{ start: Time.now, end: nil }]
      @id = id || SecureRandom.hex(4)
      @notes = notes || []
    end

    def to_h
      {
        id: @id,
        description: @description,
        time: @time,
        notes: @notes
      }
    end

    def to_s
      "Task #{@id}, '#{@description}'"
    end

    def duration
      Duration.new(total_time_in_seconds)
    end

    def total_time_in_seconds
      @time.inject(0) do |sum, time|
        sum + ( (time[:end] || Time.now) - time[:start] )
      end
    end

    def stop
      return unless @time.last[:end].nil?
      puts "Stopping #{self.to_s}"
      @time.last[:end] = Time.now
    end

    def continue
      raise TaskOngoing if @time.last[:end].nil?
      puts "Continuing #{self.to_s}"
      @time << { start: Time.now, end: nil }
    end

    def last_start_time
      @time.last[:start]
    end

    def ongoing?
      @time.last[:end].nil?
    end

    def add_note(note)
      @notes << note
    end
  end
end
