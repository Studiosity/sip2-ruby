require 'spec_helper'

describe Sip2::NonBlockingSocket do
  subject(:socket) { Sip2::NonBlockingSocket.new(:INET, :STREAM) }

  describe '#send_with_timeout' do
    it 'calls to underlying socket `send` method with message and default flags' do
      expect(socket).to receive(:send).with("foo\r", 0)
      socket.send_with_timeout 'foo'
    end

    it 'doesnt timeout if send succeeds in less than 5 seconds' do
      expect(socket).to receive(:send) do
        sleep 4.8
      end
      expect { socket.send_with_timeout 'foo' }.not_to raise_error
    end

    it 'raises WriteTimeout if send takes more than 5 seconds' do
      expect(socket).to receive(:send) do
        sleep 5.2
      end
      expect { socket.send_with_timeout 'foo' }.to raise_error Sip2::WriteTimeout
    end
  end

  describe '#gets_with_timeout' do
    it 'calls to underlying socket `gets` method and returns result' do
      expect(socket).to receive(:gets).with("\r").and_return "bar\r"
      expect(socket.gets_with_timeout).to eq "bar\r"
    end

    it 'doesnt timeout if gets succeeds in less than 5 seconds' do
      expect(socket).to receive(:gets) do
        sleep 4.8
      end
      expect { socket.gets_with_timeout }.not_to raise_error
    end

    it 'raises ReadTimeout if gets takes more than 5 seconds' do
      expect(socket).to receive(:gets) do
        sleep 5.2
      end
      expect { socket.gets_with_timeout }.to raise_error Sip2::ReadTimeout
    end
  end
end
