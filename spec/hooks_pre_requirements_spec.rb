require 'spec_helper'
require 'yaml'
require 'kafo'

HOOK_DIR = File.expand_path(File.join(__FILE__, "../../hooks"))

describe 'scenario requirements' do
  let(:kafo) do
    double('Kafo::KafoConfigure')
  end

  let(:hook_path) do
    File.join(HOOK_DIR, 'pre', '05-check_scenario_requirements.rb')
  end

  let(:hook) do
    hook = File.read(hook_path)
    proc { instance_eval(hook, '05-check_scenario_requirements.rb', 1) }
  end

  let(:logger) do
    double('Logger')
  end

  let(:scenario_data) do
    {
      required: required,
    }
  end

  let(:facts) do
    {
      memory: {
        system: {
          total_bytes: 8 * 1024 ** 3,
        },
      },
      processors: {
        count: 4,
      },
      mountpoints: {
        '/': {
          available_bytes: 3 * 1024 ** 3,
        },
        '/var': {
          available_bytes: 100 * 1024 ** 3,
        },
      },
    }
  end

  let(:disable_system_checks) do
    false
  end

  let(:context) do
    ctx = double('Kafo::HookContext')
    allow(ctx).to receive(:app_value).with(:disable_system_checks).and_return(disable_system_checks)
    allow(ctx).to receive(:facts).and_return(facts)
    allow(ctx).to receive(:logger).and_return(logger)
    allow(ctx).to receive(:scenario_data).and_return(scenario_data)
    ctx
  end

  let(:executor) do
    context.instance_exec(kafo, &hook)
  end

  describe 'without requirements' do
    let(:required) do
      nil
    end

    it 'should return nil' do
      expect(logger).to receive(:debug).with('No requirements for this scenario')
      expect(executor).to be_nil
    end
  end

  describe 'insufficient memory' do
    let(:required) do
      {
        'memory' => 10 * 1024 ** 3,
        'cores'  => 4,
      }
    end

    it 'should exit with 1' do
      expect(logger).to receive(:error).with('This system has 8 GiB of total memory. Please ensure at least 10 GiB of total memory before running the installer.')
      expect(context).to receive(:exit).with(1)

      expect(executor).to be_nil
    end
  end

  describe 'insufficient cores' do
    let(:required) do
      {
        'memory' => 1024 * 1024,
        'cores'  => 8,
      }
    end

    it 'should exit with 1' do
      expect(logger).to receive(:error).with('This system has 4 CPU cores. Please ensure at least 8 cores before running the installer.')
      expect(context).to receive(:exit).with(1)

      expect(executor).to be_nil
    end
  end
end
