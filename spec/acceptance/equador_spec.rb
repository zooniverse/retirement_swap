require 'spec_helper'

describe 'Equador' do
  let(:storage) { Nero::Storage.new(DB) }
  let(:output) { Nero::Output::IOWriter.new(StringIO.new) }
  let(:processor) do
    Nero::Processor.new(storage, output, "1810" => {"algorithm" => "equador"})
  end

  after do
    verify do
      DB[:estimates].all
                    .sort_by { |row| row[:subject_id] }
                    .map { |row| [row[:subject_id], row[:data]] }
    end
  end

  it 'processes workflow 1810' do
    File.open(File.expand_path("../../fixtures/equador_workflow_1810.json", __FILE__), 'r') do |io|
      reader = Nero::Input::IOReader.new(io, processor)
      reader.run
    end
  end
end
