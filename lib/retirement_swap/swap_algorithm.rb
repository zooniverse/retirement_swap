module RetirementSwap
  class SwapAlgorithm
    def initialize(storage, panoptes)
      @storage = storage
      @panoptes = panoptes
    end

    def process(hash)
      classification = Classification.new(hash)
      return unless classification.user_id

      agent = @storage.find_agent(classification.user_id)

      classification.subjects.map do |subject|
        old_estimate = @storage.find_estimate(subject.id, classification.workflow_id)

        if old_estimate.retired? && subject.test?
          next old_estimate
        end

        if subject.test? || old_estimate.active?
          new_estimate = old_estimate.adjust(agent, classification.guess)
          agent.update_confusion_unsupervised(classification.guess, new_estimate.probability)
        else # training subject or retired already
          new_estimate = old_estimate
          agent.update_confusion_unsupervised(classification.guess, new_estimate.probability)
        end

        @storage.record_agent(agent)
        @storage.record_estimate(new_estimate)

        if new_estimate.retired? && subject.test?
          @panoptes.retire(new_estimate)
        end

        new_estimate
      end
    end
  end
end
