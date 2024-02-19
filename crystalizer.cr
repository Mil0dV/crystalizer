require "io"

struct WavHeader
  property riff : String
  property overall_size : UInt32
  property wave : String
  property fmt_chunk_marker : String
  property length_of_fmt : UInt32
  property format_type : UInt16
  property channels : UInt16
  property sample_rate : UInt32
  property byte_rate : UInt32
  property block_align : UInt16
  property bits_per_sample : UInt16
  property data_chunk_header : String
  property data_size : UInt32

  def initialize(@riff, @overall_size, @wave, @fmt_chunk_marker, @length_of_fmt, @format_type, @channels, @sample_rate, @byte_rate, @block_align, @bits_per_sample, @data_chunk_header, @data_size)
  end
end

def read_wav_header(filename : String) : WavHeader
  File.open(filename, "rb") do |file|
    riff_slice = Bytes.new(4)
    file.read_fully(riff_slice)
    riff = String.new(riff_slice)

    overall_size = file.read_bytes(UInt32, IO::ByteFormat::LittleEndian)

    wave_slice = Bytes.new(4)
    file.read_fully(wave_slice)
    wave = String.new(wave_slice)

    fmt_chunk_marker_slice = Bytes.new(4)
    file.read_fully(fmt_chunk_marker_slice)
    fmt_chunk_marker = String.new(fmt_chunk_marker_slice)

    length_of_fmt = file.read_bytes(UInt32, IO::ByteFormat::LittleEndian)

    format_type = file.read_bytes(UInt16, IO::ByteFormat::LittleEndian)

    channels = file.read_bytes(UInt16, IO::ByteFormat::LittleEndian)

    sample_rate = file.read_bytes(UInt32, IO::ByteFormat::LittleEndian)

    byte_rate = file.read_bytes(UInt32, IO::ByteFormat::LittleEndian)

    block_align = file.read_bytes(UInt16, IO::ByteFormat::LittleEndian)

    bits_per_sample = file.read_bytes(UInt16, IO::ByteFormat::LittleEndian)

    data_chunk_header_slice = Bytes.new(4)
    file.read_fully(data_chunk_header_slice)
    data_chunk_header = String.new(data_chunk_header_slice)

    data_size = file.read_bytes(UInt32, IO::ByteFormat::LittleEndian)

    WavHeader.new(riff, overall_size, wave, fmt_chunk_marker, length_of_fmt, format_type, channels, sample_rate, byte_rate, block_align, bits_per_sample, data_chunk_header, data_size)
  end
end

# Continuing from the previous WavHeader and read_wav_header function

def read_audio_samples(filename : String, header : WavHeader) : Array(Int16)
  samples = [] of Int16 # Initialize an empty array for the samples
  File.open(filename, "rb") do |file|
    # Move the file read position to the start of the data chunk,
    # accounting for the header size and any additional metadata
    file.seek(44 + header.length_of_fmt + 4, IO::Seek::Set)

    # Assuming header.data_size represents the total number of bytes in the data chunk,
    # and each sample is 16 bits (2 bytes), calculate the number of samples.
    num_samples = header.data_size // 2 # for 16-bit samples

    num_samples.times do
      begin
        sample = file.read_bytes(Int16, IO::ByteFormat::LittleEndian)
        samples << sample
      rescue IO::EOFError
        break # End loop if end of file is reached prematurely
      end
    end
  end
  samples
end

def calculate_rms(samples : Array(Int16)) : Float64
  return 0.0 if samples.empty?

  # Sum the squares of all sample values
  sum_of_squares = samples.reduce(0.0) { |sum, sample| sum + sample.to_f64**2 }

  # Calculate the mean of the squares
  mean_of_squares = sum_of_squares / samples.size

  # Take the square root of the mean to get the RMS
  Math.sqrt(mean_of_squares)
end

# Example usage
wav_header = read_wav_header("CantinaBand60.wav")
audio_samples = read_audio_samples("CantinaBand60.wav", wav_header)
rms_value = calculate_rms(audio_samples)

puts "Sample Rate: #{wav_header.sample_rate}"
puts "Bit Depth: #{wav_header.bits_per_sample}"
puts "Channels: #{wav_header.channels}"
puts "Audio samples count: #{audio_samples.size}"
puts "RMS Value: #{rms_value}"
