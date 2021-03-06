# frozen_string_literal: true

require 'eksek'
require 'eksekuter'

RSpec.describe 'Eksekuter success methods' do
  it 'returns true or false depending on the exit code' do
    expect(Eksekuter.new.exec('true').success?).to be(true)
    expect(Eksekuter.new.exec('exit 1').success?).to be(false)
  end

  it 'fails when appropriate' do
    expect { Eksekuter.new.exec('true').success! }.not_to raise_error
    expect { Eksekuter.new.exec('exit 1').success! }.to raise_error EksekError
  end

  it 'returns the exit code' do
    expect(Eksekuter.new.exec('exit 0').exit_code).to be(0)
    expect(Eksekuter.new.exec('exit 1').exit_code).to be(1)
    expect(Eksekuter.new.exec('exit 7').exit_code).to be(7)
  end
end

RSpec.describe 'Eksekuter#capture' do
  it 'captures the stdout and stderr separately' do
    expect(Eksekuter.new.capture('printf Hello').stdout)
      .to eq('Hello')
    expect(Eksekuter.new.capture('printf Hello >&2').stderr)
      .to eq('Hello')
  end
end

RSpec.describe 'Eksekuter with overridden output streams' do
  it 'can write to a custom IO object' do
    readable, writable = IO.pipe
    Eksekuter.new.exec('printf Hello', out: writable)
    writable.close
    expect(readable.read).to eq('Hello')
  end

  it 'can read from a custom IO object' do
    readable, writable = IO.pipe
    writable.write 'Hello'
    writable.close
    expect(Eksekuter.new.capture('read A; printf $A', in: readable).stdout)
      .to eq('Hello')
  end
end

RSpec.describe 'Standard input' do
  it 'can write to a custom IO object' do
    readable, writable = IO.pipe
    Eksekuter.new.exec('printf Hello', out: writable)
    writable.close
    expect(readable.read).to eq('Hello')
  end

  it 'can read from a custom IO object' do
    readable, writable = IO.pipe
    writable.write 'Hello'
    writable.close
    expect(Eksekuter.new.capture('read A; printf $A', in: readable).stdout)
      .to eq('Hello')
  end
end

RSpec.describe 'Kernel#spawn-style parameters' do
  it 'accepts a Hash as an optional first parameter' do
    result = Eksekuter.new
      .capture({ 'TEXT' => 'Hello' }, 'printf $TEXT')
    expect(result.stdout).to eq('Hello')
  end

  it 'stringifies the keys of the environment' do
    result = Eksekuter.new
      .capture({ TEXT: 'Hello' }, 'printf $TEXT')
    expect(result.stdout).to eq('Hello')
  end

  it 'accepts a variable-length parameter list as command' do
    result = Eksekuter.new
      .capture('echo', 'Hello', 'World')
    expect(result.stdout).to eq("Hello World\n")
  end
end
